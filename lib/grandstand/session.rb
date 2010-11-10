module Grandstand
  class Session #:nodoc: all
    def initialize(app, session_key = '_session_id')
      @app = app
      @session_key = session_key
    end

    def call(env)
      if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/ && env['PATH_INFO'] =~ /^\/grandstand\/galleries\/\d+\/images$/
        params = Rack::Request.new(env).POST
        env['HTTP_COOKIE'] = [ @session_key, params.delete('session_key') ].join('=').freeze unless params['session_key'].nil?
      end
      @app.call(env)
    end
  end
end
