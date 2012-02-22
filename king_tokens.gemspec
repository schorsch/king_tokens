# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'king_tokens/version'

Gem::Specification.new do |s|
  s.name = %q{king_tokens}
  s.summary = %q{Access tokens for any active record object}
  s.description = %q{Tokens are a usefull way to give users access to an application. This can be for a limited time or just once. Just think of password resets, changing email, protected rss feed urls, timed out private links}
  s.version = KingTokens::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Georg Leciejewski", "Michael Bumann"]
  s.date = %q{2010-05-04}
  s.email = %q{gl@salesking.eu}
  s.homepage = %q{http://github.com/schorsch/king_tokens}

  s.extra_rdoc_files = ["README.rdoc"]
  s.require_paths = ["lib"]

  s.rubygems_version = %q{1.6.2}

  s.executables   = nil
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_paths = ["lib"]

  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'sqlite3'

end

