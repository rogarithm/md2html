# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name                  = %q{md2html}
  s.version               = "0.1.1"
  s.description           = %q{A simple markdown to html converter}
  s.date                  = %q{2024-03-26}

  s.authors               = ["sehoon gim"]
  s.email                 = %q{sehoongim@gmail.com}

  s.files                 = Dir["lib/**/*"]
  s.require_paths         = ["lib"]

  s.required_ruby_version = %q{>= 2.7.2}
  s.rubygems_version      = %q{3.1.4}

  s.license               = %q[MIT]
  s.summary               = %q{It converts basic markdown to html.}
end
