require 'rest-client'

module GOVUK
  module Client
    module Errors

      # Map rest-client exceptions onto our own exception hierarchy in order to
      # insulate users from the details of the http library we're using.
      #
      # @api private
      def self.create_for(restclient_exception)
        if restclient_exception.http_code
          HTTPError.new(restclient_exception.message)
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

      class HTTPError < BaseError; end

    end
  end
end
