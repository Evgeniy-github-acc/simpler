require 'yaml'
require 'singleton'
require 'sequel'
require_relative 'router'
require_relative 'controller'

module Simpler
  class Application

    include Singleton

    attr_reader :db, :router, :controller

    def initialize
      @router = Router.new
      @db = nil
    end

    def bootstrap!
      setup_database
      require_app
      require_routes
    end

    def routes(&block)
      @router.instance_eval(&block)
    end

    def call(env)
      route = @router.route_for(env)

      route_exist?(route) ? valid_route(route, env) : invalid_route
    end

    private

    def require_app
      Dir["#{Simpler.root}/app/**/*.rb"].each { |file| require file }
    end

    def require_routes
      require Simpler.root.join('config/routes')
    end

    def route_exist?(route)
      !route.nil?
    end

    def valid_route(route, env)
      @controller = route.controller.new(env)
      @controller.set_params(route.params_keys, route.params_values)
      action = route.action

      make_response(controller, action)        
    end

    def invalid_route
      Rack::Response.new('Page not found', 404, { 'Content-Type' => 'text/plain' }).finish  
    end

    def setup_database
      database_config = YAML.load_file(Simpler.root.join('config/database.yml'))
      database_config['database'] = Simpler.root.join(database_config['database'])
      @db = Sequel.connect(database_config)
    end

    def make_response(controller, action)
      controller.make_response(action)
    end

  end
end
