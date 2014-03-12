# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mandrill/client/version'

Gem::Specification.new do |spec|
  spec.name          = "mandrill-client"
  spec.version       = Mandrill::Client::VERSION
  spec.authors       = ["Matthieu \"Ezveus\" Ciappara"]
  spec.email         = ["ciappam@gmail.com"]
  spec.description   = %q{Mandrill::Client aims to provide easy access to Mandrill API}
  spec.summary       = %q{Mandrill::Client aims to provide easy access to Mandrill API}
  spec.homepage      = "https://github.com/Ezveus/Mandrill--Client"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
