def env
  return ENV['AWS_ENV'] if ENV['AWS_ENV']
  [File.expand_path('~/'), "/etc"].each do |pre|
    %w(production uat developemnt).each {|e| return e.to_sym if File.exists?("#{pre}/#{e}") }
  end
  return :development
end

source :rubygems
gem 'rb-inotify'
gem 'rb-fsevent'
gem 'sinatra'
gem 'async_sinatra'
gem 'thin'
gem 'mailfactory'
gem 'sdsykes-ferret'
gem 'disqus'

gem 'tilt', :git => 'git://github.com/simulacre/tilt.git', :branch => 'bug-119_redcarpet_extensions'

if env == :development
  gem 'awestruct', :path => File.dirname(__FILE__) + "/../awestruct/"
  gem 'octopress-plugins', :require => 'octopress', :path => File.dirname(__FILE__) + "/../octopress/"
else
  gem 'awestruct', :git => 'git://github.com/simulacre/awestruct.git'
  gem 'octopress-plugins', :require => 'octopress', :git => 'git://github.com/simulacre/octopress.git'
end # env == :development
