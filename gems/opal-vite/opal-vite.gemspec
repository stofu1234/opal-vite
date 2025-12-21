require_relative 'lib/opal/vite/version'

Gem::Specification.new do |spec|
  spec.name          = "opal-vite"
  spec.version       = Opal::Vite::VERSION
  spec.authors       = ["stofu1234"]
  spec.email         = [""]

  spec.summary       = "Integrate Opal with Vite"
  spec.description   = "Compile Ruby to JavaScript using Opal and Vite for fast development"
  spec.homepage      = "https://stofu1234.github.io/opal-vite/"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*", "opal/**/*", "bin/*", "README.md", "LICENSE"]
  end
  spec.bindir        = "bin"
  spec.executables   = ["opal-vite"]
  spec.require_paths = ["lib"]

  spec.add_dependency "opal", "~> 1.8"
  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "base64", "~> 0.2"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
end
