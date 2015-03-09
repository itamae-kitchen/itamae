require 'itamae'
require 'hashie'
require 'json'

module Itamae
  class Node < Hashie::Mash
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
          val = host_inventory[key]
        rescue NotImplementedError, NameError
          val = nil
        end
      end
      val
    end

    def validate(schema)
      errors = Validator.new.validate(schema, self)
      unless errors.empty?
        Logger.error "Node validation error:"
        Logger.formatter.indent do
          errors.each do |error|
            Logger.error error.description
          end
        end
      end
    end

    class Validator
      class Error < Struct.new(:location, :message)
        def description
          "#{location.join('/')} #{message}"
        end
      end

      def validate(schema, data)
        errors = []

        schema.each do |k, v|
          case v
          when Hash
            validate(v, data[k]).each do |error|
              error[0].unshift(k)
              errors << error
            end
          when Array
            if data[k].is_a?(Array)
              data[k].each_with_index do |d, i|
                unless d.is_a?(v.first)
                  errors << Error.new([k, i], "error")
                end
              end
            else
              errors << Error.new([k], "not array")
            end
          when Class
            unless data[k].is_a?(v)
              errors << Error.new([k], "error")
            end
          end
        end

        errors
      end
    end
  end
end

