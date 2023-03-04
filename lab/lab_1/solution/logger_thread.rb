Thread.new do
  while true
    workers = Sidekiq::CLI.instance&.launcher&.manager&.workers
    num_processors_busy = workers&.count(&:job) || 0
    num_processors_total = workers&.size || 0
    util_percent = num_processors_busy.to_f / num_processors_total * 100

    default_queue_latency_in_seconds = Sidekiq::Stats.new.default_queue_latency.round # Maybe in Sidekiq::API?

    retry_queue_latency_in_seconds = Sidekiq::Queue.new("retry").latency # Maybe in Sidekiq::API?

    Sidekiq.logger.warn(Sidekiq::CLI.r + "*" * 20 + Sidekiq::CLI.reset)
    Sidekiq.logger.warn(
      "Utilization (instantaneous): #{util_percent}% | " +
      "Default latency: #{default_queue_latency_in_seconds} | " +
      "Retries latency: #{retry_queue_latency_in_seconds}"
    )
    Sidekiq.logger.warn(Sidekiq::CLI.r + "*" * 20 + Sidekiq::CLI.reset)
    sleep 1
  end
end