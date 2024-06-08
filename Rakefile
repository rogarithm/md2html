require 'rake/clean'
require 'rspec/core/rake_task'

namespace :test do
  desc 'run all specs and tests'
  task :all => [:token, :parser, :generator, :concern, :file] do
  end

  desc 'run file based test'
  task :file do
    `ruby test/run_tests.rb`
  end

  desc 'run all specs'
  task :specs => [:token, :parser, :generator, :concern] do
  end

  desc 'run token spec'
  task :token do
    RSpec::Core::RakeTask.new(:token_spec) do |t|
      t.pattern = 'spec/token*.rb'
    end
    Rake::Task[:token_spec].execute
  end

  desc 'run parser spec'
  task :parser do
    RSpec::Core::RakeTask.new(:parser_spec) do |t|
      t.pattern = 'spec/parser_spec.rb'
    end
    Rake::Task[:parser_spec].execute
  end

  desc 'run generator spec'
  task :generator do
    RSpec::Core::RakeTask.new(:generator_spec) do |t|
      t.pattern = 'spec/generator_spec.rb'
    end
    Rake::Task[:generator_spec].execute
  end

  desc 'run concern spec'
  task :concern do
    RSpec::Core::RakeTask.new(:concern_spec) do |t|
      t.pattern = 'spec/concern_spec.rb'
    end
    Rake::Task[:concern_spec].execute
  end
end
