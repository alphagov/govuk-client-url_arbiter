require "gem_publisher"

desc "Publish gem to RubyGems.org"
task :publish_gem do |t|
  gem = GemPublisher.publish_if_updated("govuk-client-url_arbiter.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end
