Sidekiq.redis { |conn|
  conn.flushall
}

arg = ARGV[0].dup
if !arg 
  puts "No argument - assuming type A"
  arg = "a"
end
arg.downcase!

require_relative "data_processor_job"

Sidekiq::Client.push_bulk(
  "class" => DataProcessor, 
  "args" => ProfGraySatelliteAnalysis::Data.retrieve(100).map { |a| a << { type: arg }}
)

Thread.new do 
  stats = Sidekiq::Stats.new
  while true
    sleep(1)
    stats.fetch_stats!

    if stats.dead_size > 0 
      puts "*" * 80
      puts "Failure! Latency limit exceeded by at least 1 job"
      puts "*" * 80 
      exit(1) 
    end

    if stats.queues["default"] == 0
      puts "Success!"
      exit(0) 
    end
  end
end
