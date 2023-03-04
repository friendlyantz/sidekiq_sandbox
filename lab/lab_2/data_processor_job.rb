require_relative "../../prof_gray/satellite_analysis"

class DataProcessor
  include Sidekiq::Worker
  sidekiq_options retry: 0

  def perform(data, type)
    Timeout::timeout(1.8) do
      ProfGraySatelliteAnalysis::Analyzer.analyze_type(data, type)
    end
  end
end
