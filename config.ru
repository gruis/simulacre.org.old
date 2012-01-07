#!/usr/bin/env ruby
# encoding: UTF-8
require "bundler/setup"
require "awestruct"
require 'sinatra/base'
require "fssm"

class Awestruct::Sinatra < Sinatra::Base
  set :environment, (lambda do
    return ENV['AWS_ENV'] if ENV['AWS_ENV']
    [File.expand_path('~/'), "/etc"].each do |pre|
      %w(production uat developemnt).each {|e| return e if File.exists?("#{pre}/#{e}") }
    end 
    return 'development'
  end.call.to_sym)
  awc = Awestruct::Config.new(Dir.pwd)
  awe = Awestruct::Engine.new(awc)
  awe.generate( settings.environment.to_s, awe.site.base_url, "http://localhost:#{settings.port}", force=false )

  enable :static, :logging
  disable :run

  set :awe, awe
  set :server, %w{ rainbows thin webrick }
  set :bind, awe.site.bind || '127.0.0.1'
  set :port, awe.site.port || 4242
  set :root,  (awe.site.sinatra_root ||= File.join(File.dirname(__FILE__), "sinatra"))
  set :public_folder, awc.output_dir
  set :app_file, (awe.site.sinatra_app ||= File.join(settings.root, "app.rb"))

  if settings.environment != :development
    awe.site.sinatra_logdir ||= File.join(awe.site.sinatra_root, 'log')
    FileUtils.mkdir_p(awe.site.sinatra_logdir)
    log      = File.new(File.join(awe.site.sinatra_logdir, "sinatra.log"), "a+") 
    log.sync = true
    $stdout.reopen(log)
    $stderr.reopen(log)
  end # settings.environment == :development

  htaccess = IO.read('.htaccess').each_line.map(&:strip)
  ohta     = htaccess.clone
  ['RewriteEngine on', 
   'RewriteRule wordpress/photos/album/(.*) /ee/i/simIndigo/album/$1 [R,L]',
   'RewriteRule wordpress/photos/tags/(.*) /ee/i/simIndigo/flickr/tags/$1 [R,L]',
   'RewriteRule wordpress/tags/(.*) /ee/i/simIndigo/flickr/tags/$1 [R,L]',
   'RewriteCond %{REQUEST_URI} !=/feed/',
   'RewriteCond %{REQUEST_URI} !=/feed/index.html',
   'RewriteCond %{REQUEST_FILENAME} !-f', 
   'RewriteCond %{REQUEST_FILENAME}/index.html !-f', 
   'RewriteRule ^(.*)$ http://localhost:4242/$1 [P,L]']
  .inject(0) do |idx, line|
    if (nidx = htaccess.index(line))
      htaccess.delete_at(nidx)
    end
    htaccess.insert(idx, line)
    idx + 1
  end # idx, line
  if ohta != htaccess
    File.open(".htaccess", "w") { |f| f.puts htaccess.join("\n") }
    awe.generate( settings.environment.to_s, awe.site.base_url, "http://localhost:#{settings.port}", force=false )
  end # ohta != htaccess



  get '/?' do
    IO.read(settings.public_folder + "/index.html")
  end

  awe.site.sinatra_app = File.join(settings.root, "app.rb") unless awe.site.sinatra_app
  instance_eval(IO.read(awe.site.sinatra_app), awe.site.sinatra_app, 1) if File.exists?(awe.site.sinatra_app)


  if settings.environment == :development
    Thread.new do
      monitor       = FSSM::Monitor.new
      call_generate = lambda do |base, relative|
        return if relative =~ /^(_site|_tmp|\.git|\.gitignore|\.sass-cache|\.|\.\.).*/  
        return if relative =~ /.*(~|\.(swp|bak|tmp))$/ 
        return if awc.ignore.include?(relative)
        puts "Triggered regeneration: #{File.join(base, relative)}"
        awe.generate(settings.environment.to_s, awe.site.base_url, "http://localhost:#{settings.port}", force=false)
        puts "Done"
      end # base, relative
      monitor.path(awc.input_dir) do
        update &call_generate
        create &call_generate
      end
      monitor.run
    end # Thread.new
  end # settings.environment == :development

end # class::Awestruct::Sinatra < Sinatra::Base


$0 == __FILE__ ? Awestruct::Sinatra.run! : (run Awestruct::Sinatra)
