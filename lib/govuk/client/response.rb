require 'delegate'
require 'multi_json'

module GOVUK
  module Client

    # An API response.  This delegates to a hash containing the parsed
    # response body.  It also has methods for accessing the response metadata.
    class Response < SimpleDelegator

      # @param code [Integer] The http status code
      # @param body_str [String] The JSON encoded response body.
      def initialize(code, body_str)
        @code = code
        @payload = MultiJson.load(body_str)
        super(@payload)
      end

      # @return [Integer] The HTTP response code
      attr_reader :code
    end
  end
end
