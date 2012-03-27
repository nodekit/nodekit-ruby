Gem::Specification.new do |s|
  s.name        = 'inkit'
  s.version     = '0.0.12'
  
  s.require_paths = ["./lib"]

  s.author      = "Szikszai Gusztáv"
  s.email       = 'ink-support@hotmail.com'
  s.homepage    = 'http://inkit.org'
  s.summary     = "Client library for INK."
  s.description = "Client library to pull and render INK views."
  
  s.files = [
   './lib/inkit.rb',
   './lib/cache.rb'
  ]
  
  s.test_files = Dir.glob('test/*')
  
  s.add_dependency("mustache")
  
end
