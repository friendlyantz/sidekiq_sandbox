require_relative "../../prof_gray/satellite_analysis"
require "sidekiq/cli"
require "sidekiq/api"

Sidekiq.redis { |conn|
  conn.flushall
}

Sidekiq::Client.push_bulk(
  "class" => "DataProcessor",
  "args" => ProfGraySatelliteAnalysis::Data.retrieve(30)
)

STDOUT.flush
stats = Sidekiq::Stats.new
puts("Starting the clock!")
STDOUT.flush
end_time = Time.now + 30
while Time.now <= end_time
  stats.fetch_stats!
  sleep(1)
  if stats.retry_size > 0
    puts Sidekiq::RetrySet.new.each { |j| puts j.item }
    puts "Failure - at least one job failed."
    break
  end
  break if stats.processed >= 30
end

if stats.processed == 30
  puts "Success - all results processed"
else
  raise "Failure - not all jobs processed. Was: #{stats.processed}"
end
