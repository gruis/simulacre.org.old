require 'json'
require 'eventmachine'
require "mailfactory"
require 'sinatra/async'
require "ferret"

register Sinatra::Async

File.expand_path("~/.mailer.simulacre.org.yml").tap do |mc|
  if File.exists?(mc)
    set :mailer, YAML.load_file(mc)
  else
    warn "mailer configuration #{mc} does not exists"
  end
end

set :sindex, Ferret::Index::Index.new

post_generate do
  settings.sindex =  Ferret::Index::Index.new
  settings.awe.site.pages.each do |page|
    next unless File.extname(page.output_path) == ".html" && (page.title || page.demo)
    settings.sindex << {
      :title   => page.title || "#{page.demo[:title]} - #{page.demo[:subtitle]}",
      :url     => page.url,
      :summary => page.summary,
      :tags    => page.tags && page.tags.join(", "),
      :date    => page.date && page.date.strftime('%Y-%m-%d'),
      :content => page.content
    }
  end
  $stderr.puts("indexed #{awe.site.pages.count} pages")
end # post_generate

not_found do
  IO.read(settings.public_folder + '/404.html')
end

get '/?' do
  IO.read(settings.public_folder + "/index.html")
end

get "/search/?" do
  raise Sinatra::NotFound unless params[:q]
  call env.merge("PATH_INFO" => "/search/q/#{params[:q]}/")
end

get '/search/q/:query/?' do |q|
  results = {}
  settings.sindex.search_each(%Q{*: #{q} }) do |id, score|
    page = settings.sindex[id]
    results[page[:url]] = { :url     => page[:url],
                            :title   => page[:title],
                            :date    => page[:date],
                            :tags    => page[:tags],
                            :summary => page[:summary].force_encoding("UTF-8"),
                            :score   => score}
  end # id, score

  # @todo render as JSON if request was JSON, HTML otherwise.
  page         = settings.awe.load_page("_search.html.haml", :relative_path => '_search.html.haml')
  page.query   = q
  page.results = results
  settings.awe.send(:render_page, page)
end # /search/q/:query/?

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
