module JsRender
  module AssetFinder
    class Base
      def find_files(component_name)
        base_path = JsRender.config.base_path
        paths = JsRender.config.component_paths
        suffix = JsRender.config.component_suffix

        paths.map do |path|
          Dir[File.join(base_path, path)].select do |full_path|
            full_path.match Regexp.new("/#{component_name}#{suffix}")
          end
        end.compact.flatten.uniq
      end

      def read_files(component_name)
        files = find_files component_name
        files.map { |file| read file }.join('')
      end

      def read(path)
        if File.file? path
          File.read path
        else
          raise JsRender::Errors::AssetFileNotFound.new "Asset \"#{path}\" does not exist."
        end
      end
    end
  end
end
