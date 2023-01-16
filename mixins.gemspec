# -*- encoding: utf-8 -*-
# stub: mixins 0.1.0.pre.20250527081241 ruby lib

Gem::Specification.new do |s|
  s.name = "mixins".freeze
  s.version = "0.1.0.pre.20250527081241".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://todo.sr.ht/~ged/Mixins", "changelog_uri" => "https://deveiate.org/code/mixins/History_md.html", "documentation_uri" => "https://deveiate.org/code/mixins", "homepage_uri" => "https://hg.sr.ht/~ged/Mixins", "source_uri" => "https://hg.sr.ht/~ged/Mixins" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2025-05-27"
  s.description = "This is a collection of zero-dependency mixins. They\u2019re intended to be generically useful for building other software, well-tested, and not add any non-stdlib dependencies.".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.files = [".simplecov".freeze, "History.md".freeze, "README.md".freeze, "Rakefile".freeze, "lib/mixins.rb".freeze, "spec/mixins_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://hg.sr.ht/~ged/Mixins".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.5.11".freeze
  s.summary = "This is a collection of zero-dependency mixins.".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.10".freeze])
end
