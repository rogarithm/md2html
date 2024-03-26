require 'rake/clean'
require 'rspec/core/rake_task'

task :test_token do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/token*.rb'
  end
  Rake::Task["spec"].execute
end
task :test_parser do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/parser_spec.rb'
  end
  Rake::Task["spec"].execute
end
task :test_generator do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/generator_spec.rb'
  end
  Rake::Task["spec"].execute
end
task :test_concern do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/concern_spec.rb'
  end
  Rake::Task["spec"].execute
end
