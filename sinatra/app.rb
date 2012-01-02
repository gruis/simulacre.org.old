require "json"

get "/search/?" do
  call env.merge("PATH_INFO" => "/search/q/#{params[:q]}/")
end

get '/search/q/:query/?' do |q|
  content_type :json
  JSON.dump({ :query => q, :results => [] })
end
