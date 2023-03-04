require_relative "app"
require "sidekiq/cli"
require "sidekiq/api"

Sidekiq.redis { |conn|
  conn.flushall
}

sleep 3

50.times do
  Sidekiq::Client.push({"queue" => "bulk", "class" => DataProcessor, "args" => [
    ProfGraySatelliteAnalysis::Data.retrieve(1), {"type" => "c", "enqueued_at" => Time.now.to_f, "within" => 30}
  ]})
end
20.times do
  Sidekiq::Client.push({"queue" => "medium", "class" => DataProcessor, "args" => [
    ProfGraySatelliteAnalysis::Data.retrieve(1), {"type" => "c", "enqueued_at" => Time.now.to_f, "within" => 15}
  ]})
end
20.times do
  Sidekiq::Client.push({"queue" => "high", "class" => DataProcessor, "args" => [
    ProfGraySatelliteAnalysis::Data.retrieve(1), {"type" => "c", "enqueued_at" => Time.now.to_f, "within" => 10}
  ]})
end
10.times do
  Sidekiq::Client.push({"queue" => "critical", "class" => DataProcessor, "args" => [
    ProfGraySatelliteAnalysis::Data.retrieve(1), {"type" => "c", "enqueued_at" => Time.now.to_f, "within" => 5}
  ]})
end

end_time = Time.now + 30
while Time.now <= end_time
  bulk_queue_latency_in_seconds = Sidekiq::Queue.new("bulk").latency.round(2)

  Sidekiq.logger.warn(Sidekiq::CLI.r + "*" * 20 + Sidekiq::CLI.reset)
  Sidekiq.logger.warn(
    "Bulk latency: #{bulk_queue_latency_in_seconds} "
  )
  Sidekiq.logger.warn(Sidekiq::CLI.r + "*" * 20 + Sidekiq::CLI.reset)
  sleep 1
  if Sidekiq::Stats.new.processed == 100
    break
  end
  if Sidekiq::Stats.new.retry_size > 0
    puts "Failure - at least one job did not process in time."
    break
  end
end

stats = Sidekiq::Stats.new
if stats.enqueued > 0
  raise "Failure - not all jobs processed. Processed: #{stats.processed}"
else
  puts "Success - all jobs processed."
end


