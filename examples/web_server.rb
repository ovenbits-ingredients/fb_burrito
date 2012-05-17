require 'sinatra'
require './lib/fb_burrito.rb'

get '/facebook' do
  user = FbBurrito.find_or_create_user!(:auth_code => params[:code])
  "access_token: #{user.fb_token}".strip
end
