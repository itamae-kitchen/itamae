require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'tempfile'
require 'net/ssh'

namespace :spec do
  RSpec::Core::RakeTask.new("unit") do |task|
    task.ruby_opts = '-I ./spec/unit'
    task.pattern = "./spec/unit{,/*/**}/*_spec.rb"
  end

  namespace :integration do
    targets = []
    Dir.glob('./spec/integration/environments/*').each do |dir|
      next unless File.directory?(dir)
      targets << File.basename(dir)
    end

    task :all     => targets
    task :default => :all

    targets.each do |target|
      desc "Run provision and specs to #{target}"
      task target => ["provision:#{target}", "serverspec:#{target}"]

      namespace :provision do
        task target do
          Bundler.with_clean_env do
            config = Tempfile.new('', Dir.tmpdir)
            env = {"VAGRANT_CWD" => File.expand_path('./spec/integration')}
            system env, "/usr/bin/vagrant up #{target}"
            system env, "/usr/bin/vagrant ssh-config #{target} > #{config.path}"
            options = Net::SSH::Config.for(target, [config.path])

            cmd = "bundle exec bin/lightchef ssh"
            cmd << " -h #{options[:host_name]}"
            cmd << " -u #{options[:user]}"
            cmd << " -p #{options[:port]}"
            cmd << " -i #{options[:keys].first}"
            cmd << " spec/integration/recipes/default.rb"

            system cmd
            abort unless $?.exitstatus == 0
          end
        end
      end

      namespace :serverspec do
        desc "Run serverspec tests to #{target}"
        RSpec::Core::RakeTask.new(target.to_sym) do |t|
          ENV['TARGET_HOST'] = target
          t.ruby_opts = '-I ./spec/integration'
          t.pattern = "spec/integration/environments/#{target}/*_spec.rb"
        end
      end
    end
  end
end
