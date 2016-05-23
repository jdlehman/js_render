require 'spec_helper'

describe JsRender::AssetFinder::Base do
  let (:asset_finder) { JsRender::AssetFinder::Base.new }
  after(:each) do
    JsRender.reset
  end

  describe '#find_files' do
    context 'single component file' do
      it 'returns an array of file paths relevant to the component' do
        JsRender.config.base_path = 'spec/js_assets'
        expect(asset_finder.find_files 'TodoList').to eq ['spec/js_assets/TodoList.js']
      end
    end

    context 'component lives in folder' do
      it 'returns an array of file paths relevant to the component' do
        JsRender.config.base_path = 'spec/js_assets'
        JsRender.config.component_suffix = '/index.js'
        expect(asset_finder.find_files 'Box').to eq ['spec/js_assets/Box/index.js']
      end
    end

    context 'component needs multiple files' do
      it 'returns an array of file paths relevant to the component' do
        JsRender.config.base_path = 'spec/js_assets'
        JsRender.config.component_suffix = '/(index|serverRenderer).js'
        expect(asset_finder.find_files 'SplitComponent').to eq ['spec/js_assets/SplitComponent/index.js', 'spec/js_assets/SplitComponent/serverRenderer.js']
      end
    end
  end

  describe '#read_files' do
    context 'single component file' do
      it 'returns contents of component files as string' do
        JsRender.config.base_path = 'spec/js_assets'
        expect(asset_finder.read_files 'TodoList').to eq File.read('spec/js_assets/TodoList.js')
      end
    end

    context 'component lives in folder' do
      it 'returns contents of component files as string' do
        JsRender.config.base_path = 'spec/js_assets'
        JsRender.config.component_suffix = '/index.js'
        expect(asset_finder.read_files 'Box').to eq File.read('spec/js_assets/Box/index.js')
      end
    end

    context 'component needs multiple files' do
      it 'returns contents of component files as string' do
        JsRender.config.base_path = 'spec/js_assets'
        JsRender.config.component_suffix = '/(index|serverRenderer).js'
        file_str = File.read('spec/js_assets/SplitComponent/index.js') + File.read('spec/js_assets/SplitComponent/serverRenderer.js')
        expect(asset_finder.read_files 'SplitComponent').to eq file_str
      end
    end
  end

  describe '#read' do
    context 'file exists' do
      it 'throws an error' do
        expect{asset_finder.read 'notafile.js'}.to raise_error(JsRender::Errors::AssetFileNotFound)
      end
    end

    context 'file does not exist' do
      it 'reads file' do
        expect(asset_finder.read 'spec/js_assets/myFile.txt').to eq "hello\n"
      end
    end
  end
end
