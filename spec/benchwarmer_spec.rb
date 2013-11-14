require 'spec_helper'

module Benchwarmer
  describe API do

    it "requires an API token on initialization" do
      expect {Benchwarmer::API.new}.should raise_error(ArgumentError)
    end

    it "also accepts config options on initialization" do
      expect {Benchwarmer::API.new('api_token', {:secure => true})}.should_not raise_error(ArgumentError)
    end

    it "requires a username and password for class methods" do
      expect {Benchwarmer::API.login('password')}.should raise_error(ArgumentError)
      expect {Benchwarmer::API.token_get('password')}.should raise_error(ArgumentError)
      expect {Benchwarmer::API.token_add('password')}.should raise_error(ArgumentError)
      expect {Benchwarmer::API.token_delete('password')}.should raise_error(ArgumentError)
    end

    it "requires a token to delete" do
      expect {Benchwarmer::API.token_delete('username', 'password')}.should raise_error(ArgumentError)
    end

    it "also accepts config options on class methods" do
      expect {Benchwarmer::API.login('username', 'password', {:secure => true})}.should_not raise_error(ArgumentError)
      expect {Benchwarmer::API.token_get('username', 'password', {:secure => true})}.should_not raise_error(ArgumentError)
      expect {Benchwarmer::API.token_add('username', 'password', {:secure => true})}.should_not raise_error(ArgumentError)
      expect {Benchwarmer::API.token_delete('username', 'password', 'token', {:secure => true})}.should_not raise_error(ArgumentError)
    end

    describe 'Accept-Encoding header' do
      shared_examples_for 'set Accept-Encoding: identity' do
        it { subject.http_header_extra["accept-encoding"].should eq "identity" }
      end

      it_behaves_like 'set Accept-Encoding: identity' do
        subject { Benchwarmer::API.new('api_token', {:secure => true}).instance_eval { @api_client } }
      end

      it_behaves_like 'set Accept-Encoding: identity' do
        subject { Benchwarmer::API.api_client({}) }
      end
    end

    # TODO: Need a way to mock XMLRPC requests.

  end
end
