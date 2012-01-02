require "json"

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

post '/mail.json' do
  raise NotImplementedError
end
