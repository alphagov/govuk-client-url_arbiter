require "govuk/client/url_arbiter/version"

require "rest-client"
require "multi_json"
require "govuk/client/errors"

module GOVUK
  module Client
    class URLArbiter

      def initialize(base_url)
        @base_url = URI.parse(base_url)
      end

      def path(path)
        get_json("/paths#{path}")
      end

      private

      def get_json(path)
        response = RestClient.get(@base_url.merge(path).to_s)
        MultiJson.load(response)
      rescue RestClient::ResourceNotFound, RestClient::Gone
        nil
      rescue RestClient::Exception => e
        raise Errors.create_for(e)
      end

    end
  end
end
