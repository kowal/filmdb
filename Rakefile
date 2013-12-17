require "bundler/gem_tasks"
require 'rvm-tester'

RVM::Tester::TesterTask.new(:suite) do |t|
  t.bundle_install = false
  t.use_travis     = true
  t.command        = "bundle exec rspec"
end
