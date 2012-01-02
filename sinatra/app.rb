require 'json'
require 'eventmachine'
require "mailfactory"
require 'sinatra/async'

register Sinatra::Async

set :mailer, YAML.load_file(".mailer.yml") if File.exists?(".mailer.yml")

not_found do
  IO.read(settings.public_folder + '/404.html')
end

get "/search/?" do
  raise Sinatra::NotFound unless params[:q]
  call env.merge("PATH_INFO" => "/search/q/#{params[:q]}/")
end

get '/search/q/:query/?' do |q|
  content_type :json
  JSON.dump({ :query => q, :results => [] })
end

apost '/mail.json' do
  unless params['mootact']
    body(JSON.dump({:exception => {:general => "mootact param is required"}}))
    return
  end
  mootact = params['mootact']
  missing = %w(name email subject message).select {|p| !mootact.include?(p) || mootact[p].nil? || mootact[p].empty? }
  unless missing.empty?
    body(JSON.dump({:exception => {:general => "#{missing.join(", ")} #{(missing.count > 1 ? 'are' : 'is')} required"}}))
    return
  end

  ebody = <<-EBODY
    From: #{mootact['name']} (#{mootact['email']})
    Subject: #{mootact['subject']}

    #{mootact['message']}
  EBODY
  .gsub(/^    /, "")

  mail         = MailFactory.new
  mail.to      = settings.mailer[:to]
  mail.from    = settings.mailer[:from]
  mail.subject = mootact[:subject]
  mail.text    = ebody
  msg_config = {
     :domain   => settings.mailer[:domain],
     :host     => settings.mailer[:host],
     :port     => settings.mailer[:port],
     :starttls => settings.mailer[:tls],
     :from     => mail.from,
     :to       => mail.to,
     :content  => "#{mail.to_s}\r\n.\r\n",
     :verbose  => settings.mailer[:verbose]
  }
  msg_config[:auth] = settings.mailer[:auth] unless settings.mailer[:auth].nil? || (settings.mailer[:auth].respond_to?(:empty?) && settings.mailer[:auth].empty? )

  email = EM::Protocols::SmtpClient.send(msg_config)
  email.callback do
    body(JSON.dump({ "success" => 1 }))
  end
  email.errback do |e|
    puts "failed to send #{ebody}\n\n #{e}";
    body(JSON.dump({:exception => {:general => "#{e.message} (#{e.code})"}}))
  end
end # mail.json
