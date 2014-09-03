require 'plek'

module GOVUK
  module Client
    module TestHelpers
      # Some test helpers for the url-arbiter client. This module is expected
      # to be mixed in to test classes.
      #
      # These rely on WebMock being available in the test suite.
      module URLArbiter
        URL_ARBITER_ENDPOINT = Plek.new.find('url-arbiter')

        # Stub out some sensible default url-arbiter responses.
        #
        # - all +GET+ requests for paths to return a 404.
        # - all +PUT+ requests to register a path return a 201 along with corresponding sample data.
        def stub_default_url_arbiter_responses
          stub_request(:get, %r[\A#{URL_ARBITER_ENDPOINT}/paths/]).
            to_return(:status => 404)

          stub_request(:put, %r[\A#{URL_ARBITER_ENDPOINT}/paths/]).to_return { |request|
            base_path = request.uri.path.sub(%r{\A/paths}, '')
            {:status => 201, :body => url_arbiter_data_for(base_path).to_json, :headers => {:content_type => "application/json"}}
          }
        end

        # Stub out calls to simulate webmock having registration information
        # for a given path.
        #
        # - +GET+ requests for the path return corresponding sample data.
        # - +PUT+ requests with a matching publishing_app return 200 along with the sample data.
        # - +PUT+ requests with a different publishing_app will return a 409 and include error data in the response.
        #
        # @param path [String] The path to be reserved.
        # @param publishing_app [String] The app the path should be registered to.
        def url_arbiter_has_registration_for(path, publishing_app)
          data = url_arbiter_data_for(path, "publishing_app" => publishing_app)
          error_data = data.merge({
            "errors" => {"base" => ["is already reserved by the #{publishing_app} application"]},
          })

          stub_request(:get, "#{URL_ARBITER_ENDPOINT}/paths#{path}").
            to_return(:status => 200, :body => data.to_json, :headers => {:content_type => "application/json"})

          stub_request(:put, "#{URL_ARBITER_ENDPOINT}/paths#{path}").
            to_return(:status => 409, :body => error_data.to_json, :headers => {:content_type => "application/json"})

          stub_request(:put, "#{URL_ARBITER_ENDPOINT}/paths#{path}").
            with(:body => {"publishing_app" => publishing_app}).
            to_return(:status => 200, :body => data.to_json, :headers => {:content_type => "application/json"})
        end

        # Generate sample url-arbiter data for a given path.
        #
        # @param path [String] The path being requested
        # @param override_attributes [Hash] Any specific attributes to override the defaults.
        def url_arbiter_data_for(path, override_attributes = {})
          now = Time.now.utc.iso8601
          {
            "path" => path,
            "publishing_app" => "foo-publisher",
            "created_at" => now,
            "updated_at" => now,
          }.merge(override_attributes)
        end
      end
    end
  end
end
