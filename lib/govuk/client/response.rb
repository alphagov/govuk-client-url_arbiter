require 'delegate'
require 'multi_json'

module GOVUK
  module Client

    # An API response.  This delegates to a hash containing the parsed
    # response body.  It also has methods for accessing the response metadata.
    #
    # This is expected to represent a HTTP response with a JSON body, but in
    # the case where the body is not JSON (eg for some error responses), this
    # will delegate to an empty Hash.  The raw response can then be accessed
    # via the {#raw_body} accessor.
    class Response < SimpleDelegator

      # @param code [Integer] The http status code
      # @param body_str [String] The JSON encoded response body.
      def initialize(code, body_str)
        @code = code
        @raw_body = body_str
        super(MultiJson.load(@raw_body))
      rescue MultiJson::ParseError
        # Delegate to empty hash so that this instance still quacks like a hash.
        super({})
      end

      # @return [Integer] The HTTP response code
      attr_reader :code

      # @return [String] The raw HTTP response body
      attr_reader :raw_body
    end
  end
end
