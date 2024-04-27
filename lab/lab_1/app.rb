require_relative "../../prof_gray/satellite_analysis"
require_relative "logger_thread"

Sidekiq.logger.level = :warn

class DataProcessor
  include Sidekiq::Worker

  def perform(data)
    sleep 2
    ProfGraySatelliteAnalysis::Analyzer.analyze_type(data, {"type" => "a"})
  end
end
