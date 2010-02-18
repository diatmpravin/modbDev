begin
  require 'resque/tasks'

  task "resque:setup" => :environment
rescue LoadError
  $stderr.puts "*" * 40
  $stderr.puts "The resque gem is required to run it's tasks"
  $stderr.puts "*" * 40
end

namespace :workers do

  desc "
    Start up COUNT (default 1) resque worker(s) that listen on the QUEUE (default '*') queue.
    If you're looking to add to an already existing list of workers, use START to start the
    count at a number other than 0.
    To ignore any existing .dtach files, use FORCE=true, otherwise this task will error out.
  "
  task :start => :environment do
    count = (ENV["COUNT"] || 1).to_i
    queue = ENV["QUEUE"] || "*"
    start = (ENV["START"] || 0).to_i
    force = ENV["FORCE"] == "true"

    puts "Starting up #{count} workers to listen on queue(s) #{queue.inspect}"

    name = queue.gsub(/,/, "_").gsub(/\*/, "all")

    (start...(start + count)).each do |i|
      basename = "resque_worker_#{name}_#{i}"
      dtach_socket = Rails.root.join("tmp", "pids", "#{basename}.dtach")
      pid_file = Rails.root.join("tmp", "pids", "#{basename}.pid")

      # Error out if we hit a detach socket
      if File.exists?(dtach_socket) && !force
        raise "Unable to start worker on #{dtach_socket}. The dtach socket file already exists. " +
                "Fix this or pass in FORCE=true to ignore this check."
      end

      # Start up our new worker via dtach
      puts "Starting worker ##{i} to listen to queue #{queue.inspect}"
      system "dtach -n #{dtach_socket} rake resque:work QUEUE=#{queue}"

      # Now get the pid of the new process and save it.
      # This is a two step process, we need to find the new dtach process, get it's pid,
      # then look at the resque processes, find the one w/ the parentpid of the dtach process,
      # get *its* pid, and finally write that pid out to the pid file
      dtach_pid = `ps -C dtach -o pid=,cmd= | grep #{basename} | awk '{print($1)}'`.strip
      resque_pid = `ps -C rake -o pid=,ppid= | grep #{dtach_pid} | awk '{print($1)}'`.strip

      File.open(pid_file, "w+") { |f| f.write(resque_pid) }
    end
  end

  desc "
    Stop resque workers.
    To stop workers by queue, give QUEUE.
    To stop a specific worker, give QUEUE and COUNT.
    To stop all workers, give ALL=true.
  "
  task :stop => :environment do
    queue = ENV["QUEUE"] || ""
    count = ENV["COUNT"]
    all = ENV["ALL"] == "true"

    if queue.nil? && count.nil? && !all
      raise "Must specify what workers you want to kill. See description for details."
    end

    name = queue.gsub(/,/, "_").gsub(/\*/, "all")

    pid_dir = Rails.root.join("tmp", "pids")
    Dir["#{pid_dir}/*.pid"].each do |pid_file|
      next if !all && pid_file !~ /#{name}/

      if count
        next if pid_file !~ /#{name}_#{count}/
      end

      pid = File.read(pid_file)
      puts "Shutting down #{pid_file} with pid #{pid}"

      `kill -s TERM #{pid}`

      count = 0

      while `ps -C rake -o pid= | grep #{pid}`.strip != ""
        sleep 1
        count += 1

        if count > 20
          puts "Process #{pid} doesn't seem to be dying. You can wait or kill it yourself, this script will wait for you."
          count = 0
        end
      end

      File.unlink(pid_file)
    end
  end

  desc "
    List out all running resque workers.
    Simply outputs a list of the .pid files in the pid dir
  "
  task :list do
    pid_dir = Rails.root.join("tmp", "pids")
    Dir["#{pid_dir}/*.pid"].each do |pid_file|
      pid = File.read(pid_file)
      status = `ps -C rake -o pid= | grep #{pid}`.strip
      puts "#{status == "" ? "( STALE )" : "(Running)"} #{pid_file}"
    end
  end

end
