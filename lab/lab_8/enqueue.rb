require "sidekiq/client"
require "sidekiq/api"
require_relative "../../prof_gray_satellite_analysis"require_relative "./prep_env"
require_relative "./app"

client = Sidekiq::Client.new

TYPES = %w[a b c d]
100.times do
  client.push({
    "queue" => "default",
    "class" => "DataProcessor",
    "args" => [
      ProfGraySatelliteAnalysis::Data.retrieve(1).flatten,
      {"type" => TYPES.sample}
    ]
  })
end

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
  break if stats.enqueued == 0
end

if stats.enqueued == 0
  puts "Success - all results processed"
else
  raise "Failure - not all jobs processed"
end
