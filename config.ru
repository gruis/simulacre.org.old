#!/usr/bin/env ruby
# encoding: UTF-8
require "bundler/setup"
require "awestruct"
require 'sinatra/base'
require "fssm"


class Awestruct::Sinatra < Sinatra::Base
  awc = Awestruct::Config.new(Dir.pwd)
  awe = Awestruct::Engine.new(awc)
  awe.generate( settings.environment.to_s, awe.site.base_url, "http://localhost:#{settings.port}", force=(settings.environment == :production) )
  File.open("#{awe.site.output_dir}/.htaccess", "w") { |f| f.puts Tilt.new('_htaccess.erb').render(settings) }

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
