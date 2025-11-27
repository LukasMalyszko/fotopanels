# frozen_string_literal: true

require 'rspec/core/rake_task'

# Default task runs tests
task default: :spec

# RSpec task
RSpec::Core::RakeTask.new(:spec)

desc 'Run the example script'
task :example do
  ruby 'example.rb'
end

desc 'Run RuboCop linter'
task :rubocop do
  sh 'bundle exec rubocop'
end

desc 'Run all checks (tests and linter)'
task check: %i[spec rubocop]
