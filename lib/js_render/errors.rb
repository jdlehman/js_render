module JsRender
  class Error < StandardError
  end

  module Errors
    # Will be thrown when an error occurs in generating server side HTML
    class ServerRenderError < JsRender::Error
      def initialize(component_name, data, message)
        message = ["Error \"#{message}\" when server rendering component, \"#{component_name}\", with data: \"#{data}\"",
                   message.backtrace.join("\n")].join("\n")
        super(message)
      end
    end
  end
end
