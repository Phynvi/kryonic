# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'kryonic/version'

Gem::Specification.new do |s|
  s.name        = 'kryonic'
  s.version     = Kryonic::VERSION
  s.authors     = ['jimsmi6', 'cursedchild']
  s.email       = ['support@kryonic.com']
  s.homepage    = 'http://github.com/kryonic/kryonic'
  s.summary     = 'placeholder'
  s.description = 'placeholder'

  s.require_paths    = ['lib']
  s.files            = `git ls-files`.split("\n")
  s.extra_rdoc_files = %w( README.md CHANGELOG.md LICENSE )
  s.executables      = 'kryonic'

  s.add_runtime_dependency 'eventmachine',      '~> 0.12'
  s.add_runtime_dependency 'sqlite3',           '~> 1.3'
  s.add_runtime_dependency 'to_regexp',         '~> 0.1'
  s.add_runtime_dependency 'xml-simple',        '~> 1.1'
  s.add_runtime_dependency 'rufus-scheduler',   '~> 2.0'
  s.add_runtime_dependency 'logging',           '~> 1.3'
end
