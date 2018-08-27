# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "net/http"
require "uri"
require "mechanize"
require "rss"
require "nokogiri"

# if you want to debug it you just have to uncomment the puts and build the gem with 
#   ruby -S gem build logstash-input-multirss.gemspec
# and install the gem in a logstash service with
#   logstash-plugin install logstash-input-multirss-x.x.x.gem

class LogStash::Inputs::Multirss < LogStash::Inputs::Base
  config_name "multirss"

  default :codec, "plain"

  # The rss array list to use in the pipe
  config :multi_feed, :validate => :array, :required => true

  # The rss array list to use in the pipe
  config :one_feed, :validate => :array, :default => []

  #Set de interval for stoppable_sleep
  config :interval, :validate => :number, :default => 3600
  
  #Set de black list to forget read
  config :blacklist, :validate => :array, :default => []

  public
   def register
    @agent = Mechanize.new
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   end # def register


  def run(queue)
    # we can abort the loop if stop? becomes true
    urls = []

    while !stop?
      
      @multi_feed.each do |rss|
        str = "Read parent: " + rss
        #puts str
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
            str = "Read clidren: " + link
            #puts str
          rescue
            str = "Fail to get " + link + " children"
            #puts str
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
          str = "Read clidren: " + link
          #puts str
        rescue
          str = "Fail to get " + link
          #puts str
          next
        end # begin
      end # all_links loop

      urls.clear

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
      item.element_children.each do |x| 
        if x.inner_html.to_s.chars.first(9).join == "<![CDATA["
          eve = LogStash::Event.new( x.name => x.inner_html.to_s[9..x.inner_html.to_s.length-4])
          event.append( eve )
        else
          eve = LogStash::Event.new( x.name => x.inner_html.to_s )
          event.append( eve )
        end # end if
      end # end loop
      decorate(event)
      queue << event
  end # def link_rss_response

  def not_include_blacklist(link) 
      for i in 0..@blacklist.length-1
        if link.href.include?(@blacklist[i])
          return false
        end # end if
      end # end for
      return true
  end # def not_include_blacklist


end # class LogStash::Inputs::Crawler
