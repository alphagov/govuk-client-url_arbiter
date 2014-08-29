require "govuk/client/url_arbiter/version"

require "rest-client"
require "multi_json"
require "govuk/client/errors"

module GOVUK
  module Client
    class URLArbiter

      # @param base_url [String] the base URL for the service (eg http://url-arbiter.example.com).
      def initialize(base_url)
        @base_url = URI.parse(base_url)
      end

      # Fetch details of a path
      #
      # @param path [String] the path to fetch
      # @return [Hash, nil] The response parsed into a hash, or nil if the path wasn't found.
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
