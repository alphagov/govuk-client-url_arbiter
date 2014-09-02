
require "govuk/client/url_arbiter"

describe GOVUK::Client::URLArbiter do

  let(:base_url) { "http://url-arbiter.example.com" }
  let(:client) { GOVUK::Client::URLArbiter.new(base_url) }

  describe "fetching details of a reserved path" do
    it "should return the details as a hash" do
      json_data = <<-EOT
{
  "path": "/foo/bar",
  "publishing_app": "foo_publisher",
  "created_at": "2014-08-13T13:25:17.184Z",
  "updated_at": "2014-08-13T13:25:17.184Z"
}
      EOT
      stub_request(:get, "#{base_url}/paths/foo/bar").
        to_return(:status => 200, :body => json_data, :headers => {'Content-Type' => 'application/json'})

      response = client.path("/foo/bar")
      expect(response).to be_a(GOVUK::Client::Response)
      expect(response).to eq({
        "path" => "/foo/bar",
        "publishing_app" => "foo_publisher",
        "created_at" => "2014-08-13T13:25:17.184Z",
        "updated_at" => "2014-08-13T13:25:17.184Z"
      })
    end

    it "should return nil on 404" do
      stub_request(:get, "#{base_url}/paths/foo/bar").
        to_return(:status => 404)

      response = client.path("/foo/bar")
      expect(response).to be_nil
    end

    it "should return nil on 410" do
      stub_request(:get, "#{base_url}/paths/foo/bar").
        to_return(:status => 410)

      response = client.path("/foo/bar")
      expect(response).to be_nil
    end

    it "should raise an exception on other HTTP errors" do
      stub_request(:get, "#{base_url}/paths/foo/bar").
        to_return(:status => 500, :body => "Computer says no!")

      expect {
        response = client.path("/foo/bar")
      }.to raise_error(GOVUK::Client::Errors::HTTPError)
    end

    it "should raise a timeout exception on timeouts" do
      stub_request(:get, "#{base_url}/paths/foo/bar").to_timeout

      expect {
        response = client.path("/foo/bar")
      }.to raise_error(GOVUK::Client::Errors::Timeout)

    end
  end

  describe "reserving a path" do
    it "should reserve the path and return the details as a hash" do
      json_data = <<-EOT
{
  "path": "/foo/bar",
  "publishing_app": "foo_publisher",
  "created_at": "2014-08-13T13:25:17.184Z",
  "updated_at": "2014-08-13T13:25:17.184Z"
}
      EOT
      stub_request(:put, "#{base_url}/paths/foo/bar").
        with(:body => {"publishing_app" => "foo_publisher"}, :headers => {"Content-Type" => 'application/json'}).
        to_return(:status => 201, :body => json_data, :headers => {'Content-Type' => 'application/json'})

      response = client.reserve_path("/foo/bar", "publishing_app" => "foo_publisher")
      expect(response).to be_a(GOVUK::Client::Response)
      expect(response.code).to eq(201)
      expect(response).to eq({
        "path" => "/foo/bar",
        "publishing_app" => "foo_publisher",
        "created_at" => "2014-08-13T13:25:17.184Z",
        "updated_at" => "2014-08-13T13:25:17.184Z"
      })
    end

    it "should raise a conflict error if the path is already reserved" do
      json_data = <<-EOT
{
  "path": "/foo/bar",
  "publishing_app": "foo_publisher",
  "created_at": "2014-08-13T13:25:17.184Z",
  "updated_at": "2014-08-13T13:25:17.184Z",
  "errors":{"base":["is already reserved by the 'bar_publisher' app"]}
}
      EOT
      stub_request(:put, "#{base_url}/paths/foo/bar").
        with(:body => {"publishing_app" => "foo_publisher"}, :headers => {"Content-Type" => 'application/json'}).
        to_return(:status => 409, :body => json_data, :headers => {'Content-Type' => 'application/json'})

      expect {
        response = client.reserve_path("/foo/bar", "publishing_app" => "foo_publisher")
      }.to raise_error(GOVUK::Client::Errors::Conflict) { |error|
        expect(error.code).to eq(409)
        expect(error.response).to eq({
          "path" => "/foo/bar",
          "publishing_app" => "foo_publisher",
          "created_at" => "2014-08-13T13:25:17.184Z",
          "updated_at" => "2014-08-13T13:25:17.184Z",
          "errors" => { "base" => ["is already reserved by the 'bar_publisher' app"] },
        })
      }
    end

    it "should raise an unprocessable entity error if there are validation errors" do
      json_data = <<-EOT
{
  "path":"/foo/bar",
  "publishing_app":"",
  "created_at":null,
  "updated_at":null,
  "errors":{"publishing_app":["can't be blank"]}
}
      EOT
      stub_request(:put, "#{base_url}/paths/foo/bar").
        with(:body => {"publishing_app" => ""}, :headers => {"Content-Type" => 'application/json'}).
        to_return(:status => 422, :body => json_data, :headers => {'Content-Type' => 'application/json'})

      expect {
        response = client.reserve_path("/foo/bar", "publishing_app" => "")
      }.to raise_error(GOVUK::Client::Errors::UnprocessableEntity) { |error|
        expect(error.code).to eq(422)
        expect(error.response).to eq({
          "path" => "/foo/bar",
          "publishing_app" => "",
          "created_at" => nil,
          "updated_at" => nil,
          "errors" => { "publishing_app" => ["can't be blank"] },
        })
      }
    end

    # FIXME: extract this test into separate unit tests for the generic JSON
    # client stuff when that is extracted into a separate gem.
    it "should handle error responses that don't include a JSON body" do
      stub_request(:put, "#{base_url}/paths/foo/bar").
        to_return(:status => 500, :body => "Computer says no!")

      expect {
        response = client.reserve_path("/foo/bar", "publishing_app" => "foo_publisher")
      }.to raise_error(GOVUK::Client::Errors::HTTPError) { |error|
        expect(error.code).to eq(500)
        expect(error.response.raw_body).to eq("Computer says no!")
        expect(error.response).to eq({})
      }
    end
  end
end
