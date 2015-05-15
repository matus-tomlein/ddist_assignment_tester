begin
  gem 'colored'
  gem 'json'
  gem 'sinatra'
  gem 'macaddr'
  gem 'levenshtein-jruby'
rescue Gem::LoadError => e
  puts e.message
  puts "Install it using 'bin/jruby-1.7.19/bin/jruby -S gem install GEM_NAME'"
  exit
end
