$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "filters/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "filters"
  s.version     = Filters::VERSION
  s.authors     = ["Aaron Bullard"]
  s.email       = ["aaron.bullard77@gmail.com"]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"

  # s.add_development_dependency "sqlite3"

  s.add_development_dependency "rspec"
end
