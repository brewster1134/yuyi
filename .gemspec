# coding: utf-8
Gem::Specification.new do |s|
  s.author = 'Ryan Brewster'
  s.bindir = 'bin'
  s.date = '2014-07-21'
  s.description = 'Maintain a menu of applications and services to automate the installation'
  s.email = 'brewster1134@gmail.com'
  s.executables = ["yuyi"]
  s.files = ["Gemfile", "Gemfile.lock", "Guardfile", "README.md", "Rakefile", "bin/yuyi", "lib/yuyi.rb", "lib/yuyi/cli.rb", "lib/yuyi/core.rb", "lib/yuyi/dsl.rb", "lib/yuyi/menu.rb", "lib/yuyi/roll.rb", "lib/yuyi/source.rb", "lib/yuyi/ui.rb", "spec/fixtures/menu.yaml", "spec/fixtures/menu2.yaml", "spec/fixtures/roll_dir/foo_roll.rb", "spec/fixtures/roll_dir/foo_roll_model.rb", "spec/fixtures/roll_dir/nested/bar_roll.rb", "spec/fixtures/roll_zip.zip", "spec/lib/yuyi/cli_spec.rb", "spec/lib/yuyi/core_spec.rb", "spec/lib/yuyi/dsl_spec.rb", "spec/lib/yuyi/menu_spec.rb", "spec/lib/yuyi/roll_spec.rb", "spec/lib/yuyi/source_spec.rb", "spec/lib/yuyi/ui_spec.rb", "spec/lib/yuyi_spec.rb", "spec/roll_validator.rb", "spec/spec_helper.rb", "yuyi_menu", ".gitignore", ".new", ".rspec", ".ruby-version", ".travis.yml"]
  s.homepage = 'https://github.com/brewster1134/Yuyi'
  s.license = 'MIT'
  s.name = 'yuyi'
  s.summary = 'Automation for installing/uninstalling/updating your machine environment'
  s.test_files = ["spec/fixtures/roll_dir/foo_roll.rb", "spec/fixtures/roll_dir/foo_roll_model.rb", "spec/fixtures/roll_dir/nested/bar_roll.rb", "spec/lib/yuyi/cli_spec.rb", "spec/lib/yuyi/core_spec.rb", "spec/lib/yuyi/dsl_spec.rb", "spec/lib/yuyi/menu_spec.rb", "spec/lib/yuyi/roll_spec.rb", "spec/lib/yuyi/source_spec.rb", "spec/lib/yuyi/ui_spec.rb", "spec/lib/yuyi_spec.rb", "spec/roll_validator.rb", "spec/spec_helper.rb"]
  s.version = '1.1.4'
  s.add_runtime_dependency 'thor', '>= 0'
  s.add_development_dependency 'guard', '>= 0'
  s.add_development_dependency 'guard-rspec', '>= 0'
  s.add_development_dependency 'new', '>= 0'
  s.add_development_dependency 'rake', '>= 0'
  s.add_development_dependency 'terminal-notifier-guard', '>= 0'
end
