# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rooftop/rails/extras/version'

Gem::Specification.new do |spec|
  spec.name          = "rooftop-rails-extras"
  spec.version       = Rooftop::Rails::Extras::VERSION
  spec.authors       = ["Ed Jones"]
  spec.email         = ["ed@errorstudio.co.uk"]
  spec.summary       = %q{A selection of handy mixins for building Rails sites quickly with Rooftop}
  spec.description   = %q{A selection of handy mixins for building Rails sites quickly with Rooftop}
  spec.homepage      = "https://github.org/rooftopcms/rooftop-rails-extras"
  spec.license       = "GPL-3.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_dependency 'require_all', '~> 1.3'
  spec.add_dependency 'rooftop-rails', '~>0.1.0'
  spec.add_dependency 'mail_form', '~> 1.6'


end
