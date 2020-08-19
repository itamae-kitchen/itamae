require 'spec_helper'
require 'bundler'
require 'rubygems/security'
require 'rubygems/mock_gem_ui'

module Gem
  # from rubygems/lib/rubygems/test_case.rb
  def self.searcher=(searcher)
    @searcher = searcher
  end
end

module Itamae
  describe List do
    # build gem space for test; from Gem::TestCase#setup
    before do
      @orig_env = ENV.to_hash
      @tmp = File.expand_path("tmp")

      FileUtils.mkdir_p @tmp

      ENV['GEM_VENDOR'] = nil
      ENV['GEMRC'] = nil
      ENV['SOURCE_DATE_EPOCH'] = nil
      ENV["TMPDIR"] = @tmp

      @current_dir = Dir.pwd

      @back_ui = Gem::DefaultUserInteraction.ui
      Gem::DefaultUserInteraction.ui = Gem::MockGemUi.new

      tmpdir = File.realpath Dir.tmpdir
      tmpdir.tap(&Gem::UNTAINT)

      @tempdir = File.join(tmpdir, "test_rubygems_#{$$}")
      @tempdir.tap(&Gem::UNTAINT)

      FileUtils.mkdir_p @tempdir

      @orig_SYSTEM_WIDE_CONFIG_FILE = Gem::ConfigFile::SYSTEM_WIDE_CONFIG_FILE
      Gem::ConfigFile.send :remove_const, :SYSTEM_WIDE_CONFIG_FILE
      Gem::ConfigFile.send :const_set, :SYSTEM_WIDE_CONFIG_FILE,
                           File.join(@tempdir, 'system-gemrc')

      @gemhome = File.join @tempdir, 'gemhome'
      @userhome = File.join @tempdir, 'userhome'
      ENV["GEM_SPEC_CACHE"] = File.join @tempdir, 'spec_cache'

      orig_ruby = if ENV['RUBY']
                    ruby = Gem.ruby
                    Gem.ruby = ENV['RUBY']
                    ruby
                  end

      Gem.ensure_gem_subdirectories @gemhome

      @orig_LOAD_PATH = $LOAD_PATH.dup
      $LOAD_PATH.map! do |s|
        expand_path = File.realpath(s) rescue File.expand_path(s)
        if expand_path != s
          expand_path.tap(&Gem::UNTAINT)
          if s.instance_variable_defined?(:@gem_prelude_index)
            expand_path.instance_variable_set(:@gem_prelude_index, expand_path)
          end
          expand_path.freeze if s.frozen?
          s = expand_path
        end
        s
      end

      Dir.chdir @tempdir

      ENV['HOME'] = @userhome
      Gem.instance_variable_set :@user_home, nil
      Gem.instance_variable_set :@data_home, nil
      Gem.instance_variable_set :@gemdeps, nil
      Gem.instance_variable_set :@env_requirements_by_name, nil
      Gem.send :remove_instance_variable, :@ruby_version if
        Gem.instance_variables.include? :@ruby_version

      FileUtils.mkdir_p @gemhome
      FileUtils.mkdir_p @userhome

      # these are not used here, but used in Gem test:
      @default_dir = File.join @tempdir, 'default'
      @default_spec_dir = File.join @default_dir, "specifications", "default"
      if Gem.java_platform?
        @orig_default_gem_home = RbConfig::CONFIG['default_gem_home']
        RbConfig::CONFIG['default_gem_home'] = @default_dir
      else
        Gem.instance_variable_set(:@default_dir, @default_dir)
      end
      FileUtils.mkdir_p @default_spec_dir

      Gem::Specification.unresolved_deps.clear
      Gem.use_paths(@gemhome)

      Gem::Security.reset

      Gem.loaded_specs.clear
      Gem.instance_variable_set(:@activated_gem_paths, 0)
      Gem.clear_default_specs
      Bundler.reset!

      Gem.configuration.verbose = true
      Gem.configuration.update_sources = true

     #Gem::RemoteFetcher.fetcher = Gem::FakeFetcher.new

      Gem.sources.replace ["http://gems.example.com/"]

      Gem.searcher = nil
     #Gem::SpecFetcher.fetcher = nil

      @orig_arch = RbConfig::CONFIG['arch']

      if win_platform?
        util_set_arch 'i386-mswin32'
      else
        util_set_arch 'i686-darwin8.10.1'
      end

      @orig_hooks = {}
      %w[post_install_hooks done_installing_hooks post_uninstall_hooks pre_uninstall_hooks pre_install_hooks pre_reset_hooks post_reset_hooks post_build_hooks].each do |name|
        @orig_hooks[name] = Gem.send(name).dup
      end

      @marshal_version = "#{Marshal::MAJOR_VERSION}.#{Marshal::MINOR_VERSION}"
      @orig_LOADED_FEATURES = $LOADED_FEATURES.dup
    end

    describe "#run" do
      it "prints 'dummy::a' recipe" do
        recipe_path   = "lib/itamae/plugin/recipe/dummy/a.rb"
        dummy_plugin  = util_spec('itamae-plugin-recipe-dummy', '1', nil, recipe_path)
        install_specs(dummy_plugin)
        File.open(@tmp + '/list.out', 'w') do |f|
          Itamae::List.new(f).run
        end
        expect(File.read(@tmp + '/list.out')).to include("dummy::a")
      end
    end

    after do
      $LOAD_PATH.replace @orig_LOAD_PATH if @orig_LOAD_PATH
      if @orig_LOADED_FEATURES
        if @orig_LOAD_PATH
          ($LOADED_FEATURES - @orig_LOADED_FEATURES).each do |feat|
            $LOADED_FEATURES.delete(feat) if feat.start_with?(@tmp)
          end
        else
          $LOADED_FEATURES.replace @orig_LOADED_FEATURES
        end
      end

      RbConfig::CONFIG['arch'] = @orig_arch

     #if defined? Gem::RemoteFetcher
     #  Gem::RemoteFetcher.fetcher = nil
     #end

      Dir.chdir @current_dir

      FileUtils.rm_rf @tempdir

      ENV.replace(@orig_env)

      Gem::ConfigFile.send :remove_const, :SYSTEM_WIDE_CONFIG_FILE
      Gem::ConfigFile.send :const_set, :SYSTEM_WIDE_CONFIG_FILE,
                           @orig_SYSTEM_WIDE_CONFIG_FILE

      Gem.ruby = @orig_ruby if @orig_ruby

      if Gem.java_platform?
        RbConfig::CONFIG['default_gem_home'] = @orig_default_gem_home
      else
        Gem.instance_variable_set :@default_dir, nil
      end

      Gem::Specification._clear_load_cache
      Gem::Specification.unresolved_deps.clear
      Gem::refresh

      @orig_hooks.each do |name, hooks|
        Gem.send(name).replace hooks
      end

      @back_ui.close
    end

    # stub to emulate rubygems:lib/rubygems/test_case.rb
    def win_platform?
      false
    end

    # stub to emulate rubygems:lib/rubygems/test_case.rb
    def util_set_arch(arch)
      RbConfig::CONFIG['arch'] = arch
      platform = Gem::Platform.new arch

      Gem.instance_variable_set :@platforms, nil
      Gem::Platform.instance_variable_set :@local, nil

      yield if block_given?
  
      platform
    end

    # from rubygems lib/rubygems/{test_case.rb,test_gem_specification.rb}
    def init_gem_related
      # Setting `@default_source_date_epoch` to `nil` effectively resets the
      # value used for `Gem.source_date_epoch` whenever `$SOURCE_DATE_EPOCH`
      # is not set.
      Gem.instance_variable_set(:'@default_source_date_epoch', nil)
    end

    # from rubygems lib/rubygems/test_case.rb
    def util_spec(name, version=2, deps = nil, *files)
      spec = Gem::Specification.new do |s|
        s.platform    = Gem::Platform::RUBY
        s.name        = name
        s.version     = version
        s.author      = 'A User'
        s.email       = 'example@example.com'
        s.homepage    = 'http://example.com'
        s.summary     = "this is a summary"
        s.description = "This is a test description"
        s.files.push(*files) unless files.empty?

        yield s if block_given?
      end
      spec
    end

    # Install the provided specs; from rubygems lib/rubygems/test_case.rb
    #
    # NOTE: physical files in 'spec.files' are automatically generated by Gem::FakePackage
    def install_specs(*specs)
      specs.each do |spec|
        Gem::Installer.for_spec(spec).install
      end
      Gem.searcher = nil
    end
  end
end
