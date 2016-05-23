require 'execjs'
require 'securerandom'

module JsRender
  class Renderer
    attr_reader :component_name, :json_data, :uuid, :asset_finder

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
      renderer_code = asset_finder.read_files(@component_name)
      context = ::ExecJS.compile(GLOBAL_CONTEXT + renderer_code)
      context.eval(server_code)
    rescue ExecJS::RuntimeError, ExecJS::ProgramError => error
      raise Errors::ServerRenderError::new(@component_name, @json_data, error)
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

    def asset_finder
      @asset_finder ||=
        if JsRender.config.asset_finder_class
          JsRender.config.asset_finder_class.new
        elsif defined?(::Rails) && JsRender.config.use_asset_pipeline
          Rails::AssetFinder.new
        else
          AssetFinder::Base.new
        end
    end
  end
end
