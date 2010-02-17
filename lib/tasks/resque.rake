begin
  require 'resque/tasks'

  task "resque:setup" => :environment
rescue LoadError
  $stderr.puts "*" * 40
  $stderr.puts "The resque gem is required to run it's tasks"
  $stderr.puts "*" * 40
end
