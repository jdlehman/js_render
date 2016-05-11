module JsRender
  module Rails
    class AssetFinder < ::JsRender::AssetFinder::Base
      def initialize
        @environment = ::Rails.application.assets
        @manifest = ::Rails.application.assets_manifest
      end

      def find(path)
        logical_path = path.gsub('app/assets/javascripts/', '')
        if @environment
          @environment[logical_path].to_s
        elsif @manifest.assets[logical_path]
          relative_path = @manifest.assets[logical_path]
          full_path = File.join(@manifest.dir, relative_path)
          File.read full_path
        else
          super path
        end
      end
    end
  end
end
