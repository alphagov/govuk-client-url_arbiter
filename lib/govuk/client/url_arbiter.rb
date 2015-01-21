require "govuk/client/url_arbiter/version"
require "govuk/client/base"
require "govuk/client/errors"

require "plek"

module GOVUK
  module Client
    class URLArbiter
      include GOVUK::Client::Base

      # @param base_url [String] the base URL for the service (eg
      #   https://url-arbiter.example.com).  If unspecified, this will be
      #   looked up with {https://github.com/alphagov/plek Plek}.
      def initialize(base_url = nil)
        base_url ||= Plek.new.find('url-arbiter')
        super(base_url)
      end

      # Fetch details of a path
      #
      # @param path [String] the path to fetch
      # @return [Response, nil] Details of the reserved path, or +nil+ if the path wasn't found.
      # @raise [ArgumentError] when called with an invalid path.
      def path(path)
        check_path(path)

        Errors.ignoring_missing do
          get("/paths#{path}")
        end
      end

      # Reserve a path
      #
      # @param path [String] the path to reserve.
      # @param details [Hash] the request data to be sent to url-arbiter.
      # @return [Response] Details of the reserved path.
      # @raise [Errors::Conflict] if the path is already reserved by another app.
      # @raise [Errors::UnprocessableEntity] for any validation errors.
      # @raise [ArgumentError] when called with an invalid path.
      def reserve_path(path, details)
        check_path(path)
        put("/paths#{path}", details)
      end

      private

      def check_path(path)
        unless path && path.start_with?("/")
          raise ArgumentError, "Path must start with a '/'"
        end
      end
    end
  end
end
