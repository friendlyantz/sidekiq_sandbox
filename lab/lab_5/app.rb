require "sidekiq"
require_relative "../../prof_gray/satellite_analysis"
Sidekiq.redis { |conn|
  conn.flushall
}

Sidekiq.logger.level = :warn

class DataProcessor
  include Sidekiq::Worker

  def perform(data, opts)
    ProfGraySatelliteAnalysis::Analyzer.analyze_type(data, {"type" => opts["type"]})

    time_since_enqueued = Time.now - Time.at(opts["enqueued_at"])

    unless time_since_enqueued <= opts["within"]
      puts "Time since enqueued: #{time_since_enqueued}"
      puts "Process within: #{opts["within"]}"
      raise "Failed to process within allotted time!"
    end
  end
end