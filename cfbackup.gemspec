Gem::Specification.new do |s|
  s.name = %q{cfbackup}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jon Stacey"]
  s.date = %q{2009-04-18}
  s.default_executable = %q{cfbackup}
  s.email = %q{jon@jonsview.com}
  s.executables = ["cfbackup"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown"
  ]
  s.files = [
    "CFBackup.gemspec",
    "CHANGELOG.markdown",
    "LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION.yml",
    "bin/cfbackup",
    "lib/OptCFBackup.rb",
    "lib/cfbackup.rb",
    "test/cfbackup_test.rb",
    "test/data.txt",
    "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jmstacey/cfbackup}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{TODO}
  s.test_files = [
    "test/cfbackup_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<jmstacey-ruby-cloudfiles>, [">= 1.3.3"])
    else
      s.add_dependency(%q<jmstacey-ruby-cloudfiles>, [">= 1.3.3"])
    end
  else
    s.add_dependency(%q<jmstacey-ruby-cloudfiles>, [">= 1.3.3"])
  end
end
