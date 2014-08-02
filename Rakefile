require "bundler/gem_tasks"
require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new("unit") do |task|
    task.ruby_opts = '-I ./spec/unit'
    task.pattern = "./spec/unit{,/*/**}/*_spec.rb"
  end

  namespace :integration do
    targets = []
    Dir.glob('./spec/integration/*').each do |dir|
      next unless File.directory?(dir)
      targets << File.basename(dir)
    end

    task :all     => targets
    task :default => :all

    targets.each do |target|
      desc "Run serverspec tests to #{target}"
      RSpec::Core::RakeTask.new(target.to_sym) do |t|
        ENV['TARGET_HOST'] = target
        t.ruby_opts = '-I ./spec/integration'
        t.pattern = "spec/integration/#{target}/*_spec.rb"
      end
    end
  end
end
