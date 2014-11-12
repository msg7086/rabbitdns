require 'grape'
require 'active_record'
require 'redis'
require 'rest_client'
require 'whois'
require 'json'

use ActiveRecord::ConnectionAdapters::ConnectionManagement
Dir[File.dirname(__FILE__) + "/app/*/*.rb"].each {|file| require file }
require File.dirname(__FILE__) + "/app/dns.rb"

ActiveRecord::Base.logger = Logger.new('debug.log')
database = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(database['development'])
$config = YAML::load(IO.read('config/core.yml'))
$redis = Redis.new

run RabbitHouse::DNS
