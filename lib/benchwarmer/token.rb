module Benchwarmer
  module Token
    
    # Get a list of the tokens
    def token_get
      @api_client.call("tokenGet", @username, @password)
    end
    
    # Add a new token (generated randomly)
    def token_add
      @api_client.call("tokenAdd", @username, @password, SecureRandom.urlsafe_base64(20))
      # TODO: Do we need to replace the @api_token variable?
    end
    
    # Delete an existing token
    def token_delete(token)
      @api_client.call("tokenDelete", @username, @password, token)
      # TODO: Do we need to replace the @api_token variable?
    end
    
  end
end