require_relative "app"
require "sidekiq/cli"
require "sidekiq/api"

Sidekiq.redis { |conn|
  conn.flushall
}

args = Array.new(10) { [ProfGraySatelliteAnalysis::Data.retrieve(1), {"type" => "c"} ]}
t = Thread.new do
  while true
    Sidekiq::Client.push_bulk(
      "class" => "DataProcessor",
      "args" => args
    )
    sleep 1
  end
end

while true
  stats = Sidekiq::Stats.new

  Sidekiq.logger.warn(Sidekiq::CLI.r + "*" * 20 + Sidekiq::CLI.reset)
  Sidekiq.logger.warn(
    "Default latency: #{stats.default_queue_latency.round} \n" +
    "Processed jobs: #{stats.processed}"
  )
  Sidekiq.logger.warn(Sidekiq::CLI.r + "*" * 20 + Sidekiq::CLI.reset)
  sleep 5
end
