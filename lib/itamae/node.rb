require 'hashie'
require 'json'
require 'schash'
require_relative "mash"

module Itamae
  class Node
    ValidationError = Class.new(StandardError)

    attr_reader :mash

    def initialize(hash, backend)
      @mash = Itamae::Mash.new(hash)
      @backend = backend
    end

    def reverse_merge(other_hash)
      self.class.new(_reverse_merge(other_hash), @backend)
    end

    def reverse_merge!(other_hash)
      @mash.replace(_reverse_merge(other_hash))
    end

    def [](key)
      if @mash.has_key?(key)
        @mash[key]
      else
        fetch_inventory_value(key)
      end
    end

    def validate!(&block)
      errors = Schash::Validator.new(&block).validate(@mash)
      unless errors.empty?
        errors.each do |error|
          Itamae.logger.error "'#{error.position.join('->')}' #{error.message}"
        end
        raise ValidationError
      end
    end

    private

    def _reverse_merge(other_hash)
      Itamae::Mash.new(other_hash).merge(@mash)
    end

    def method_missing(method, *args)
      if @mash.respond_to?(method)
        return @mash.public_send(method, *args)
      elsif args.empty? && value = fetch_inventory_value(method)
        return value
      end

      super
    end

    def respond_to?(method, priv = false)
      @mash.respond_to?(method, priv) || super
    end

    def fetch_inventory_value(key)
      value = @backend.host_inventory[key]
      if value.is_a?(Hash)
        value = Itamae::Mash.new(value)
      end

      value
    rescue NotImplementedError, NameError
      nil
    end
  end
end
