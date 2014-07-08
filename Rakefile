namespace :yuyi do
  desc 'Watch Yuyi for changes with guard'
  task(:watch) do
    require 'guard'
    Guard.start
    while Guard.running do
      sleep 0.5
    end
  end

  namespace :test do
    require 'rspec/core/rake_task'

    desc 'Run the rspec tests for the Yuyi library and a sanity check on rolls from a menu source'
    task :all => ['test:library', 'test:rolls']

    task :library do
      RSpec::Core::RakeTask.new(:spec)
      Rake::Task[:spec].invoke
    end

    desc 'Run a sanity check on the source rolls'
    task :rolls do
      RSpec::Core::RakeTask.new(:roll_validator) do |t|
        t.pattern = './spec/roll_validator.rb'
      end
      Rake::Task[:roll_validator].invoke
    end
  end

  desc 'Run the rspec tests for the Yuyi library'
  task :test => 'test:library'

end

desc 'Alias for yuyi:watch'
task :yuyi => 'yuyi:watch'
task :default => 'yuyi:watch'
