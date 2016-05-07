require 'spec_helper'

describe JsRender do
  it 'has a version number' do
    expect(JsRender::VERSION).not_to be nil
  end

  it 'has a configuration class' do
    expect(JsRender::Configuration).not_to be nil
  end

  it 'has a renderer class' do
    expect(JsRender::Renderer).not_to be nil
  end
end
