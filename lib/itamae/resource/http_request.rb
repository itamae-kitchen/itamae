require 'itamae'
require 'open-uri'

module Itamae
  module Resource
    class HttpRequest < File
      UrlNotFoundError = Class.new(StandardError)

      define_attribute :headers, type: Hash, default: {}
      define_attribute :url, type: String

      def pre_action
        unless attributes.url
          raise UrlNotFoundError, "url is not found"
        end

        attributes.content = open(attributes.url, attributes.headers).read

        super
      end

      private

      def content_file
        nil
      end
    end
  end
end
