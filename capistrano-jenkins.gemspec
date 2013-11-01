# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "capistrano-jenkins"
  s.version     = "0.1.4"
  s.authors     = ["Martin Jonsson"]
  s.email       = ["martin.jonsson@gmail.com"]
  s.homepage    = "http://github.com/martinj/capistrano-jenkins"
  s.summary     = "Capistrano Jenkins recipe"
  s.description = "Capistrano recipe to validate the build on jenkins status before deploying"
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.license = 'MIT'
end