# Professor Gray's Satellite Data Processing

Hello again, minion -- er, I mean, valued research associate:

I'm preparing a grant application for my satellite data work, and I need to have some kind of estimate for how many machines we'll need to process my incoming satellite data.

I've created an example program that enqueues some satellite data. What I need from you is an estimate of _how many Sidekiq processes_ I need to keep this queue to **60 seconds of latency or less**.

The `Procfile` will have separate "job enqueueing" and Sidekiq process types. Configure the process types' `concurrency` setting for maximum efficiency, then figure out how many you have to start in order to keep queue latency below 60 seconds. You can start multiple workers like this: `$ foreman start -c enqueuer=1,worker=2`

Good luck!