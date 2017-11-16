
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rails/memwatch/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-memwatch"
  spec.version       = Rails::Memwatch::VERSION
  spec.authors       = ["shvetsovdm"]
  spec.email         = ["sorrows@mail.ru"]

  spec.summary       = %q{Rails memory watcher}
  spec.description   = %q{Report when memory exceeds a limit}
  spec.homepage      = "https://github.com/farpostdesign/rails-memwatch"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org/"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rails", ">= 4.2.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "3.7.0"
  spec.add_development_dependency "rspec-rails", "3.7.1"
  spec.add_development_dependency "capybara", "2.16.0"
  spec.add_development_dependency "sentry-raven", "2.7.1"
end
