
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
end
