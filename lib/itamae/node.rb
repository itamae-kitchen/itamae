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
        rescue NotImplementedError
          val = nil
        end
      end
      val
    end
  end
end

