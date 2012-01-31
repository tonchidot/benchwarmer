module Benchwarmer
  class API
    # Blank Slate
    instance_methods.each do |m|
      undef_method m unless m.to_s =~ /^__|object_id|method_missing|respond_to?|to_s|inspect/
    end
    
    # Benchmark Email API Documentation: http://www.benchmarkemail.com/API/Library
    BENCHMARK_API_VERSION = "1.0"
    DEFAULTS = {
      :api_version => BENCHMARK_API_VERSION,
      :secure => false,
      :timeout => nil
    }

    # Initialize with an API token and config options
    def initialize(api_token, config = {})
      opts = DEFAULTS.merge(config).freeze
      @api_client = XMLRPC::Client.new2("#{opts[:secure] ? 'https' : 'http'}://api.benchmarkemail.com/#{opts[:api_version]}/", nil, opts[:timeout])
      @api_token = api_token
    end

    def method_missing(api_method, *args) # :nodoc:
      @api_client.call(camelize_api_method_name(api_method.to_s), @api_token, *args)
    rescue XMLRPC::FaultException => error
      super if error.message.include?("unsupported method called:")
      raise APIError.new(error)
    end
    
    def respond_to?(api_method) # :nodoc:
      @api_client.call(api_method, @api_token)
    rescue XMLRPC::FaultException => error
      error.message.include?("unsupported method called:") ? false : true
    end
    
    # Token management methods
    #
    # Each time you "login", a new token is generated with access to the B.E. API.
    # This means that you should store a single token and use it over and over,
    # preventing a build-up of tokens.
    #
    # Our hope is that in the future B.E. will make the following changes
    # with regard to API access tokens:
    #
    # - Provide an interface for account holders to manage their API tokens.
    # - Remove the ability to login with username, password.
    # - Add OAuth2 so that the "access_token" can be used in the same way that
    #   "API tokens" are currently used.
    #
    # In other words, make it more like Mailchimp.
    
    def self.login(username, password, config = {})
      api_client(config)
      @api_client.call('login', username, password)
    end
    
    # Get a list of the tokens
    def self.token_get(username, password, config = {})
      api_client(config)
      @api_client.call("tokenGet", username, password)
    end

    # Add a new token (generated randomly)
    def self.token_add(username, password, config = {})
      api_client(config)
      @api_client.call("tokenAdd", username, password, SecureRandom.urlsafe_base64(20))
    end

    # Delete an existing token
    def self.token_delete(username, password, token, config = {})
      api_client(config)
      @api_client.call("tokenDelete", username, password, token)
    end
    
    private
    
    def self.api_client(options)
      opts = DEFAULTS.merge(options).freeze
      @api_client = XMLRPC::Client.new2("#{opts[:secure] ? 'https' : 'http'}://api.benchmarkemail.com/#{opts[:api_version]}/", nil, opts[:timeout])
    end
    
    def camelize_api_method_name(str)
      str.to_s[0].chr.downcase + str.gsub(/(?:^|_)(.)/) { $1.upcase }[1..str.size]
    end
    
  end
  
  class APIError < StandardError
    def initialize(error)
      super("(#{error.faultCode}) #{error.message}")
    end
  end

end