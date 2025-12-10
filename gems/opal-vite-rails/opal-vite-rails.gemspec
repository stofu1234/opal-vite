require_relative 'lib/opal/vite/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "opal-vite-rails"
  spec.version       = Opal::Vite::Rails::VERSION
  spec.authors       = ["opal-vite contributors"]
  spec.email         = [""]

  spec.summary       = "Rails integration for Opal with Vite"
  spec.description   = "Seamlessly integrate Opal (Ruby to JavaScript compiler) with Rails using Vite for fast development"
  spec.homepage      = "https://github.com/yourusername/opal-vite"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*", "templates/**/*", "README.md", "LICENSE"]
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "opal-vite", Opal::Vite::Rails::VERSION
  spec.add_dependency "railties", ">= 6.0.0"
  spec.add_dependency "actionview", ">= 6.0.0"
  spec.add_dependency "vite_rails", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
end
