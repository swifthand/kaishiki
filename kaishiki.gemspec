# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kaishiki/version'

Gem::Specification.new do |spec|
  spec.name         = "kaishiki"
  spec.version      = Kaishiki::VERSION
  spec.authors      = ["Paul Kwiatkowski"]
  spec.email        = ["paul@groupraise.com"]
  spec.summary      = "A form object library which marries Virtus for attributes, ActiveModel for validations and Normalizr for normalizations."
  spec.description  = "A form object library which marries Virtus for attributes, ActiveModel for validations and Normalizr for normalizations. Provides several coercions, validations and normalizations. Beyond the default Kaishiki::Form implementation, several common-use form object configurations are provided."
  spec.homepage     = "https://github.com/swifthand/kaishiki"
  spec.license      = "Revised BSD, see LICENSE.md"

  spec.files = Dir['lib/**/*.rb'] + Dir['bin/*']
  spec.files += Dir['[A-Z]*'] + Dir['test/**/*']
  spec.files.reject! { |fn| fn.include? "CVS" }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", "~> 4.0", ">= 4.0.0"
  spec.add_dependency "virtus", "~> 1.0"
  spec.add_dependency "normalizr", "=0.1.1"
  spec.add_development_dependency "bundler",  "~> 1.7"
  spec.add_development_dependency "rake",     "~> 10.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.1"
  spec.add_development_dependency "turn-again-reporter", "~> 1.1", ">= 1.1.0"
  spec.add_development_dependency "activerecord", "~> 4.0", ">= 4.0.0"
  spec.add_development_dependency "sqlite3", "~> 1.3", ">= 1.3.0"
end
