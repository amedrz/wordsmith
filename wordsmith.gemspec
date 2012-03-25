# encoding: utf-8
$LOAD_PATH.unshift 'lib'
require "wordsmith/version"

Gem::Specification.new do |s|
  s.name        = "wordsmith"
  s.version     = Wordsmith::VERSION
  s.authors     = ["Amed Rodriguez", "Javier Saldana", "Rene Cienfuegos"]
  s.email       = ["amed@tractical.com", "javier@tractical.com", "renecienfuegos@gmail.com"]
  s.homepage    = "https://github.com/tractical/wordsmith"
  s.summary     = "E-books publisher."
  s.description = "Create, collaborate and publish e-books -- easily."
  s.has_rdoc    = false

  s.rubyforge_project = "wordsmith"

  s.executables   = %w( wordsmith )
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_dependency('nokogiri')
  s.add_dependency('kindlegen')
  s.add_development_dependency("rake")
  s.add_development_dependency("test-unit")
end
