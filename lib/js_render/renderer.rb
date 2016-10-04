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
      unless data.is_a?(String)
        transform_keys(data)
        data = data.to_json
      end
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
      return "<span id=\"#{@uuid}\"></span>" unless JsRender.config.should_server_render

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

    def transform_keys(data)
      JsRender.config.key_transforms.reduce(data) do |transformed_data, transform|
        transformed_data.tap do |d|
          d.keys.each { |k| d[transform.call(k.to_s)] = d.delete(k) }
        end
      end
    end
  end
end
