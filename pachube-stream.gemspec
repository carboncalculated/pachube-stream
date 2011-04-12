# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pachube-stream/version"

Gem::Specification.new do |s|
  s.name        = "pachube-stream"
  s.version     = Pachube::Stream::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Hookercookerman"]
  s.email       = ["hookercookerman@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Pachube TCP streaming API}
  s.description = %q{Simple Ruby client library for pachube TCP streaming API. Uses EventMachine for connection handling.JSON format only.}

  s.rubyforge_project = "pachube-stream"
  
  s.add_dependency "eventmachine", ">= 1.0.0.beta.3"
  s.add_dependency "addressable", ">= 2.2.3"
  s.add_dependency "hashie", ">= 0.5.1"
  s.add_dependency 'yajl-ruby', '~> 0.8.2'
  s.add_dependency 'uuid', '~> 2.3.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
