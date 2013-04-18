$LOAD_PATH.unshift 'lib'
require 'wordsmith/version'

Gem::Specification.new do |gem|
  gem.name        = "wordsmith"
  gem.version     = Wordsmith::VERSION
  gem.authors     = ["Amed Rodriguez", "Javier Saldana", "Rene Cienfuegos"]
  gem.email       = ["amed@tractical.com", "javier@tractical.com", "rene@tractical.com"]
  gem.homepage    = "https://github.com/tractical/wordsmith"
  gem.summary     = "The best way to publish ebooks. No, really."
  gem.description = "Create, collaborate and publish ebooks easily."
  gem.executables = "wordsmith"
  gem.license     = "MIT"

  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.add_dependency "nokogiri",  ">= 1.5.2"
  gem.add_dependency "kindlegen", ">= 2.3.1"
  gem.add_dependency "git"

  gem.add_development_dependency "sass", ">= 3.1"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit"
end
