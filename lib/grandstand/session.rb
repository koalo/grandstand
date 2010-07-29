require 'rack/utils'

module Grandstand
  class Session
    def initialize(app, session_key = '_session_id')
      @app = app
      @session_key = session_key
    end

    def call(env)
      if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/ && env['PATH_INFO'] =~ /^\/admin\/galleries\/\d+\/images$/
        params = Rack::Request.new(env).POST
        unless params['session_key'].nil?
          # This will strip out the session_key from the POST params - not entirely necessary,
          # but still cleaner than the alternative
          env['HTTP_COOKIE'] = [ @session_key, params.delete('session_key') ].join('=').freeze
          env['rack.input'] = StringIO.new(Rack::Utils::Multipart.build_multipart(params))
          env['rack.input'].rewind
        end
        puts "\n\n#{env['HTTP_COOKIE'].inspect}\n\n"
      end
      @app.call(env)
    end
  end
end
