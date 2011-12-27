class OAuthRequest

  attr_accessor :callback_url, :token, :secret

  def initialize(params = {})
    @callback_url = params[:callback_url]
  end

  def get_token
    request = consumer.get_request_token(:oauth_callback => @callback_url)
    @token  = request.token
    @secret = request.secret
    request
  end

  def validate_token(params)
    token    = params[:token]
    secret   = params[:secret]
    request = OAuth::RequestToken.new(consumer, token, secret)
    request.get_access_token(:oauth_verifier => params[:oauth_verifier])
  end

  def authorize_url
    consumer.authorize_url
  end

  private

  def consumer
    key = APP_CONFIG[:twitter][:consumer_key]
    secret = APP_CONFIG[:twitter][:consumer_secret]
    puts "Things"
    puts key, secret
    params = {
    :site => "http://api.twitter.com",
    :request_endpoint => "http://api.twitter.com",
    :sign_in => true
    }

    @consumer ||= OAuth::Consumer.new(key, secret, params)
  end

end