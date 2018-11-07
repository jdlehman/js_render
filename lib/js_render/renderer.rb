require 'execjs'
require 'securerandom'
require 'lru_redux'

module JsRender
  class Renderer
    attr_reader :component_name, :json_data, :uuid, :asset_finder

    @@cache = LruRedux::TTL::ThreadSafeCache.new(JsRender.config.cache_size, JsRender.config.cache_ttl)

    GLOBAL_CONTEXT = <<-JS
      var global = global || this;
      var self = self || this;
      var window = window || this;
      var console = console || { history: [] };
    JS

    CONSOLE_POLYFILL = File.read(File.join(File.dirname(__FILE__), 'polyfills', 'console_polyfill.js'))
    CONSOLE_REPLAY = File.read(File.join(File.dirname(__FILE__), 'polyfills', 'console_replay.js'))

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
          var consoleReplayStr = #{CONSOLE_REPLAY};
          return '<span id="#{@uuid}">' + serverStr + '</span>' + consoleReplayStr;
        })()
      JS
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

    def context
      base_path = JsRender.config.base_path
      paths = JsRender.config.component_paths
      suffix = JsRender.config.component_suffix
      @@cache.getset(base_path + paths.join('') + suffix + @component_name) do
        renderer_code = asset_finder.read_files(@component_name)
        ExecJS.compile(GLOBAL_CONTEXT + CONSOLE_POLYFILL + renderer_code)
      end
    end

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
