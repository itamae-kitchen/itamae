require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'tempfile'
require 'net/ssh'

desc 'Run unit and integration specs.'
task :spec => ['spec:unit', 'spec:integration:all']

namespace :spec do
  RSpec::Core::RakeTask.new("unit") do |task|
    task.ruby_opts = '-I ./spec/unit'
    task.pattern = "./spec/unit{,/*/**}/*_spec.rb"
  end

  namespace :integration do
    targets = ["ubuntu:trusty"]

    task :all     => targets

    targets.each do |target|
      desc "Run provision and specs to #{target}"
      task target => ["docker:#{target}", "provision:#{target}", "serverspec:#{target}"]

      namespace :docker do
        desc "Run docker for #{target}"
        task target do
          sh "docker run --privileged -d --name itamae #{target} /sbin/init"
        end
      end

      namespace :provision do
        desc "Run itamae to #{target}"
        task target do
          suites = [
            [
              "spec/integration/recipes/default.rb",
              "spec/integration/recipes/default2.rb",
              "spec/integration/recipes/redefine.rb",
            ],
            [
              "--dry-run",
              "spec/integration/recipes/dry_run.rb",
            ],
          ]
          suites.each do |suite|
            cmd = %w!bundle exec bin/itamae docker!
            cmd << "-l" << (ENV['LOG_LEVEL'] || 'debug')
            cmd << "-j" << "spec/integration/recipes/node.json"
            cmd << "--container" << "itamae"
            cmd << "--tag" << "itamae:latest"
            cmd += suite

            p cmd
            unless system(*cmd)
              raise "#{cmd} failed"
            end
          end
        end
      end

      namespace :serverspec do
        desc "Run serverspec tests to #{target}"
        RSpec::Core::RakeTask.new(target.to_sym) do |t|
          ENV['DOCKER_CONTAINER'] = "itamae"
          t.ruby_opts = '-I ./spec/integration'
          t.pattern = "spec/integration/*_spec.rb"
        end
      end
    end
  end
end

