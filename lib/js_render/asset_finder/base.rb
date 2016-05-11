module JsRender
  module AssetFinder
    class Base
      def initialize
      end

      def find(path)
        if File.file? path
          File.read(path)
        else
          raise JsRender::Errors::AssetFileNotFound.new "Asset \"#{path}\" does not exist."
        end
      end
    end
  end
end
