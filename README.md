# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

# Developing

## Install

You can test it installing in a logstash service or container with the plugin utility :

logstash-plugin install logstash-input-multirss

or you can use other installation type (installing the gem) from https://rubygems.org/gems/logstash-input-multirss , or build it yuouself in a logstash service or container with :

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

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.


## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.

