class SessionsController < ApplicationController

  include Twitter::AuthenticationHelpers

  def new
  end

  def create
    logger.info callback_url
    request = oauth_consumer.get_request_token(:oauth_callback => callback_url )
    session[:request_token] = request.token
    session[:request_secret] = request.secret
    redirect_to request.authorize_url
  end

  def destroy
  end

  def callback
    o = oauth_consumer
    t = session[:request_token]
    s = session[:request_secret]   
    request = OAuth::RequestToken.new(o,t,s)
    access_token = request.get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:access_token] = access_token.token
    session[:access_secret] = access_token.secret
    user = client.verify_credentials
    sign_in(user)
    redirect_back_or root_path  
end

  private

  def oauth_consumer
    key = APP_CONFIG[:twitter][:consumer_key]
    secret = APP_CONFIG[:twitter][:consumer_secret]
    params = {
    :site => "http://api.twitter.com",
    :request_endpoint => "http://app.twitter.com",
    :sign_in => true
    }

    @oauth_consumer ||= OAuth::Consumer.new(key, secret, params)
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
