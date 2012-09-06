require 'bundler'
Bundler.setup

require 'rubygems/package_task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

gem_spec = Gem::Specification.load('idzebra.gemspec')
Gem::PackageTask.new(gem_spec) do |pkg|
  pkg.package_dir = 'pkg'
end

task :default => :spec
