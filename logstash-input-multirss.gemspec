Gem::Specification.new do |s|
  s.name          = 'logstash-input-multirss'
  s.version       = '1.1.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'Simple multi rss plugin'
  s.description   = 'This plugin get the feed content and works with : 
                      1) multi_feed => [array] URI parent with more rss links inside , something like this: http://rss.elmundo.es/rss/  
                      2) one_feed => [array] (optionally) childs URIS with XML content inside , something like this: http://estaticos.elmundo.es/elmundo/rss/portada.xml 
                      3) blacklist => [array] (optionally) strings , links, text ... what you dont want explored'
  s.homepage      = 'https://github.com/felixramirezgarcia/logstash-input-multirss'
  s.authors       = ['Felix R G']
  s.email         = 'felixramirezgarcia@correo.ugr.es'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core"
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'stud', '>= 0.0.22'
  s.add_development_dependency 'logstash-devutils', '>= 0.0.16'
  s.add_runtime_dependency "mechanize"
  s.add_runtime_dependency "nokogiri"
end
