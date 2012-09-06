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
  s.license     = 'Simplified BSD'
  s.required_ruby_version = '>= 1.9.1'
  s.requirements << 'idzebra-2.0'
  s.add_dependency 'ffi'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
