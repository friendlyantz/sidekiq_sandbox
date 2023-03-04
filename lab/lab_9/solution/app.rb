require_relative "../../prof_gray_satellite_analysis"
Sidekiq.logger.level = :warn

class DataProcessor
  include Sidekiq::Worker

  def perform(data)
    analyzed = ProfGraySatelliteAnalysis::Analyzer.analyze_type(data, {"type" => "e"})
    data = Array.new(100_000) { analyzed }

    result = data.reduce("") { |memo, str| memo << str }.upcase!

    puts Digest::MD5.hexdigest(result)
  end
end