require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'tempfile'
require 'net/ssh'

vagrant_bin = 'vagrant'

desc 'Run unit and integration specs.'
task :spec => ['spec:unit', 'spec:integration:all']

namespace :spec do
  RSpec::Core::RakeTask.new("unit") do |task|
    task.ruby_opts = '-I ./spec/unit'
    task.pattern = "./spec/unit{,/*/**}/*_spec.rb"
  end

  namespace :integration do
    targets = []
    status = `cd spec/integration && #{vagrant_bin} status`
    unless $?.exitstatus == 0
      raise "vagrant status failed.\n#{status}"
    end

    status.split("\n\n")[1].each_line do |line|
      targets << line.match(/^[^ ]+/)[0]
    end

    task :all     => targets

    targets.each do |target|
      desc "Run provision and specs to #{target}"
      task target => ["provision:#{target}", "serverspec:#{target}"]

      namespace :provision do
        task target do
          config = Tempfile.new('', Dir.tmpdir)
          env = {"VAGRANT_CWD" => File.expand_path('./spec/integration')}
          system env, "#{vagrant_bin} up #{target}"
          system env, "#{vagrant_bin} ssh-config #{target} > #{config.path}"
          options = Net::SSH::Config.for(target, [config.path])

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
            cmd = %w!bundle exec bin/itamae ssh!
            cmd << "-h" << options[:host_name]
            cmd << "-u" << options[:user]
            cmd << "-p" << options[:port].to_s
            cmd << "-i" << options[:keys].first
            cmd << "-l" << (ENV['LOG_LEVEL'] || 'debug')
            cmd << "-j" << "spec/integration/recipes/node.json"
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
          ENV['TARGET_HOST'] = target
          t.ruby_opts = '-I ./spec/integration'
          t.pattern = "spec/integration/*_spec.rb"
        end
      end
    end
  end
end

