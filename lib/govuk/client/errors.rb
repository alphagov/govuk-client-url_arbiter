require 'rest-client'

require 'govuk/client/response'

module GOVUK
  module Client
    module Errors

      # Map rest-client exceptions onto our own exception hierarchy in order to
      # insulate users from the details of the HTTP library we're using.
      #
      # @api private
      def self.create_for(restclient_exception)
        if restclient_exception.http_code
          case restclient_exception.http_code
          when 409
            Conflict.new(restclient_exception)
          when 422
            UnprocessableEntity.new(restclient_exception)
          else
            HTTPError.new(restclient_exception)
          end
        else
          case restclient_exception
          when RestClient::RequestTimeout
            Timeout.new(restclient_exception.message)
          else
            BaseError.new(restclient_exception.message)
          end
        end
      end

      class BaseError < StandardError; end

      class Timeout < BaseError; end

      class InvalidPath < BaseError; end

      class HTTPError < BaseError
        # @api private
        def initialize(restclient_exception)
          super(restclient_exception.message)
          @wrapped_exception = restclient_exception
        end

        # @return [Integer] The HTTP status code associated with this exception.
        def code
          @wrapped_exception.http_code
        end

        # @return [Response] The response that triggered this exception.
        def response
          @response ||= Response.new(code, @wrapped_exception.response)
        end
      end

      class Conflict < HTTPError; end

      class UnprocessableEntity < HTTPError; end

    end
  end
end
