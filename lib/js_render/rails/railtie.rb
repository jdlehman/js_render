require 'rails'

module JsRender
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'js_render.view_helpers' do
        ActionView::Base.send :include, ViewHelpers
      end
    end
  end
end
