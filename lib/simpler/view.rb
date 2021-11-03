require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      if template_inline?
        @env['simpler.plain']
      else
        template = File.read(template_path)
        ERB.new(template).result(binding)
      end
    end

    private

    def template_inline?
      @env['simpler.template'] == 'inline'
    end

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def template_path
      path = template || [controller.name, action].join('/')

      @env['simpler.template'] = path
      Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
    end

  end
end
