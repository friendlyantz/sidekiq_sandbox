require 'sidekiq/api'
require 'colorize'
# Thanks for your help! - Prof Gray

Thread.new do
  while true
    stats = Sidekiq::Stats.new
    stats_processes_size = stats.processes_size # how many times we invoked sidekiq on a server

    ################ Utilization Hacky CLI way #####################
    # this only for this processor instance, launched via command 'sidekiq -r filename.rb'
    # this is hacky but slightly more up-to-date data
    workers = Sidekiq::CLI.instance&.launcher&.managers&.first&.workers
    num_processor_threads_busy_for_one_process = workers&.count(&:job) || 0
    num_processor_threads_total_for_one_process = workers&.count || 0
    util_percent_for_process_instance = num_processor_threads_busy_for_one_process.to_f / num_processor_threads_total_for_one_process * 100


    ############## Utilization Sidekiq UI way #####################
    num_processor_threads_busy_on_server = stats.workers_size
    # ws = Sidekiq::WorkSet.new.size || 0 # same as above
    num_processor_threads_total_on_server = Sidekiq::ProcessSet.new.total_concurrency

    util_percent_for_all_processes = num_processor_threads_busy_on_server.to_f / num_processor_threads_total_on_server * 100


    ### Latency ###
    default_queue_latency_in_seconds =
      Sidekiq::Stats.new.default_queue_latency.round(2)
    # or Sidekiq::Queue.new('default').latency.round(2)

    retry_queue_latency_in_seconds = Sidekiq::Queue.new('retry').latency.round(2)

    Sidekiq.logger.warn(Sidekiq::CLI.r + '*' * 20 + Sidekiq::CLI.reset)
    Sidekiq.logger.warn(
      <<~HEREDOC
      Stats.new.processes_size how many were executed in total           #{stats_processes_size} processes

      Utilization (instantaneous) for THIS process:                      #{util_percent_for_process_instance.to_s.red}%
      Utilization (instantaneous) for ALL processes:                     #{util_percent_for_all_processes.to_s.light_red}%

      Hacky CLI                         BUSY threads for THIS process    #{num_processor_threads_busy_for_one_process.to_s.light_green}
      Hacky CLI                         ALL threads for THIS process     #{num_processor_threads_total_for_one_process.to_s.light_green}

      WorkerSet.new.size                BUSY threads for ALL processes   #{num_processor_threads_busy_on_server.to_s.green}
      ProcessSet.new.total_concurrency  ALL threads for ALL processes    #{num_processor_threads_total_on_server.to_s.green}

      Default latency:                                                   #{default_queue_latency_in_seconds} sec
      Retries latency:                                                   #{retry_queue_latency_in_seconds} sec
      HEREDOC
    )
    Sidekiq.logger.warn(Sidekiq::CLI.r + '*' * 20 + Sidekiq::CLI.reset)
    sleep 1
  end
end
