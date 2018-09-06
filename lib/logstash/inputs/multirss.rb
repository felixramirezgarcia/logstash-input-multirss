# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "net/http"
require "uri"
require "mechanize"
require "rss"
require "nokogiri"
require "fileutils"

# if you want to debug it you just have to uncomment the puts and build the gem with 
#   ruby -S gem build logstash-input-multirss.gemspec
# and install the gem in a logstash service or container with
#   logstash-plugin install logstash-input-multirss-x.x.x.gem

class LogStash::Inputs::Multirss < LogStash::Inputs::Base
  config_name "multirss"  #Plugin name

  default :codec, "plain" #Codec

  # The rss parent array list to use in the pipe (link with a lot rss links inside)
  config :multi_feed, :validate => :array, :default => []

  # The rss childs array list to use in the pipe (simple rss link)
  config :one_feed, :validate => :array, :default => []

  #Set de interval for stoppable_sleep
  config :interval, :validate => :number, :default => 3600
  
  #Set de black list to forget read and get content 
  config :blacklist, :validate => :array, :default => []

  #Set de keywords to ONLY get content whit it
  config :keywords, :validate => :array, :default => []

  public
   
   def register #initialize
    #Mechanize agent
    @agent = Mechanize.new
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   end # def register


  def run(queue)
    # we can abort the loop if stop? becomes true
    urls = []

    #Don't stop, keep going.
    while !stop?

      manage_tempdir

      @multi_feed.each do |rss|     #get the father's children
        #puts "Read parent: " + rss
        begin
          page = @agent.get(rss)
          page.links.each do |link|
              if (link.href.chars.last(3).join == "xml" || link.href.include?('/rss') || link.href.include?('/feed')) && not_include_blacklist(link) 
                urls << link.href
              end
          end
        rescue
          str = "Fail to get " + rss + " childrens links"
          #puts str
        end # end begin
         
        links = urls.uniq
        links.each do |link|
          begin
            response_link(link,queue)
            #puts "Read clidren: " + link
          rescue
            #puts "Fail to get " + link + " children"
            next
          end # end begin
        end # end each links

        urls.clear
      end # multi_feed loop

      @one_feed.each do |feed|
        urls << feed
      end # one_feed loop

      all_links = urls.uniq
      all_links.each do |link|
        begin
          response_link(link,queue)
          #puts "Read clidren: " + link
        rescue
          #puts "Fail to get " + link
          next
        end # begin
      end # all_links loop

      urls.clear

      # Remove the tempfiles
      if (File::directory?(@d))
        ENV.delete("TMPDIR")
        FileUtils.rm_rf @d
        #puts "Remove temp dir"
      end

    #Stoppable_sleep interval
    Stud.stoppable_sleep(@interval) { stop? }
    end # end while
  end # end def run


  def stop
  end #def stop

  def response_link(link, queue)
    tried = 2
    begin
      page = Nokogiri::XML(open(link,&:read)) # [&:read] -> no OpenURI outputs in /tmp
      page.search('item').each do |item| 
        link_rss_response(queue, item)
      end # end each page
    rescue => ex
      if link.chars.first(1).join == "/" && link.chars.first(2).join != "//"
        link = "http:/" + link
        retry
      elsif link.chars.first(1).join == "/" && link.chars.first(2).join == "//"
        link = "http:" + link
        retry
      end # end if elsif
      if link.chars.first(4).join == "http" && link.chars.first(5).join != "https"
        link = link.sub('http','https')
        tried = tried - 1
        retry if (tried > 0)
      end # end if 
      #@logger.error("Error : ", :exception => ex)
    rescue => exc
      @logger.error("Uknown error while parsing the feed", :exception => exc)
    end # end begin
  end # end def response_link

  def link_rss_response(queue, item)
      event = LogStash::Event.new()

      if @keywords.size.to_s.to_i > 0 # "Have keywords
        haskey = false

        item.element_children.each do |x|   
            if include_keywords(x.inner_html.to_s)
              #puts "--------------Finded notice with the keyword---------------"
              haskey = true
            end
        end # end loop

        if haskey == true
          item.element_children.each do |x|
            #puts "The notice " + x.name + " is " + x.inner_html.to_s
            if x.inner_html.to_s.chars.first(9).join == "<![CDATA["
              eve = LogStash::Event.new( x.name => x.inner_html.to_s[9..x.inner_html.to_s.length-4] )
              event.append( eve )
            else
              eve = LogStash::Event.new( x.name => x.inner_html.to_s )
              event.append( eve )
            end # end if else       
          end # end loop
        elsif haskey == false # havent haskey
          event = nil
        end # if haskey

      else # havent keywords!
        #puts "Havent keywords, go to get all items"
        item.element_children.each do |x|
          if x.inner_html.to_s.chars.first(9).join == "<![CDATA["
            eve = LogStash::Event.new( x.name => x.inner_html.to_s[9..x.inner_html.to_s.length-4])
            event.append( eve )
          else
            eve = LogStash::Event.new( x.name => x.inner_html.to_s )
            event.append( eve )
          end # end if
        end # end loop
      end # end if have keywords

      if event != nil
        decorate(event)
        queue << event
      end # end if
      
  end # def link_rss_response


  def not_include_blacklist(link) 
      for i in 0..@blacklist.length-1
        if link.href.include?(@blacklist[i])
          return false
        end # end if
      end # end for
      return true
  end # def not_include_blacklist


  def include_keywords(key) 
    for i in 0..@keywords.length-1
      if key.include?(@keywords[i])
        return true
      end # end if
    end # end for
    return false
  end # def include_keywords
  

  def manage_tempdir
    #set the tempfile to openUri output
    @d = "#{Dir.home}/.tmp"
    #if exists
    if (File::directory?(@d))
      #puts "Dir exists , removed and create again"
      ENV.delete("TMPDIR")
      FileUtils.rm_rf @d
      #create new
      Dir.mkdir @d    #create in /usr/share/logstash
      ENV["TMPDIR"] = @d
    else
      Dir.mkdir @d    #create in /usr/share/logstash
      ENV["TMPDIR"] = @d
      #puts "Dir no exist , created...."
    end
  end


end # class LogStash::Inputs::Crawler
