require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'tempfile'
require 'net/ssh'

Dir['tasks/*.rb'].each do |file|
  require_relative file
end

desc 'Run unit and integration specs.'
task :spec => ['spec:unit', 'spec:integration:all']

TEST_IMAGE = ENV["TEST_IMAGE"] || "ubuntu:trusty"

namespace :spec do
  RSpec::Core::RakeTask.new("unit") do |task|
    task.ruby_opts = '-I ./spec/unit'
    task.pattern = "./spec/unit{,/*/**}/*_spec.rb"
  end

  namespace :integration do
    container_name = 'itamae'

    task :all => ['spec:integration:docker' 'spec:integration:local']

    desc "Run provision and specs"
    task :docker => ["docker:boot", "docker:provision", "docker:serverspec", 'docker:clean_docker_container']

    namespace :docker do
      desc "Run docker"
      task :boot do
        sh "docker run --privileged -d --name #{container_name} #{TEST_IMAGE} /sbin/init"
      end

      desc "Run itamae"
      task :provision do
        suites = [
          [
            "spec/integration/recipes/default.rb",
            "spec/integration/recipes/default2.rb",
            "spec/integration/recipes/redefine.rb",
            "spec/integration/recipes/docker.rb",
          ],
          [
            "--dry-run",
            "spec/integration/recipes/dry_run.rb",
          ],
        ]
        suites.each do |suite|
          cmd = %w!bundle exec ruby -w bin/itamae docker!
          cmd << "-l" << (ENV['LOG_LEVEL'] || 'debug')
          cmd << "-j" << "spec/integration/recipes/node.json"
          cmd << "--container" << container_name
          cmd << "--tag" << "itamae:latest"
          cmd << "--tmp-dir" << (ENV['ITAMAE_TMP_DIR'] || '/tmp/itamae_tmp')
          cmd += suite

          p cmd
          unless system(*cmd)
            raise "#{cmd} failed"
          end
        end
      end

      desc "Run serverspec tests"
      RSpec::Core::RakeTask.new(:serverspec) do |t|
        ENV['DOCKER_CONTAINER'] = container_name
        t.ruby_opts = '-I ./spec/integration'
        t.pattern = "spec/integration/{default,docker}_spec.rb"
      end

      desc 'Clean a docker container for test'
      task :clean_docker_container do
        sh('docker', 'rm', '-f', container_name)
      end
    end
  end
end

task :default => :spec
