module JsRender
  class << self
    attr_accessor :config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.reset
    @config = Configuration.new
  end

  def self.configure
    yield(config)
  end

  class Configuration
    attr_accessor :component_paths,
                  :base_path,
                  :component_suffix,
                  :server_render_function,
                  :client_render_function,
                  :use_asset_pipeline,
                  :asset_finder_class,
                  :should_server_render

    def initialize
      @base_path = 'app/assets/javascripts'
      @component_paths = ['/**/*']
      @component_suffix = '.js'
      @server_render_function = 'window.render*Server'
      @client_render_function = 'window.render*Client'
      @use_asset_pipeline = false
      @asset_finder_class = nil
      @should_server_render = true
    end
  end
end
