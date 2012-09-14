Gem::Specification.new do |s|
  s.name        = 'idzebra'
  s.version     = '0.1.1'
  s.date        = '2012-09-14'
  s.summary     = "Ruby bindings for IdZebra"
  s.description = "Ruby bindings for the Zebra open-source Z39.50/SRU server."
  s.authors     = ["Tim Dettrick"]
  s.homepage    = 'https://github.com/tjdett/idzebra'
  s.email       = 'tim@dettrick.net'
  s.files       = Dir.glob('lib/**/*.rb') +
                  Dir.glob('bin/*')
  s.executables << 'zebraidx_record'
  s.license     = 'Simplified BSD'
  s.required_ruby_version = '>= 1.9.1'
  s.requirements << 'idzebra-2.0'
  s.add_dependency 'ffi'
  s.add_dependency 'trollop'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
