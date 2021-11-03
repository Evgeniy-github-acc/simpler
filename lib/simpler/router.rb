require_relative 'router/route'

module Simpler
  class Router

    attr_reader :routes

    def initialize
      @routes = []
    end

    def get(path, route_point)
      add_route(:get, path, route_point)
    end

    def post(path, route_point)
      add_route(:post, path, route_point)
    end

    def route_for(env)
      method = env['REQUEST_METHOD'].downcase.to_sym
      path = env['PATH_INFO']

      route = @routes.find { |route| route.match?(method, path) }
      route.params_values = env_params(path, route.default_path)

      route
    end

    private

    def add_route(method, path, route_point)
      route_point = route_point.split('#')
      controller = controller_from_string(route_point[0])
      action = route_point[1]
      converted_path = convert_path(path)
      route = Route.new(method, converted_path, controller, action)

      route.default_path = path
      route.params_keys = params_from_path(path)

      @routes.push(route)
    end

    def controller_from_string(controller_name)
      Object.const_get("#{controller_name.capitalize}Controller")
    end

    def convert_path(path)
      path.split('/').map! { |i| i = i.start_with?(':') ? 101 : i }.join('/')
    end

    def params_from_path(path)
      path.split('/').select { |i| i.start_with?(':') }
                     .map! { |i| i.delete(":").to_sym }
    end

    def env_params(env_path, route_path)
      env_path.split('/') - route_path.split('/')
    end


  end
end
