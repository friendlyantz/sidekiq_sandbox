require_relative "app"
require "sidekiq/cli"
require "sidekiq/api"

Sidekiq.redis { |conn|
  conn.flushall
}

sleep 1

150.times do
  Sidekiq::Client.push({"queue" => "bulk", "class" => DataProcessor, "args" => [
    ProfGraySatelliteAnalysis::Data.retrieve(1), {"type" => "b", "enqueued_at" => Time.now.to_f, "within" => 30}
  ]})
end

Thread.new do
  times = 150
  while times > 0
    sleep 0.1
    Sidekiq::Client.push({"queue" => "medium", "class" => DataProcessor, "args" => [
      ProfGraySatelliteAnalysis::Data.retrieve(1), {"type" => "c", "enqueued_at" => Time.now.to_f, "within" => 20}
    ]})
    times -= 1
  end
end

Thread.new do
  times = 150
  while times > 0
    sleep 0.1
    Sidekiq::Client.push({"queue" => "high", "class" => DataProcessor, "args" => [
      ProfGraySatelliteAnalysis::Data.retrieve(1), {"type" => "d", "enqueued_at" => Time.now.to_f, "within" => 10}
    ]})
    times -= 1
  end
end

Thread.new do
  times = 250
  while times > 0
    sleep 0.1
    Sidekiq::Client.push({"queue" => "critical", "class" => DataProcessor, "args" => [
      ProfGraySatelliteAnalysis::Data.retrieve(1), {"type" => "d", "enqueued_at" => Time.now.to_f, "within" => 5}
    ]})
  end
  times -= 1
end

t = Thread.new do
  end_time = Time.now + 30
  while Time.now <= end_time
    bulk_queue_latency_in_seconds = Sidekiq::Queue.new("bulk").latency.round(2)
    med_queue_latency_in_seconds = Sidekiq::Queue.new("medium").latency.round(2)
    high_queue_latency_in_seconds = Sidekiq::Queue.new("high").latency.round(2)
    crit_queue_latency_in_seconds = Sidekiq::Queue.new("critical").latency.round(2)

    Sidekiq.logger.warn(Sidekiq::CLI.r + "*" * 20 + Sidekiq::CLI.reset)
    Sidekiq.logger.warn(
      ["","Bulk latency: #{bulk_queue_latency_in_seconds} ",
      "Medium latency: #{med_queue_latency_in_seconds} ",
      "High latency: #{high_queue_latency_in_seconds} ",
      "Crit latency: #{crit_queue_latency_in_seconds} "].join("\n")
    )
    Sidekiq.logger.warn(Sidekiq::CLI.r + "*" * 20 + Sidekiq::CLI.reset)
    sleep 1
    if Sidekiq::Stats.new.processed == 400
      break
    end
    if Sidekiq::Stats.new.retry_size > 0
      puts "Failure - at least one job did not process in time."
      break
    end
  end

  stats = Sidekiq::Stats.new
  if stats.enqueued > 0
    puts "Failure - not all jobs processed! Processed: #{stats.processed}"
  else
    puts "Success - all jobs processed."
  end
end

t.join