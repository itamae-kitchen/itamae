desc 'Run all integration tests on `itamae local` command'
task 'spec:integration:local' => ['spec:integration:local:main', 'spec:integration:local:ordinary_user']

namespace 'spec:integration:local' do
  desc 'Run main integration test with `itamae local`'
  task 'main' do
    if RUBY_DESCRIPTION.include?('dev')
      $stderr.puts "This integration test is skipped with unreleased Ruby."
      $stderr.puts "Use released Ruby to execute this integration test."
      next
    end

    IntegrationLocalSpecRunner.new(
      [
        [
          "spec/integration/recipes/default.rb",
          "spec/integration/recipes/default2.rb",
          "spec/integration/recipes/redefine.rb",
          "spec/integration/recipes/local.rb",
        ],
        [
          "--dry-run",
          "spec/integration/recipes/dry_run.rb",
        ],
      ],
      ['spec/integration/default_spec.rb']
    ).run
    
  end

  desc 'Run integration test for ordinary user with `itamae local`'
  task 'ordinary_user' do
    if RUBY_DESCRIPTION.include?('dev')
      $stderr.puts "This integration test is skipped with unreleased Ruby."
      $stderr.puts "Use released Ruby to execute this integration test."
      next
    end

    runner = IntegrationLocalSpecRunner.new(
      [
        [
          "--dry-run",
          "spec/integration/recipes/ordinary_user.rb",
        ],
        [
          "spec/integration/recipes/ordinary_user.rb"
        ],
      ],
      ['spec/integration/ordinary_user_spec.rb'],
      user: 'ordinary_san'
    )
    runner.docker_exec 'useradd', 'ordinary_san', '-p', '*'
    runner.docker_exec 'useradd', 'itamae', '-p', '*', '--create-home'
    runner.docker_exec 'sh', '-c', 'echo "ordinary_san ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers'
    runner.run
  end
end

class IntegrationLocalSpecRunner
  CONTAINER_NAME = 'itamae'
  include FileUtils

  def initialize(suites, specs, ruby_version: RUBY_VERSION.split('.')[0..1].join('.'), user: nil)
    @suites = suites
    @specs = specs
    @ruby_version = ruby_version
    @user = user

    docker_run
    prepare
  end

  def run
    provision
    serverspec
    clean_docker_container
  end

  def docker_run
    mount_dir = Pathname(__dir__).join('../').to_s
    sh 'docker', 'run', '--privileged', '-d', '--name', CONTAINER_NAME, '-v', "#{mount_dir}:/itamae", "ruby:#{@ruby_version}", 'sleep', '1d'
  end

  def prepare
    # Install the same version of bundler into the Docker container as is installed locally
    current_bundler_version = /([0-9.]+)/.match(`bundle -v`).captures[0]
    docker_exec 'gem', 'install', 'bundler', '-v', current_bundler_version

    docker_exec 'bundle', 'install', options: %w[--workdir /itamae]
    docker_exec 'apt-get', 'update', '-y'
    docker_exec 'apt-get', 'install', 'locales', 'sudo', '-y'
    docker_exec 'localedef', '-i', 'en_US', '-c', '-f', 'UTF-8', '-A', '/usr/share/locale/locale.alias', 'en_US.UTF-8'
  end

  def provision
    @suites.each do |suite|
      cmd = %W!bundle exec ruby -w bin/itamae local!
      cmd << "-l" << (ENV['LOG_LEVEL'] || 'debug')
      cmd << "-j" << "spec/integration/recipes/node.json"
      cmd += suite

      options = %w[--workdir /itamae]
      options.push('--user',  @user) if @user
      docker_exec(*cmd, options: options)
    end
  end

  def serverspec
    ENV['DOCKER_CONTAINER'] = CONTAINER_NAME
    sh('bundle', 'exec', 'rspec', '-I', './spec/integration', *@specs)
  end

  def clean_docker_container
    sh('docker', 'rm', '-f', CONTAINER_NAME)
  end

  def docker_exec(*cmd, options: [])
    sh 'docker', 'exec', '--env', 'LANG=en_US.utf8', *options, CONTAINER_NAME, *cmd
  end
end
