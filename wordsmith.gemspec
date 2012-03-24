# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wordsmith/version"

Gem::Specification.new do |s|
  s.name        = "wordsmith"
  s.version     = Wordsmith::VERSION
  s.authors     = ["Amed Rodriguez", "Javier Saldana", "Rene Cienfuegos"]
  s.email       = ["amed@tractical.com", "javier@tractical.com", "renecienfuegos@gmail.com"]
  s.homepage    = ""
  s.summary     = "E-books publisher."
  s.description = "Create, collaborate and publish e-books -- easily."

  s.rubyforge_project = "wordsmith"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_runtime_dependency "pandoc-ruby"
end
