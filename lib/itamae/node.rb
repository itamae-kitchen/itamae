require 'itamae'
require 'hashie'
require 'json'
require 'schash'

module Itamae
  class Node < Hashie::Mash
    ValidationError = Class.new(StandardError)

    def initialize(initial_hash, backend = nil)
      super(initial_hash)
      @backend = backend
    end

    def reverse_merge(other_hash)
      Hashie::Mash.new(other_hash).merge(self)
    end

    def reverse_merge!(other_hash)
      self.replace(reverse_merge(other_hash))
    end

    def [](key)
      val = super(key)
      if val.nil?
        begin
          val = @backend.host_inventory[key]
        rescue NotImplementedError, NameError
          val = nil
        end
      end
      val
    end

    def validate!(&block)
      errors = Schash::Validator.new(&block).validate(self)
      unless errors.empty?
        errors.each do |error|
          Logger.error "'#{error.position.join('->')}' #{error.message}"
        end
        raise ValidationError
      end
    end
  end
end

