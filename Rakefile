require 'bundler'
Bundler.setup

require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'yard'

task :default => [:spec, :yard]

RSpec::Core::RakeTask.new

gem_spec = Gem::Specification.load('idzebra.gemspec')
Gem::PackageTask.new(gem_spec) do |pkg|
  pkg.package_dir = 'pkg'
end

YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"]
  t.options = ['--output-dir', 'doc']
end