module Benchwarmer
  class API
    # Blank Slate
    instance_methods.each do |m|
      undef_method m unless m.to_s =~ /^__|object_id|method_missing|respond_to?|to_s|inspect/
    end
    
    # Benchmark Email API Documentation: http://www.benchmarkemail.com/API/Library
    BENCHMARK_API_VERSION = "1.0"

    # Initialize with an API key and config options
    def initialize(username, password, config = {})
      raise ArgumentError.new('Please enter your Benchmark Email account username.') unless username
      defaults = {
        :api_version        => BENCHMARK_API_VERSION,
        :secure             => false,
        :timeout            => nil
      }
      @config = defaults.merge(config).freeze
      protocol = @config[:secure] ? 'https' : 'http'
      @api_client = XMLRPC::Client.new2("#{protocol}://api.benchmarkemail.com/#{@config[:api_version]}/", nil, @config[:timeout])
      login(username, password)
    end
    
    def login(username, password)
      @api_token = @api_client.call("login", username, password)
    rescue XMLRPC::FaultException => error
      raise APIError.new(error)
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
    
    private

    def camelize_api_method_name(str)
      str.to_s[0].chr.downcase + str.gsub(/(?:^|_)(.)/) { $1.upcase }[1..str.size]
    end
  end
  
  class APIError < StandardError
    def initialize(error)
      super("#{error.message}")
    end
  end

end