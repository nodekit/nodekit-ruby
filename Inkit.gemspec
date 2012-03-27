Gem::Specification.new do |s|
  s.name        = 'inkit'
  s.version     = '0.0.1'
  
  s.require_paths = ["./"]

  s.author      = "Szikszai Gusztáv"
  s.email       = 'ink-support@hotmail.com'
  s.homepage    = 'http://inkit.org'
  s.summary     = "Client library for INK."
  s.description = "Client library to pull and render INK views."
  
  s.files = [
   './inkit.rb',
   './Library.rb',
   './Utils.rb',
   './Renderers/Haml.rb',
   './Renderers/Sass.rb',
  ]
  
  s.add_dependency("haml")
  s.add_dependency("sass")
  
end
