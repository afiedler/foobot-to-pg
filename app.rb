require 'active_record'
require 'dotenv'
require 'logger'

Dotenv.load

if ENV['RUBY_ENV'] == 'development'
  ActiveRecord::Base.logger = Logger.new('./tmp/debug.log')
elsif ENV['RUBY_ENV'] == 'production'
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])