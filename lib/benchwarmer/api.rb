module Benchwarmer
  class API
    # Blank Slate
    instance_methods.each do |m|
      undef_method m unless m.to_s =~ /^__|object_id|method_missing|respond_to?|to_s|inspect/
    end
    
    # Benchmark Email API Documentation: http://www.mailchimp.com/api/1.3/
    BENCHMARK_API_VERSION = "1.0"

    # Initialize with an API key and config options
    def initialize(username, password, config = {})
      # TODO: Raise an error if there is no username or password
      defaults = {
        :api_version        => BENCHMARK_API_VERSION,
        :autologin          => true,
        :secure             => false,
        :timeout            => nil
      }
      @config = defaults.merge(config).freeze
      protocol = @config[:secure] ? 'https' : 'http'
      @apiClient = XMLRPC::Client.new2("#{protocol}://api.benchmarkemail.com/#{@config[:api_version]}/", nil, @config[:timeout])
      @api_token = @apiClient.call("login", username, password)
      begin
      rescue
         puts "*** Benchmark Email API Error ***"
         puts "Connection: #{@apiClient}"
         puts "Login: #{username}"
         puts "Password: #{password}"
      end
    end

    def method_missing(api_method, *args) # :nodoc:
      @apiClient.call(camelize_api_method_name(api_method.to_s), @api_token, *args)
    rescue XMLRPC::FaultException => error
      super if error.faultCode == -32601
      raise APIError.new(error)
    end
    
    def respond_to?(api_method) # :nodoc:
      @apiClient.call(api_method, @api_token)
    rescue XMLRPC::FaultException => error
      error.faultCode == -32601 ? false : true 
    end
    
    private

    def camelize_api_method_name(str)
      str.to_s[0].chr.downcase + str.gsub(/(?:^|_)(.)/) { $1.upcase }[1..str.size]
    end
  end
  
  class APIError < StandardError
    def initialize(error)
      super("<#{error.faultCode}> #{error.message}")
    end
  end

end