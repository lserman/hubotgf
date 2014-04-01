$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hubotgf/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hubotgf"
  s.version     = HubotGF::VERSION
  s.authors     = ['Logan Serman']
  s.email       = ['loganserman@gmail.com']
  s.homepage    = 'TODO GITHUB URL'
  s.summary     = 'TODO'
  s.description = s.summary

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.4"
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "sidekiq"
  s.add_development_dependency "resque"
  s.add_development_dependency "webmock"

end
