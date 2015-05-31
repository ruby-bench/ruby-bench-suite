# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'noop/gem/version'

Gem::Specification.new do |spec|
  spec.name          = "noop-gem"
  spec.version       = Noop::Gem::VERSION
  spec.authors       = ["Samuel E. Giddins"]
  spec.email         = ["segiddins@segiddins.me"]
  spec.summary       = ''

  spec.files         = Dir["{lib,bin}/**/*"]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
