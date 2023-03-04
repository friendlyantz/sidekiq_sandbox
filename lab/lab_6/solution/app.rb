require_relative "../../prof_gray_satellite_analysis"
require "active_record"
ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "prof_greys_data")
class Result < ActiveRecord::Base
end

class DataProcessor
  include Sidekiq::Worker

  def perform(data, opts)
    begin
      result_record = Result.find_or_create_by(data: data, analysis_type: opts["type"])
      result_record.with_lock do
        result_record.reload && return if result_record.result
        result_record.result = ProfGraySatelliteAnalysis::Analyzer.analyze_type(data, {"type" => opts["type"]})
        result_record.save!
      end
    rescue
      false # Record was already processed - we're good.
    end
  end
end