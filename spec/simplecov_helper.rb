# frozen_string_literal: true

unless ENV['SKIP_SIMPLECOV']
  require 'simplecov'
  SimpleCov.start 'rails' do
    minimum_coverage 90 # fails if overall coverage < 90%
    minimum_coverage_by_file 85

    # Exclude Rails auto-generated files
    add_filter '/bin/'
    add_filter '/db/'
    add_filter '/config/'
    add_filter '/spec/'
    add_filter '/vendor/'
    add_filter '/app/channels/application_cable/'
    add_filter 'app/mailers/application_mailer.rb'
    add_filter 'app/jobs/application_job.rb'
    add_filter 'app/models/ability.rb'
  end
end
