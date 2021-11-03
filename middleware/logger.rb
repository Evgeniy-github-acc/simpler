require 'logger'

class AppLogger

  def initialize(app, **options)
    @logger = Logger.new(options[:logdev] || STDOUT)
    @app = app
  end

  def call(env)
    @app.call(env)
    @logger.info(message(env))
    @app.controller.response.finish
  end

  def message(env)
    "\nRequest:    #{env['REQUEST_METHOD']} #{env['PATH_INFO']}
       Handler:    #{@app.router.route_for(env).controller}\##{@app.router.route_for(env).action}
       Parameters: #{@app.controller.request.params}
       Response:   #{@app.controller.response.status}
                   #{@app.controller.response['Content-Type']}
                   #{env['simpler.template'] == 'inline' ? nil : env['simpler.template'] + ".html.erb"}"
  end

end