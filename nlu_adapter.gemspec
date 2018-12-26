
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nlu_adapter/version"

Gem::Specification.new do |spec|
  spec.name          = "nlu_adapter"
  spec.version       = NluAdapter::VERSION
  spec.authors       = ["Girish"]
  spec.email         = ["getgirish@gmail.com"]

  spec.summary       = %q{NLU Adapter - An adapter for various NLU web services}
  spec.description   = %q{An adapter for various NLU web services like Aws Lex, Google Dialogflow etc.}
  spec.homepage      = "https://rubygems.org/gems/nlu_adapter"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/technopreneurG/nlu_adapter_ruby"
    spec.metadata["changelog_uri"] = "https://github.com/technopreneurG/nlu_adapter_ruby/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.8"

  #Official AWS Ruby gem for Amazon Lex Runtime Service. This gem is part of the AWS SDK for Ruby.
  spec.add_dependency('aws-sdk-lex', '1.9')
  spec.add_dependency('aws-sdk-lexmodelbuildingservice', '1.12')
 
  #google-cloud-dialogflow is the official library for Dialogflow API.
  spec.add_dependency('google-cloud-dialogflow', '0.2.3')

end
