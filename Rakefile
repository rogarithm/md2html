require 'rake/clean'
require 'rspec/core/rake_task'

desc 'build gem'
task :build => "test:all" do
  `gem build md2html.gemspec`
end

desc 'install gem'
task :install do
  gem_version_line = `cat md2html.gemspec | grep "^\s*s\.version.*"`
  gem_version = gem_version_line.match(/[0-9]+\.[0-9]+\.[0-9]+/)
  if `gem list | grep md2html`.strip! == ""
    puts "not found previously installed gem. install new version..."
    `gem install ./md2html-#{gem_version}.gem`
  else
    puts "uninstall previously installed gem and install new version..."
    `gem uninstall md2html && gem install ./md2html-#{gem_version}.gem`
  end
end

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
