require "govuk/client/url_arbiter/version"
require "govuk/client/response"
require "govuk/client/errors"

require "rest-client"
require "multi_json"

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
      # @return [Response, nil] Details of the reserved path, or +nil+ if the path wasn't found.
      def path(path)
        get_json("/paths#{path}")
      end

      # Reserve a path
      #
      # @param path [String] the path to reserve.
      # @param details [Hash] the request data to be sent to url-arbiter.
      # @return [Response] Details of the reserved path.
      # @raise [Errors::Conflict] if the path is already reserved by another app.
      # @raise [Errors::UnprocessableEntity] for any validation errors.
      def reserve_path(path, details)
        put_json!("/paths#{path}", details)
      end

      private

      def get_json(path)
        response = RestClient.get(@base_url.merge(path).to_s)
        Response.new(response.code, response.body)
      rescue RestClient::ResourceNotFound, RestClient::Gone
        nil
      rescue RestClient::Exception => e
        raise Errors.create_for(e)
      end

      def put_json!(path, data)
        json = MultiJson.dump(data)
        response = RestClient.put(@base_url.merge(path).to_s, json, {:content_type => 'application/json'})
        Response.new(response.code, response.body)
      rescue RestClient::Exception => e
        raise Errors.create_for(e)
      end

    end
  end
end
