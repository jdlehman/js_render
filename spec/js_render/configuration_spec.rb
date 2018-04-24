require 'spec_helper'

describe JsRender::Configuration do
  describe '.config' do
    it 'reads/writes to config' do
      JsRender.config.base_path = 'test'
      JsRender.config.component_paths = ['test', 'test2']

      expect(JsRender.config.base_path).to eq 'test'
      expect(JsRender.config.component_paths).to eq ['test', 'test2']
    end
  end

  describe '.reset' do
    it 'resets config' do
      JsRender.config.base_path = 'test'
      JsRender.reset
      expect(JsRender.config.base_path).not_to eq 'test'
    end
  end

  describe '.configure' do
    it 'allows configuration in a block' do
      JsRender.configure do |config|
        config.base_path = 'test'
        config.component_paths = ['abc']
      end
      expect(JsRender.config.base_path).to eq 'test'
      expect(JsRender.config.component_paths).to eq ['abc']
    end
  end

  describe '#initialize' do
    it 'sets default configs' do
      config = JsRender::Configuration.new
      expect(config.base_path).to eq 'app/assets/javascripts'
      expect(config.component_paths).to eq ['/**/*']
      expect(config.component_suffix).to eq '.js'
      expect(config.server_render_function).to eq 'window.render*Server'
      expect(config.client_render_function).to eq 'window.render*Client'
      expect(config.use_asset_pipeline).to eq false
      expect(config.asset_finder_class).to eq nil
      expect(config.should_server_render).to eq true
      expect(config.cache_size).to eq 100
      expect(config.cache_ttl).to eq 600
    end
  end
end
