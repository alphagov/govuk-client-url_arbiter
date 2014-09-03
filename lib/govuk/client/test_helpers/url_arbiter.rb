require 'plek'

module GOVUK
  module Client
    module TestHelpers
      module URLArbiter
        URL_ARBITER_ENDPOINT = Plek.new.find('url-arbiter')

        def stub_default_url_arbiter_responses
          stub_request(:get, %r[\A#{URL_ARBITER_ENDPOINT}/paths/]).
            to_return(:status => 404)

          stub_request(:put, %r[\A#{URL_ARBITER_ENDPOINT}/paths/]).to_return { |request|
            base_path = request.uri.path.sub(%r{\A/paths}, '')
            {:status => 201, :body => url_arbiter_data_for(base_path).to_json, :headers => {:content_type => "application/json"}}
          }
        end

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
