require 'spec_helper'
require 'json'

describe JsRender::Renderer do
  let (:stubbed_uuid) { '123-abc' }
  let (:todo_renderer) do
    JsRender::Renderer.new 'TodoList', {
      items: [
        {task: 'Task one', status: 'done'},
        {task: 'Do stuff', status: 'incomplete'}
      ]
    }
  end
  let (:box_renderer) { JsRender::Renderer.new 'Box', {value: 'box data'} }
  let (:split_renderer) { JsRender::Renderer.new 'SplitComponent', 'null' }
  let (:error_renderer) { JsRender::Renderer.new 'Box', 'invalid json' }
  before(:each) do
    allow(SecureRandom).to receive(:uuid) { stubbed_uuid }
  end
  after(:each) do
    JsRender.reset
  end

  describe '#initialize' do
    it 'sets instance variables' do
      renderer = JsRender::Renderer.new 'MyComponent', 'data'
      expect(renderer.component_name).to eq 'MyComponent'
      expect(renderer.json_data).to eq 'data'
      expect(renderer.uuid).to eq stubbed_uuid
    end

    context 'data is a string' do
      it 'uses string data' do
        renderer = JsRender::Renderer.new 'MyComponent', 'string'
        expect(renderer.json_data).to eq 'string'
      end
    end

    context 'data reponds to "to_json"' do
      it 'converts data to JSON' do
        renderer = JsRender::Renderer.new 'MyComponent', {a: 1, b: 2}
        expect(renderer.json_data).to eq '{"a":1,"b":2}'
      end
    end

    context 'data does not repond to "to_json"' do
      it 'throws error' do
        class Object
          undef_method(:to_json)
        end
        expect{JsRender::Renderer.new 'MyComponent', Object.new}.to raise_error(NoMethodError)
      end
    end
  end

  describe '#generate_html' do
    context 'should_server_render config is false' do
      it 'returns an empty span' do
        JsRender.config.should_server_render = false
        expect(todo_renderer.generate_html).to eq "<span id=\"#{stubbed_uuid}\"></span>"
      end
    end

    context 'server render function undefined' do
      it 'returns an empty span' do
        JsRender.config.server_render_function = 'notHere'
        expect(todo_renderer.generate_html).to eq "<span id=\"#{stubbed_uuid}\"></span>"
      end
    end

    context 'component is a file' do
      it 'returns HTML string' do
        JsRender.configure do |config|
          config.base_path = 'spec/js_assets'
          config.component_paths = ['/*']
          config.component_suffix = '.js'
        end
        expected = <<-HTML
          <span id="#{stubbed_uuid}">
            <ul>
              <li class="done">Task one</li>
              <li class="incomplete">Do stuff</li>
            </ul>
          </span>
        HTML
        expect(todo_renderer.generate_html).to eq clean_heredoc_html(expected)
      end
    end

    context 'component is a folder' do
      it 'returns HTML string' do
        JsRender.configure do |config|
          config.base_path = 'spec/js_assets'
          config.component_paths = ['/**/*']
          config.component_suffix = '/index.js'
        end
        expected = <<-HTML
          <span id="#{stubbed_uuid}">
            <box>box data</box>
          </span>
        HTML
        expect(box_renderer.generate_html).to eq clean_heredoc_html(expected)
      end
    end

    context 'render function name configured' do
      it 'returns HTML string' do
        JsRender.configure do |config|
          config.base_path = 'spec/js_assets'
          config.component_paths = ['/**/*']
          config.component_suffix = '/index.js'
          config.server_render_function = 'serverRender*'
        end
        expected = <<-HTML
          <span id="#{stubbed_uuid}">
            <box>box data</box>
          </span>
        HTML
        expect(box_renderer.generate_html).to eq clean_heredoc_html(expected)
      end
    end

    context 'component split into multiple files' do
      it 'returns HTML string' do
        JsRender.configure do |config|
          config.base_path = 'spec/js_assets'
          config.component_paths = ['/**/*']
          config.component_suffix = '/(index|serverRenderer).js'
        end
        expected = <<-HTML
          <span id="#{stubbed_uuid}">
            <div>Split Component</div>
          </span>
        HTML
        expect(split_renderer.generate_html).to eq clean_heredoc_html(expected)
      end
    end

    context 'with ExecJS error' do
      it 'returns HTML string' do
        expect{error_renderer.generate_html}.to raise_error(JsRender::Errors::ServerRenderError)
      end
    end
  end

  describe '#generate_client_script' do
    it 'returns a script tag calling specified function with data passed in' do
        expected = <<-HTML
        <script>
          typeof window.renderBoxClient === 'function' && window.renderBoxClient('#{stubbed_uuid}', {"value":"box data"});
        </script>
        HTML
        expect(box_renderer.generate_client_script).to eq expected
    end

    context 'client render function name configured' do
    it 'returns a script tag calling specified function with data passed in' do
      JsRender.config.client_render_function = 'init*Func'
        expected = <<-HTML
        <script>
          typeof initBoxFunc === 'function' && initBoxFunc('#{stubbed_uuid}', {"value":"box data"});
        </script>
        HTML
        expect(box_renderer.generate_client_script).to eq expected
    end
    end
  end

  describe '#render_component' do
    it 'renders HTML and script' do
      JsRender.configure do |config|
        config.base_path = 'spec/js_assets'
        config.component_paths = ['/**/*']
        config.component_suffix = '/index.js'
      end
      expected = <<-HTML
        <span id="#{stubbed_uuid}">
          <box>box data</box>
        </span>
        <script>
          typeof window.renderBoxClient === 'function' && window.renderBoxClient('#{stubbed_uuid}', {"value":"box data"});
        </script>
      HTML
      expect(clean_heredoc_html(box_renderer.render_component)).to eq clean_heredoc_html(expected)
    end
  end
end
