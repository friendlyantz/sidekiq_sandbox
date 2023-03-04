require "sidekiq"
require_relative "../../prof_gray/satellite_analysis"
Sidekiq.logger.level = :warn

class DataProcessor
  include Sidekiq::Worker

  def perform(data, type)
    ProfGraySatelliteAnalysis::Analyzer.analyze_type(data, type)
  end
end