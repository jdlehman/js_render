# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'js_render/version'

Gem::Specification.new do |spec|
  spec.name          = "js_render"
  spec.version       = JsRender::VERSION
  spec.authors       = ["Jonathan Lehman"]
  spec.email         = ["jonathan.lehman91@gmail.com"]

  spec.summary       = %q{Render JavaScript components on the server side with Ruby.}
  spec.description   = %q{Render JavaScript components on the server side with Ruby.}
  spec.homepage      = "http://github.com/jdlehman/js_render"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "execjs"
  spec.add_dependency "lru_redux"
end
