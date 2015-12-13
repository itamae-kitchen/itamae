require 'itamae'
require 'uri'
require 'net/http'

module Itamae
  module Resource
    class HttpRequest < File
      UrlNotFoundError = Class.new(StandardError)

      define_attribute :action, default: :get
      define_attribute :headers, type: Hash, default: {}
      define_attribute :message, type: String, default: ""
      define_attribute :url, type: String, required: true

      def pre_action
        uri = URI.parse(attributes.url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"

        case attributes.action
        when :delete, :get, :options
          response = http.method(attributes.action).call(uri.request_uri, attributes.headers)
        when :post, :put
          response = http.method(attributes.action).call(uri.request_uri, attributes.message, attributes.headers)
        end

        attributes.content = response.body

        super
      end

      def action_delete(options)
        action_create(options)
      end

      def action_get(options)
        action_create(options)
      end

      def action_options(options)
        action_create(options)
      end

      def action_post(options)
        action_create(options)
      end

      def action_put(options)
        action_create(options)
      end
    end
  end
end
