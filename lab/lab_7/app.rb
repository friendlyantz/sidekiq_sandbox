require_relative "../../prof_gray/satellite_analysis"
Sidekiq.logger.level = :warn

require "active_record"
ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "prof_greys_data",
  pool: 5
)
class Result < ActiveRecord::Base
end

class DataProcessor
  include Sidekiq::Worker

  def perform(data, opts)
    result = ProfGraySatelliteAnalysis::Analyzer.analyze_type(data, {"type" => opts["type"]})

    # Uniqueness/idempotency not required in this exercise!
    Result.create!(data: data, analysis_type: opts["type"], result: result)
  end
end