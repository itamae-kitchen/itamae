require 'itamae'
require 'uri'
require 'net/https'

module Itamae
  module Resource
    class HttpRequest < File
      RedirectLimitExceeded = Class.new(StandardError)

      define_attribute :action, default: :get
      define_attribute :headers, type: Hash, default: {}
      define_attribute :message, type: String, default: ""
      define_attribute :redirect_limit, type: Integer, default: 10
      define_attribute :url, type: String, required: true

      def pre_action
        uri = URI.parse(attributes.url)
        response = nil
        redirects_followed = 0

        loop do
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.scheme == "https"

          case attributes.action
          when :delete, :get, :options
            response = http.method(attributes.action).call(uri.request_uri, attributes.headers)
          when :post, :put
            response = http.method(attributes.action).call(uri.request_uri, attributes.message, attributes.headers)
          end

          if response.kind_of?(Net::HTTPRedirection)
            if redirects_followed < attributes.redirect_limit
              uri = URI.parse(response["location"])
              redirects_followed += 1
              Itamae.logger.debug "Following redirect #{redirects_followed}/#{attributes.redirect_limit}"
            else
              raise RedirectLimitExceeded
            end
          else
            break
          end
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
