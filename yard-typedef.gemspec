
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yard/typedef/version"

Gem::Specification.new do |spec|
  spec.name          = YARD::Typedef::NAME
  spec.version       = YARD::Typedef::VERSION
  spec.authors       = [ "nrser" ]
  spec.email         = [ "neil@neilsouza.com" ]

  spec.summary       = %q{A YARD plugin to define and use type }
  # spec.description   = 
  spec.homepage      = "https://github.com/nrser/yard-typedef"
  spec.license       = "BSD"
  
  spec.files        = Dir[ "lib/**/*.rb" ] +
                      %w(LICENSE.txt README.md NAME VERSION)

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep( %r{^exe/} ) { |f| File.basename(f) }
  spec.require_paths = [ "lib" ]
  
  spec.required_ruby_version \
                      = '>= 2.3.0'

  # Dependencies
  # ============================================================================
  
  # Runtime Dependencies
  # ----------------------------------------------------------------------------

  spec.add_dependency "yard"
  
  
  # Development Dependencies
  # ----------------------------------------------------------------------------

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3"
  
  ### Pry - Nicer REPL experience & CLI-based debugging ###
  
  spec.add_development_dependency "pry", '~> 0.11.3'

  # Supposed to drop into pry as a debugger on unhandled exceptions, but I 
  # haven't gotten to test it yet
  spec.add_development_dependency "pry-rescue", '~> 1.4.5'

  # Move around the stack when you debug with `pry`, really sweet
  spec.add_development_dependency "pry-stack_explorer", '~> 0.4.9'
  
  
  ### YARD - Doc Generation ###

  # Provider for `commonmarker`, the new GFM lib
  spec.add_development_dependency 'yard-commonmarker', '~> 0.5.0'
  
  # My `yard clean` command
  spec.add_development_dependency 'yard-clean', '~> 0.1.0'
  
  
  ### Doctest - Exec-n-check YARD @example tags
  
  spec.add_development_dependency 'yard-doctest', '~> 0.1.16'

end
