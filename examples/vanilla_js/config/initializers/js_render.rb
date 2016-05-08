JsRender.configure do |config|
  config.base_path = 'app/assets/javascripts/components'
  config.component_paths = ['/**/*']
  config.component_suffix = '/(index|renderServer).js'
end
