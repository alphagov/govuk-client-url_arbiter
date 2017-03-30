# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'govuk/client/url_arbiter/version'

Gem::Specification.new do |spec|
  spec.name          = "govuk-client-url_arbiter"
  spec.version       = GOVUK::Client::URLArbiter::VERSION
  spec.authors       = ["Alex Tomlins"]
  spec.email         = ["alex.tomlins@digital.cabinet-office.gov.uk"]
  spec.summary       = %q{API client for the url-arbiter}
  spec.homepage      = "https://github.com/alphagov/govuk-client-url_arbiter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", '~> 2.0'
  spec.add_dependency "multi_json", "~> 1.0"
  spec.add_dependency "plek", '~> 1.8'

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 2.3.2"
end
