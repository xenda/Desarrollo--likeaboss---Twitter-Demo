require 'oauth_request'

class SessionsController < ApplicationController

  def new
    @user = client.verify_credentials if session[:access_token]
  end

  def create
    request = OAuthRequest.new(:callback_url => callback_url)
    request_token = request.get_token

    session[:request_token] = request_token.token
    session[:request_secret] = request_token.secret

    redirect_to request_token.authorize_url
  end

  def destroy
    session[:access_token]  = nil
    session[:access_secret] = nil
    redirect_to root_path
  end

  def callback

    token_params = {
      :token  => session[:request_token],
      :secret => session[:request_secret]    
    }.merge! params

    request  = OAuthRequest.new
    access   = request.validate_token(token_params)

    session[:access_token] = access.token
    session[:access_secret] = access.secret

    @user = client.verify_credentials
    sign_in(@user)
    redirect_to root_path 
     
end

  private

  def sign_in(user)
    session[:screen_name] = user.screen_name if user
  end

  def client
    Twitter.configure do |config|
      config.consumer_key = APP_CONFIG[:twitter][:consumer_key]
      config.consumer_secret = APP_CONFIG[:twitter][:consumer_secret]
      config.oauth_token = session[:access_token]
      config.oauth_token_secret = session[:access_secret]  
    end
    @client ||= Twitter::Client.new
  end

end
