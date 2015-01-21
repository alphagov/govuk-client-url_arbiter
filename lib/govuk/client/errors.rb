require 'faraday'

require 'govuk/client/response'

module GOVUK
  module Client
    module Errors

      # Map rest-client exceptions onto our own exception hierarchy in order to
      # insulate users from the details of the HTTP library we're using.
      #
      # @api private
      def self.create_for(faraday_exception)
        if faraday_exception.response
          case faraday_exception.response[:status]
          when 409
            Conflict.new(faraday_exception)
          when 422
            UnprocessableEntity.new(faraday_exception)
          else
            HTTPError.new(faraday_exception)
          end
        else
          case faraday_exception
          when Faraday::TimeoutError
            Timeout.new(faraday_exception.message)
          else
            BaseError.new(faraday_exception.message)
          end
        end
      end

      def self.ignoring_missing
        yield
      rescue HTTPError => e
        raise unless [404, 410].include? e.code
        nil
      end

      class BaseError < StandardError; end

      class Timeout < BaseError; end

      class HTTPError < BaseError
        # @api private
        def initialize(faraday_exception)
          super(faraday_exception.message)
          @wrapped_exception = faraday_exception
        end

        # @return [Integer] The HTTP status code associated with this exception.
        def code
          @wrapped_exception.response[:status]
        end

        # @return [Response] The response that triggered this exception.
        def response
          @response ||= Response.new(code, @wrapped_exception.response[:body])
        end
      end

      class Conflict < HTTPError; end

      class UnprocessableEntity < HTTPError; end

    end
  end
end
