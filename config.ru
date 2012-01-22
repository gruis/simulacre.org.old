#!/usr/bin/env ruby
# encoding: UTF-8
require "bundler/setup"
require "awestruct"
require 'sinatra/base'
require "eventmachine"
require "directory_watcher"
require "rbconfig"

EM.epoll
EM.kqueue = EM.kqueue? if Config::CONFIG['host_os'] =~ /darwin/ 

class Awestruct::Sinatra < Sinatra::Base
  class << self
    def generating?; @generating end
    def generate(force = false)
      return nil if generating?
      @generating = true
      respond_to?(:dw) && dw.stop
      respond_to?(:awe) && awe.generate(environment.to_s, awe.site.base_url, "http://localhost:#{port}", force)
      respond_to?(:dw) && dw.start
      post_generate
      @generating = false
      true
    end 

    def post_generate(&blk)
      (@generate_cbs ||= [])
      if block_given?
        @generated && blk.call
        @generate_cbs.unshift blk
      else
        @generated = true
        @generate_cbs.each { |cb| cb.call }
        @generated = @generate_cbs.empty? 
      end 
    end # post_generate(&blk
  end 

  enable :static, :logging
  disable :run

  awc = Awestruct::Config.new(Dir.pwd)
  set :awe, awe = Awestruct::Engine.new(awc)
  generate(settings.environment == :production || ARGV[0] == "regenerate")

  set :server, %w{ thin webrick }
  set :bind, awe.site.bind || '127.0.0.1'
  set :port, awe.site.port || 4242
  set :root,  (awe.site.sinatra_root ||= File.join(File.dirname(__FILE__), "sinatra"))
  set :public_folder, awc.output_dir
  set :app_file, (awe.site.sinatra_app ||= File.join(settings.root, "app.rb"))
  set :authkey, IO.read(File.expand_path("~/.ssh/id_rsa.pub")).split(" ")[1] 
  awe.site.sinatra_app = File.join(settings.root, "app.rb") unless awe.site.sinatra_app
  File.open("#{awe.site.output_dir}/.htaccess", "w") { |f| f.puts Tilt.new('_htaccess.erb').render(settings) }

  if settings.environment != :development
    awe.site.sinatra_logdir ||= File.join(awe.site.sinatra_root, 'log')
    FileUtils.mkdir_p(awe.site.sinatra_logdir)
    log      = File.new(File.join(awe.site.sinatra_logdir, "sinatra.log"), "a+") 
    log.sync = true
    $stdout.reopen(log)
    $stderr.reopen(log)
  end # settings.environment == :development

  configure do
    EM.next_tick do
      slice_from = awc.input_dir.length
      awc.ignore.push("_htaccess.erb")
      set :dw, DirectoryWatcher.new(awc.input_dir, :interval => 0.5, :glob => '**/*', :pre_load => true, :scanner => :em)
      settings.dw.add_observer do |*events| 
        relatives = events.map{|e| e.path[slice_from..-1]}
        if relatives.include?("_htaccess.erb")
          File.open("#{awe.site.output_dir}/.htaccess", "w") { |f| f.puts Tilt.new('_htaccess.erb').render(settings) }
        end
        generate unless relatives.reject{ |r| awc.ignore.include?(r) || r =~ /.*(~|\.(swp|bak|tmp))$/ || r =~ /^(_site|_tmp|\.git|\.gitignore|\.sass-cache|\.|\.\.).*/ }.empty?
      end
      dw.start
    end 
  end

  instance_eval(IO.read(awe.site.sinatra_app), awe.site.sinatra_app, 1) if File.exists?(awe.site.sinatra_app)
end # class::Awestruct::Sinatra < Sinatra::Base

at_exit do
  if $!
    open(File.expand_path("../sinatra/log/crash.log", __FILE__), "a") do |clog|
      e = {
        :timestamp => Time.now,
        :error     => $!.message,
        :trace     => $!.backtrace
      }
      YAML.dump(e, clog)
    end
  end
end

$0 == __FILE__ ? Awestruct::Sinatra.run! : (run Awestruct::Sinatra)
