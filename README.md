# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

# Developing

## Install

U can install the plugin from https://rubygems.org/gems/logstash-input-multirss , or build it yuouself in a logstash service or container with :

git clone https://github.com/felixramirezgarcia/logstash-input-multirss

rm logstash-input-multirss-[nº_version].gem

ruby -S gem build logstash-input-multirss.gemspec

logstash-plugin install logstash-input-multirss-[nº_version].gem

### Pipeline Example

You can see a example in https://github.com/felixramirezgarcia/logstash-input-multirss/blob/master/example-pipeline.conf

The difference between the attributes multi_feed and one_feed is that the multi_feed is the URI of the parent address where several rss (xml) are found. For the case where you want to explore only one of those links you can use the one_feed attribute. A visual example can be seen by visiting the following links:

Father (multi_feed) => http://rss.elmundo.es/rss/

Son (one_feed) => http://estaticos.elmundo.es/elmundo/rss/portada.xml

All the params are :

    1) multi_feed => [array] URI parent with more rss links inside , something like this: http://rss.elmundo.es/rss/  
    
    2) one_feed => [array] childs URIS with XML content inside , something like this: http://estaticos.elmundo.es/elmundo/rss/portada.xml 
    
    3) blacklist => [array] strings , links, text ... what you dont want explored
    
    4) Interval => [int] Set the Stoppable_sleep interval for the pipe
    
    5) keywords => [array] If you use this parameter will only compile those news that contain in any of its attributes a word from this array

## Documentation

Logstash provides infrastructure to automatically generate documentation for this plugin. We use the asciidoc format to write documentation so any comments in the source code will be first converted into asciidoc and then into html. All plugin documentation are placed under one [central location](http://www.elastic.co/guide/en/logstash/current/).

- For formatting code or config example, you can use the asciidoc `[source,ruby]` directive
- For more asciidoc formatting tips, see the excellent reference here https://github.com/elastic/docs#asciidoc-guide

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

# Running your unpublished Plugin in Logstash

## Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-filter-awesome", :path => "/your/local/logstash-filter-awesome"
```
- Install plugin
```sh
bin/logstash-plugin install --no-verify
```
- Run Logstash with your plugin
```sh
bin/logstash -e 'filter {awesome {}}'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

## Run in an installed Logstash

You can use the same method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-filter-awesome.gemspec
```
- Install the plugin from the Logstash home
```sh
bin/logstash-plugin install /your/local/plugin/logstash-filter-awesome.gem
```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.
