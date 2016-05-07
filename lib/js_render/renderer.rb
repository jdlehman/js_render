require 'execjs'

module JsRender
  class Renderer
    attr_accessor :component_name, :json_data, :uuid

    GLOBAL_CONTEXT = <<-JS
      var global = global || this;
      var self = self || this;
      var window = window || this;
    JS

    def initialize(component_name, data)
      @component_name = component_name
      data = data.to_json if !data.is_a?(String)
      @json_data = data
      @uuid = SecureRandom.uuid
    end

    def render_component
      server_html = generate_html
      client_script = generate_client_script
      component = (server_html + client_script)
      component.respond_to?(:html_safe) ? component.html_safe : component
    end

    def generate_html
      func_name = JsRender.config.server_render_function.gsub('*', @component_name)
      server_code = <<-JS
        (function () {
          var serverStr = typeof #{func_name} === 'function' ? #{func_name}(#{@json_data}) : '';
          return '<span id="#{@uuid}">' + serverStr + '</span>';
        })()
      JS
      renderer_code = js_context(find_renderer)
      context = ::ExecJS.compile(GLOBAL_CONTEXT + renderer_code)
      context.eval(server_code)
    rescue ExecJS::RuntimeError, ExecJS::ProgramError => error
      raise JsRender::ServerRenderError::new(@component_name, @json_data, error)
    end

    def generate_client_script
      func_name = JsRender.config.client_render_function.gsub('*', @component_name)
      <<-HTML
        <script>
          typeof #{func_name} === 'function' && #{func_name}('#{@uuid}', #{@json_data});
        </script>
      HTML
    end


    private

    def find_renderer
      base_path = JsRender.config.base_path
      paths = JsRender.config.component_paths
      suffix = JsRender.config.component_suffix

      paths.map do |path|
        Dir[File.join(base_path, path)].select do |full_path|
          full_path.match Regexp.new("/#{@component_name}#{suffix}")
        end
      end.compact.flatten.uniq
    end

    def js_context(paths)
      if defined?(::Rails) && JsRender.config.use_asset_pipeline
        ::Rails.application.assets.each_file.select do |abs_path|
          regex = ::Regexp.new(paths.join('|'))
          abs_path.match(regex)
        end.map do |abs_path|
          ::Rails.application.assets[abs_path].to_s
        end.join('')
      else
        paths.map { |path| File.read(path) }.join('')
      end
    end
  end

  class ServerRenderError < ::StandardError
    def initialize(component_name, data, message)
      message = ["Error \"#{message}\" when server rendering component, \"#{component_name}\", with data: \"#{data}\"",
                 message.backtrace.join("\n")].join("\n")
      super(message)
    end
  end
end
