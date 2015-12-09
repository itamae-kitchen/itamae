require 'itamae'
require 'open-uri'

module Itamae
  module Resource
    class HttpRequest < File
      UrlNotFoundError = Class.new(StandardError)

      define_attribute :headers, type: Hash, default: {}
      define_attribute :url, type: String, required: true

      def pre_action
        attributes.content = open(attributes.url, attributes.headers).read

        super
      end
    end
  end
end
