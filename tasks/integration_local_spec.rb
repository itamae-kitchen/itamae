desc 'Run integration test on `itamae local` command'
task 'spec:integration:local' do
  next if RUBY_DESCRIPTION.include?('dev')

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

class IntegrationLocalSpecRunner
  CONTAINER_NAME = 'itamae'
  include FileUtils

  def initialize(suites, specs, ruby_version: RUBY_VERSION.split('.')[0..1].join('.'))
    @suites = suites
    @specs = specs
    @ruby_version = ruby_version
  end

  def run
    docker_run
    prepare
    provision
    serverspec
    clean_docker_container
  end

  def docker_run
    mount_dir = Pathname(__dir__).join('../').to_s
    sh 'docker', 'run', '--privileged', '-d', '--name', CONTAINER_NAME, '-v', "#{mount_dir}:/itamae", "ruby:#{@ruby_version}", 'sleep', '1d'
  end

  def prepare
    docker_exec 'gem', 'install', 'bundler'
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

      docker_exec(*cmd, options: %w[--workdir /itamae])
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
