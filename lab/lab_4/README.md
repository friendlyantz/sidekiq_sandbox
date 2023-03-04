# Professor Gray's Satellite Data Processing

Hello, once again.

I've been having a bit of trouble around my satellite data and the queue structure I'm using. Currently, my approach is taking too long and the throughput is far too low.

I've provided my application here. As before, you can start it with `$ foreman start`.

Here are the requirements:

1. All jobs processed with 30 seconds of starting the `enqueue` process.
2. Certain jobs will fail if they are not processed within a certain amount of time. No jobs must be allowed to fail.
3. You may use only one Sidekiq process.
4. The only file you are allowed to change is the `Procfile`