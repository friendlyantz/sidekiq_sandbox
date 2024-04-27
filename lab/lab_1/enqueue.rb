require_relative "../../prof_gray/satellite_analysis"
require "sidekiq/cli"
require "sidekiq/api"


Sidekiq.redis { |conn|
  conn.flushall
}


number_of_jobs = 60
Sidekiq::Client.push_bulk(
  "class" => "DataProcessor",
  "args" => ProfGraySatelliteAnalysis::Data.retrieve(number_of_jobs)
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
  break if stats.processed >= number_of_jobs
end

if stats.processed == number_of_jobs
  puts "Success - all results processed"
else
  raise "Failure - not all jobs processed. Was: #{stats.processed}"
end
