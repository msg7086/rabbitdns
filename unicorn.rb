worker_processes ENV["RAILS_ENV"] == "production" ? 4 : 1
timeout 15
preload_app false
listen '/tmp/unicorn.sock'
APP_PATH = File.expand_path(File.dirname(__FILE__))
working_directory APP_PATH
stderr_path APP_PATH + "/logs/unicorn.log"
stdout_path APP_PATH + "/logs/unicorn.log"

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
