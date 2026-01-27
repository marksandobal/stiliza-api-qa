require "sidekiq/testing"

RSpec.configure do |config|
  config.before(:each) do
    # By default, use fake mode (jobs are pushed to a jobs array)
    Sidekiq::Testing.fake!
  end

  config.before(:each, sidekiq: :inline) do
    # For tests tagged with sidekiq: :inline, jobs are executed immediately
    Sidekiq::Testing.inline!
  end

  config.after(:each) do
    # Clear all jobs after each test
    Sidekiq::Worker.clear_all
  end
end
