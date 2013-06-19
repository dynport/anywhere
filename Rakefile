require "bundler/gem_tasks"

task :version_commit do
  require File.expand_path("../lib/anywhere/version.rb", __FILE__)
  cmd = "git add lib/anywhere/version.rb && git commit -m 'version #{Anywhere::VERSION}'"
  system cmd
end
