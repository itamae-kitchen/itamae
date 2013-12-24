require 'lightchef'
require 'hashie'
require 'json'

module Lightchef
  class Node < Hashie::Mash
    def self.new_from_file(path)
      hash = JSON.parse(File.read(path))
      self.new(hash)
    end
  end
end

