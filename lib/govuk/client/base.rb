require 'faraday'
require 'faraday_middleware'

require 'govuk/client/response'
require 'govuk/client/errors'

module GOVUK
  module Client
    module Base

      # @param base_url [String,URI] the base URL for the service (eg
      #   https://foo.example.com).
      def initialize(base_url)
        @http_client = Faraday.new(base_url) do |conn|
          conn.request :json
          conn.response :raise_error
          conn.adapter Faraday.default_adapter
        end
      end

      protected

      def get(path)
        http_resp = @http_client.get(path)

        Response.new(http_resp.status, http_resp.body)
      rescue Faraday::ClientError => e
        raise Errors.create_for(e)
      end

      def put(path, data)
        http_resp = @http_client.put(path, data, :content_type => "application/json")

        Response.new(http_resp.status, http_resp.body)
      rescue Faraday::ClientError => e
        raise Errors.create_for(e)
      end
    end
  end
end

