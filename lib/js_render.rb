require 'js_render/version'
require 'js_render/configuration'
require 'js_render/errors'
require 'js_render/renderer'

module JsRender
end

require 'js_render/rails' if defined?(Rails)
