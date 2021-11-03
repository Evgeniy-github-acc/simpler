module Simpler
  class Router
    class Route

      attr_accessor :params_keys, :params_values, :default_path
      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
        @default_path = ""
        @params_keys = []
        @params_values = []
      end

      def match?(method, path)
        @method == method && path.match(@path)
      end

    end
  end
end
