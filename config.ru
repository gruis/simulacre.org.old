require "awestruct"
require 'sinatra/base'

class Awestruct::Sinatra < Sinatra::Base
  set :environment, :development

  awc = Awestruct::Config.new(Dir.pwd)
  awe = Awestruct::Engine.new(awc)
  awe.generate( settings.environment.to_s, awe.site.base_url, "http://localhost:#{settings.port}", force=false )

  enable :static, :logging
  disable :run

  set :awe, awe
  set :bind, awe.site.bind || '0.0.0.0'
  set :port, awe.site.port || 4242
  set :root,  (awe.site.sinatra_root ||= File.join(File.dirname(__FILE__), "sinatra"))
  set :public_folder, awc.output_dir
  set :app_file, (awe.site.sinatra_app ||= File.join(settings.root, "app.rb"))
 
  awe.site.sinatra_logdir ||= File.join(awe.site.sinatra_root, 'log')
  FileUtils.mkdir_p(awe.site.sinatra_logdir)
  log      = File.new(File.join(awe.site.sinatra_logdir, "sinatra.log"), "a+") 
  log.sync = true
  $stdout.reopen(log)
  $stderr.reopen(log)

  get '/?' do
    IO.read(settings.public_folder + "/index.html")
  end

  awe.site.sinatra_app = File.join(settings.root, "app.rb") unless awe.site.sinatra_app
  instance_eval(IO.read(awe.site.sinatra_app), awe.site.sinatra_app, 1) if File.exists?(awe.site.sinatra_app)
end

Awestruct::Sinatra.run!
