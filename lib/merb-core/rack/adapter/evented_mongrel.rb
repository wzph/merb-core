require 'swiftcore/evented_mongrel'
require 'merb-core/rack/handler/mongrel'
module Merb
  module Rack

    class EventedMongrel < Mongrel
      # Starts Mongrel as evented.
      #
      # ==== Parameters
      # opts<Hash>:: Options for Mongrel (see below).
      #
      # ==== Options (opts)
      # :host<String>:: The hostname that Mongrel should serve.
      # :port<Fixnum>:: The port Mongrel should bind to.
      # :app<String>>:: The application name.
      def self.start(opts={})
        Merb.logger.warn!("Using EventedMongrel adapter")
        Merb::Dispatcher.use_mutex = false
        server = ::Mongrel::HttpServer.new(opts[:host], opts[:port].to_i)
        Merb::Server.change_privilege
        server.register('/', ::Merb::Rack::Handler::Mongrel.new(opts[:app]))
        server.run.join
      end
    end
  end
end