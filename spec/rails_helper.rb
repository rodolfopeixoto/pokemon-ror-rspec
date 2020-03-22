require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
rails_support_path = Rails.root.join('spec', 'support', '**', '*.rb')
Dir[rails_support_path].each { |file| require file }

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => error
  puts error.to_s.strip
  exit 1
end
RSpec.configure do |configure|
  configure.fixture_path = "#{::Rails.root}/spec/fixtures"
  configure.use_transactional_fixtures = true
  configure.infer_spec_type_from_file_location!
  configure.filter_rails_from_backtrace!
end
