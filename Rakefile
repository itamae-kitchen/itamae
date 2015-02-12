require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'tempfile'
require 'net/ssh'

vagrant_bin = ENV['CI'] ? 'vagrant' : '/usr/bin/vagrant'

desc 'Run unit and integration specs.'
task :spec => ['spec:unit', 'spec:integration:all']

namespace :spec do
  RSpec::Core::RakeTask.new("unit") do |task|
    task.ruby_opts = '-I ./spec/unit'
    task.pattern = "./spec/unit{,/*/**}/*_spec.rb"
  end

  namespace :integration do
    targets = []
    Bundler.with_clean_env do
      `cd spec/integration && #{vagrant_bin} status`.split("\n\n")[1].each_line do |line|
        targets << line.match(/^[^ ]+/)[0]
      end
    end

    task :all     => targets

    targets.each do |target|
      desc "Run provision and specs to #{target}"
      task target => ["provision:#{target}", "serverspec:#{target}"]

      namespace :provision do
        task target do
          Bundler.with_clean_env do
            config = Tempfile.new('', Dir.tmpdir)
            env = {"VAGRANT_CWD" => File.expand_path('./spec/integration')}
            system env, "#{vagrant_bin} up #{target}"
            system env, "#{vagrant_bin} ssh-config #{target} > #{config.path}"
            options = Net::SSH::Config.for(target, [config.path])

            cmd = "bundle exec bin/itamae ssh"
            cmd << " -h #{options[:host_name]}"
            cmd << " -u #{options[:user]}"
            cmd << " -p #{options[:port]}"
            cmd << " -i #{options[:keys].first}"
            cmd << " -l #{ENV['LOG_LEVEL'] || 'debug'}"
            cmd << " -j spec/integration/recipes/node.json"
            cmd << " spec/integration/recipes/default.rb"
            cmd << " spec/integration/recipes/default2.rb"
            cmd << " spec/integration/recipes/redefine.rb"

            puts cmd
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
          t.pattern = "spec/integration/*_spec.rb"
        end
      end
    end
  end
end

namespace :release do
  desc "Bump up version and commit"
  task :version_up do
    version_file = File.expand_path("lib/itamae/version.txt")
    current_version = File.read(version_file).strip

    if /\A(.+?)(\d+)\z/ =~ current_version
      next_version = "#{$1}#{$2.to_i + 1}"
    else
      raise "Invalid version"
    end

    open(version_file, "w") do |f|
      f.write next_version
    end
    system "git add #{version_file}"
    system "git commit -m 'Bump up version'"
  end
end

