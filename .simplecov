require "simplecov"

SimpleCov.start "rails" do
  enable_coverage :branch
  minimum_coverage 100

  add_filter %w[
    bin/
    config/
    db/
    spec/
    vendor/
    node_modules/
    log/
    tmp/
  ]

  add_group "Models",      "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Services",    "app/services"
  add_group "Policies",    "app/policies"
  add_group "Helpers",     "app/helpers"
end
