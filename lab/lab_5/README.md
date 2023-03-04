# Professor Gray's Satellite Data Processing

Hello! I have good news.

I've been allocated some additional budget for my satellite data processing. I'm no longer restricted to running just one Sidekiq process! However, I'm not sure how I can take advantage of this additional server capacity.

So, here's the bad news - my workload has also increased. I need to process 700 jobs every 30 seconds. If we executed this workload single-threaded, it would take almost 7 minutes. Well, you've got to do 1400% better than that. And I've got some latency requirements for each type of job.

I've provided my application here. As before, you can start it with `$ foreman start`.

Here are the requirements:

1. All jobs processed with 30 seconds of starting the `enqueue` process.
2. Certain jobs will fail if they are not processed within a certain amount of time. No jobs must be allowed to fail.
3. You may use up to 5 separate Sidekiq processes. They may have different configurations, or may have the same configuration.
4. You are only allowed to change the `Procfile`.