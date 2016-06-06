require 'bundler/gem_tasks'
require 'polishgeeks-dev-tools'

desc 'Self check using command maintained in this gem'
task :check do
  PolishGeeks::DevTools.setup do |config|
    config.brakeman = false
  end

  PolishGeeks::DevTools::Runner.new.execute(
    PolishGeeks::DevTools::Logger.new
  )
end
