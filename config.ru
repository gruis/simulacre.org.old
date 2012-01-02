#!/usr/bin/env ruby
require "awestruct"
require 'sinatra/base'
require "fssm"

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

  htaccess = IO.read('.htaccess').each_line.map(&:strip)
  ['RewriteEngine on', 
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
  File.open(".htaccess", "w") { |f| f.puts htaccess.join("\n") }
  awe.generate( settings.environment.to_s, awe.site.base_url, "http://localhost:#{settings.port}", force=false )

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


  if settings.environment == :development
    Thread.new do
      monitor       = FSSM::Monitor.new
      call_generate = lambda do |base, relative|
        base = File::expand_path(base)
        base += File::SEPARATOR if base[base.length - 1] != File::SEPARATOR
        return if base.length < awc.input_dir.length or awc.input_dir != base[0..awc.input_dir.length]
        path = base + relative
        path = path[awc.input_dir.length..path.length]
        return if path =~ /^(_site|_tmp|\.git|\.gitignore|\.sass-cache|\.|\.\.).*/  || path =~ /.*(~|\.(swp|bak|tmp))$/ || "./#{path}" =~ /^#{awe.site.sinatra_logdir}\/.*/

        puts "Triggered regeneration: #{path}"
        awe.generate( settings.environment.to_s, awe.site.base_url, "http://localhost:#{settings.port}", force=false )
        puts "Done"
        if relative == '.'
          monitor.file(base) do
            update &call_generate
            create &call_generate
          end
        end
      end # base, relative
      monitor.path(awc.input_dir) do
        update &call_generate
        create &call_generate
      end

      monitor.run
    end # Thread.new
  end # settings.environment == :development

end # class::Awestruct::Sinatra < Sinatra::Base

Awestruct::Sinatra.run!
