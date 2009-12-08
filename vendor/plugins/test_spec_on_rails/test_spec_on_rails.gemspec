# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{test_spec_on_rails}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Bass"]
  s.date = %q{2009-12-03}
  s.description = %q{Provides helpers to test your Rails app using test/spec.}
  s.email = %q{pelargir@gmail.com}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "lib/generators/controller/USAGE",
     "lib/generators/controller/controller_generator.rb",
     "lib/generators/controller/templates/controller.rb",
     "lib/generators/controller/templates/functional_test.rb",
     "lib/generators/controller/templates/helper.rb",
     "lib/generators/controller/templates/view.html.erb",
     "lib/generators/model/USAGE",
     "lib/generators/model/model_generator.rb",
     "lib/generators/model/templates/fixtures.yml",
     "lib/generators/model/templates/migration.rb",
     "lib/generators/model/templates/model.rb",
     "lib/generators/model/templates/unit_test.rb",
     "lib/test/spec/rails.rb",
     "lib/test/spec/rails/convenience.rb",
     "lib/test/spec/rails/dummy_response.rb",
     "lib/test/spec/rails/should_redirect.rb",
     "lib/test/spec/rails/should_render.rb",
     "lib/test/spec/rails/should_route.rb",
     "lib/test/spec/rails/should_select.rb",
     "lib/test/spec/rails/should_validate.rb",
     "lib/test/spec/rails/should_validate_presence_of.rb",
     "lib/test/spec/rails/test_dummy.rb",
     "lib/test/spec/rails/test_layout.rb",
     "lib/test/spec/rails/test_spec_ext.rb",
     "lib/test/spec/rails/test_status.rb",
     "lib/test/spec/rails/test_template.rb",
     "lib/test/spec/rails/test_unit_ext.rb",
     "lib/test/spec/rails/test_url.rb",
     "lib/test/spec/rails/use_controller.rb",
     "tasks/spec.rake",
     "test/test/spec/rails/test_status_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/pelargir/test_spec_on_rails}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Provides helpers to test your Rails app using test/spec.}
  s.test_files = [
    "test/test/spec/rails/test_status_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

