require "active_record"

ActiveRecord::Tasks::DatabaseTasks.create(adapter: "postgresql", database: "prof_greys_data")
ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "prof_greys_data")

ActiveRecord::Base.connection.execute "ALTER SYSTEM SET max_connections TO '100';"

puts "Reset max connections to 100."