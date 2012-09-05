Gem::Specification.new do |s|
  s.name        = 'idzebra'
  s.version     = '0.0.1'
  s.date        = '2012-09-04'
  s.summary     = "Ruby bindings for IdZebra"
  s.authors     = ["Tim Dettrick"]
  s.email       = 'tim@dettrick.net'
  s.files       = Dir.glob('lib/**/*.rb') +
                  Dir.glob('ext/**/*.{c,h,rb}')
  s.extensions  = ['ext/idzebra/extconf.rb']
  s.add_dependency 'ffi'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
