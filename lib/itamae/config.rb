require 'yaml'

module Itamae
  class Config
    CONFIG_MATCHER = /(-c|--config) +([^ ]+)/

    def initialize(options)
      @options = options
    end

    def load
      return @options unless config_given?

      configs, options = parse_options
      configs.each do |config|
        options += load_config(config)
      end
      options
    end

    private

    def parse_options
      configs = []
      parsed_option = joined_options.gsub(CONFIG_MATCHER).each do |match|
        configs << Regexp.last_match[2]
        next ''
      end
      [configs, parsed_option.split(' ')]
    end

    def load_config(config)
      YAML.load(open(config)).inject([]) do |options, (key, value)|
        options + ["--#{key}", value.to_s]
      end
    end

    def config_given?
      joined_options =~ CONFIG_MATCHER
    end

    def joined_options
      @option ||= @options.join(' ')
    end
  end
end
