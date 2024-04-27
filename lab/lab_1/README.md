# Professor Gray's Satellite Data Processing

Dear colleague,

Thank you for responding to my internal email about needing someone to help me with this satellite data processing. The SETI project is, as you know, very important, and this radio telescope data from the Oumuamua flyby could contain some very interesting information indeed!

I have created a simple Sidekiq application for processing a small part of this data so I can get some initial results and test the approach. However, I need some metrics from this application before I scale it up to the entire, live dataset.

I need you to log three metrics, once per minute, to the output of my Sidekiq server:

1. Utilization at that current moment (instantaneous)
2. Current queue depth, in seconds
3. Current retry queue depth, in seconds

I've started it but I couldn't figure out how to finish it. I studied physics, not computer science or queueing theory! I'm sure you'll figure it out quickly.

You should only need to modify `logger_thread.rb`.

Thank you so much - this will greatly accelerate my research!

## NOTES

Each lab includes a Procfile - start it using `foreman`, which you may have to `gem install` if you don't have it already. Each app also includes a Gemfile, so be sure to `bundle install`.

Each lab assumes that you have a redis server running at `localhost:6379`. **Every lab will wipe this database, so make sure it doesn't have anything important in it!**

Later labs will need a Postgres server running on `localhost:5432`. You may alter the lab to use a username/password but, by default, it's set up to try to connect without one.

Many labs have time limits. I have done my best to calculate these time limits so that they will work for a majority of computers, but CPU speed may make some labs easier or other labs harder.

It's possible that Foreman may not shut down all your Sidekiq servers correctly, or if you happen to be running a Sidekiq server from outside this course at the same time. You can see very strange errors when this happens. Be sure to `kill` all Sidekiq servers - I use `pkill -9 sidekiq`. [Using `foreman start -t 10` may mitigate this issue.](https://github.com/mperham/sidekiq/issues/2312)

----

added sidekiq WebUI

```ruby
bundle exec rackup sidekiq_web_config.ru -p 9393
```
