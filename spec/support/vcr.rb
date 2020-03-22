VCR.configure do |configure|
  configure.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  configure.hook_into :webmock
  configure.configure_rspec_metadata!
end
