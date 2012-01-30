require 'spec_helper'

module Benchwarmer
  describe API do

    it "requires a username" do
      #expect {Benchwarmer::API.new}.should raise_error(ArgumentError)
    end
    
    it "requires a password" do
      #expect {Benchwarmer::API.new}.should raise_error(ArgumentError)
    end

    it "also accepts config options" do
      #expect {Benchwarmer::API.new}.should_not raise_error(ArgumentError)
    end
    
    # TODO: Need a way to mock XMLRPC requests.

  end
end
