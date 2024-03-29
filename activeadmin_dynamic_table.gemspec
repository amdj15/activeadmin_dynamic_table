# frozen_string_literal: true

require_relative "lib/activeadmin_dynamic_table/version"

Gem::Specification.new do |spec|
  spec.name = "activeadmin_dynamic_table"
  spec.version = ActiveadminDynamicTable::VERSION
  spec.authors = ["Anton Biliaiev"]
  spec.email = ["amdj15@gmail.com"]

  spec.summary = "Config activeadmin index tables on demand"
  spec.description = "Allow to controll activeadmin table columns from the UI. (Show/hide/resize/reorder table columns)"
  spec.homepage = "https://github.com/amdj15/activeadmin_dynamic_table"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activeadmin", ">= 2.9", "< 4.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
