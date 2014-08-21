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
  end
end

