module Itamae
  class List
    def run
      require 'rubygems'
      require 'rubygems/exceptions'
      require 'pathname'

      pattern = /^itamae-plugin-recipe/
      # from rubygems Gem::Commands::QueryCommand#show_local_gems
      specs = Gem::Specification.find_all do |s|
        s.name =~ pattern
      end

      req = Gem::Requirement.default
      dep = Gem::Deprecate.skip_during { Gem::Dependency.new pattern, req }
      specs.select! do |s|
        dep.match?(s.name, s.version, false)
      end
      spec_tuples = specs.map do |spec|
        [spec.name_tuple, spec]
      end

      # from rubygems Gem::Commands::QueryCommand#output_query_results
      versions = Hash.new { |h,name| h[name] = [] }
      spec_tuples.each do |spec_tuple, source|
        versions[spec_tuple.name] << [spec_tuple, source]
      end
      versions = versions.sort_by do |(n,_),_|
        n.downcase
      end

      # from rubygems Gem::Commands::QueryCommand#output_versions
      versions.each do |gem_name, matching_tuples|
        matching_tuples = matching_tuples.sort_by { |n,_| n.version }.reverse
        platforms = Hash.new { |h,version| h[version] = [] }
        matching_tuples.each do |n, _|
          platforms[n.version] << n.platform if n.platform
        end
        seen = {}
        matching_tuples.delete_if do |n,_|
          if seen[n.version]
            true
          else
            seen[n.version] = true
            false
          end
        end
        scan_lib(matching_tuples[0][1].name, matching_tuples[0][1].gem_dir)
      end
    end

    private

    def scan_lib(name, dir)
      puts name + ' gem:'
      Dir.glob(dir + '/lib/itamae/plugin/recipe/**/*.rb') do |f|
        puts '  ' + to_recipe_name(f, dir)
      end
    end

    def to_recipe_name(path, dir)
      pn = Pathname.new(path)
      relative_path = pn.relative_path_from(Pathname.new(dir + '/lib/itamae/plugin/recipe')).to_s
      relative_path.gsub(/\.rb$/, '').
          gsub('/', '::').
          gsub(/::default$/, '')
    end
  end
end
