require "sidekiq/client"
require "sidekiq/api"
require_relative "../../prof_gray_satellite_analysis"
require_relative "./app"

require "sidekiq"
Sidekiq.redis { |conn|
  conn.flushall
}

client = Sidekiq::Client.new

client.push({
  "queue" => "default",
  "class" => "DataProcessor",
  "args" => ["4b5a43498edfc5a7f1fcff79b9d3c9e3"]
})

STDOUT.flush
stats = Sidekiq::Stats.new
puts("Starting the clock!")
STDOUT.flush
end_time = Time.now + 7
while Time.now <= end_time
  stats.fetch_stats!
  sleep(1)
  if stats.retry_size > 0
    puts Sidekiq::RetrySet.new.each { |j| puts j.item }
    puts "Failure - at least one job failed."
    break
  end
  break if stats.processed == 1
end

if stats.processed == 1
  puts "Success - all results processed"
else
  raise "Failure - not all jobs processed. Processed: #{stats.processed}"
end
