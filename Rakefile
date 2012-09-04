require 'bundler'
Bundler.setup

require 'rake/extensiontask'
require 'rspec/core/rake_task'

Rake::ExtensionTask.new('idzebra') do |ext|
  ext.lib_dir = 'lib/idzebra'
end

RSpec::Core::RakeTask.new

task :spec => :compile
task :default => :spec
