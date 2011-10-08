require 'rake'

$stdout.sync = true

task :default => :spec

task :spec do
  system "rspec spec/*/*_spec.rb"
end

desc "Run all specs whenever anything changes"
task :stakeout do
  system "rake spec"
  system "stakeout rake spec/*.rb spec/*/*_spec.rb lib/*.rb lib/*/*.rb"
end

