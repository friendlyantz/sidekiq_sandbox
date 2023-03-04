require "sidekiq/client"
require "sidekiq/api"
require_relative "../../prof_gray_satellite_analysis"
require_relative "./prep_env"

client = Sidekiq::Client.new

500.times do
  client.push({
    "queue" => "default",
    "class" => "DataProcessor",
    "args" => [
      ProfGraySatelliteAnalysis::Data.retrieve(1).flatten,
      {"type" => "d"}
    ]
  })
end

STDOUT.flush
stats = Sidekiq::Stats.new
puts("Starting the clock!")
STDOUT.flush
end_time = Time.now + 15
while Time.now <= end_time
  stats.fetch_stats!
  sleep(1)
  if stats.retry_size > 0
    puts Sidekiq::RetrySet.new.each { |j| puts j.item }
    puts "Failure - at least one job failed."
    break
  end
end

if stats.enqueued == 0 && stats.processed == 500
  puts "Success - all results processed"
else
  puts "Results processed: #{stats.processed}/500"
  puts "Enqueued still: #{stats.enqueued}"
  raise "Failure - not all jobs processed"
end
