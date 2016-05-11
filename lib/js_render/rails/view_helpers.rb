module JsRender
  module Rails
    module ViewHelpers
      def render_component(component_name, data = 'undefined')
        renderer = JsRender::Renderer.new(component_name, data)
        renderer.render_component
      end
    end
  end
end
