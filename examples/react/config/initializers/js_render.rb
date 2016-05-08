JsRender.configure do |config|
  config.use_asset_pipeline = true
  config.base_path = 'app/assets/javascripts/components'
  config.component_paths = ['/**/*']
  config.component_suffix = '/renderServer.js'
end
