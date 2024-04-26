require 'sidekiq'
require 'colorize'

class CoolJob
  include Sidekiq::Job
  sidekiq_options retry: 1 # lab_2

  def perform(complexity)
    case complexity
    when "super_hard"
      puts "I'm doing something super hard!".red
      1_000_000.times { |i| OpenSSL::Digest::MD5.hexdigest(complexity + i.to_s) } # Very Sophisticated Data Analysis!
      raise "Overworked Error!" if rand(3).zero?
      sleep 5
      puts "I've finished doing something super hard!".light_red
    when "hard"
      puts "I'm doing something hard!".yellow
      100_000.times { |i| OpenSSL::Digest::MD5.hexdigest(complexity + i.to_s) }
      sleep 3
      puts "I've finished doing something hard!".light_yellow
      # while true # lab_3 introduced bug
      #   puts "loop bug".yellow
      #   sleep 3
      # end
    else
      puts "I'm doing something simple!".green
      10_000.times { |i| OpenSSL::Digest::MD5.hexdigest(complexity + i.to_s) }
      sleep 1
      puts "I've finishedf something simple!".light_green
    end
    sleep 1.01
  end
end
