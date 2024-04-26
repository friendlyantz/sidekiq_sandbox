* Table of Contents
{:toc}


## Action Plan

* [ ] [follow along this playlist](<https://www.youtube.com/playlist?list=PLjeHh2LSCFrWGT5uVjUuFKAcrcj5kSai1>) (and fix the code)
- [x] simple Sidekiq Ruby job
- [x] simple Sidekiq Ruby job with arguments and error handling
- [ ] Rack app with Sidekiq web UI
- [ ] add retry logic to job
- [ ] add exponential backoff to job
- [ ] custom retry logic
- [ ] custom error handling

## Lab 1 - Basics

```sh
cd lab1
bundle exec sidekiq -r ./simple_job.rb

# and in another terminal
bundle exec irb
bundle exec pry
```

```ruby
require './simple_job'
CoolJob.perform_async 'some_args'
```

## Lab 2 - Error Handling, Rack App with Sidekiq Web UI

you need rack, rackup and sinatra gems
```sh
cd lab2
bundle exec rackup
# or
bundle exec rackup -s puma # if you want to use puma Server instead of WEBRick (default if no Puma is in Gemfile)
```

you might need to generate a secrete for rackup Sidekiq Sinatra UI

```ruby
require 'securerandom'; File.open(".session.key", "w") {|f| f.write(SecureRandom.hex(32)) }
# and add this to config.ru

require 'rack/session'
use Rack::Session::Cookie, secret: File.read(".session.key"), same_site: true, max_age: 86400
```

Navigate to Sidekiq Web UI[localhost:9292](http://localhost:9292)

### Note 

> Also, i noted code explicitly sets Redis DBs, which did not work with WebUI and I wasn't able to see the jobs in WebUI if i kept:
```ruby
Sidekiq.configure_client do |config|
  config.redis = { db: 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { db: 1 }
end
```

> Also, I noted there is no concept of 'Workers' anymore, 'Jobs' is the go-to now it seems

## Lab 3 - UNIX Signal Handling (TTIN, USR1, TERM)

```sh
# spin up rackup WebUi from lab2

# cd into root of this repo
bundle exec pry -r ./lab_1/simple_job.rb

# in another terminal
bundle exec sidekiq -r ./lab_1/simple_job.rb
```

### TTIN - dump threads

Won't kill Sidekiq, but will dump all threads to log file.

Go to WebUI find a Busy job, and copy TID 

```sh
ps ax | grep sidekiq
kill -TTIN <sidekiqPID>
# now search for TID of a stuck job from WebUI
```

### TSTP Signal - stop accepting new jobs (replacing depricated USR1 since sidekiq v5.0)

Supposed to terminate gracefully / stop accepting new jobs, but it also terminated WIP Jobs
Used at the start of Deployment

```sh
kill -TSTP 10790 # this will cause a shutdown
```
> TSTP is `CTRL+Z` in terminal

### TERM Signal - stop accepting new jobs and finish current jobs

Used at the end of Deployment
waiting 8sec for jobs to finish

> seems like an alternative to `CTRL+C` in terminal. but Unix `CTRL+C` is `INT` signal???

```sh
kill -TSTP 20477
```

### Specify PID file for Sidekiq
> No longer available?

```sh
bundle exec sidekiq -r ./lab_1/simple_job.rb -P ~/tmp/sidekiq.pid
```

### Take it further with `xargs`

```sh
ps ax | ag sidekiq | awk '{print $1}' | xargs kill -TSTP
```

## Lab 4 - Sidekiq API

Same functionality as WebUI, but in Ruby
```ruby
require 'sidekiq/api'
```

### Queues
```ruby
Sidekiq::Queue.all
queue = Sidekiq::Queue.new "default"
queue.size

queue.each do |job|
  puts job.klass
end

queue.each do |job|
  job.delete if job.jid == 'abcdef1234567890'
end

queue.latency

queue.find_job('abcdef1234567890')

queue.clear
```

### Sheduled Jobs

```ruby
ss = Sidekiq::ScheduledSet.new

CoolJob.perform_in(20, 'hard')
ss.size
```

### Retry Set

```ruby
rs = Sidekiq::RetrySet.new
rs.size
```
jobs in retry set ordered by retry time

### Dead Set

```ruby
ds = Sidekiq::DeadSet.new
ds.size
ds.fist.retry
```
### Process Set

gives UNIX details like PID, hostname, concurrency, etc
```ruby
ps = Sidekiq::ProcessSet.new
ps.each do |process|
  puts process['hostname']
end
```

#### UNIX Signals alternatives with ProcessSet

this is useful for deployment where signals are not supported

```ruby
ps.each do |process|
  process.quiet! # stop accepting new jobs
end

ps.each do |process|
  process.stop! # stop accepting new jobs and finish current jobs
end
```

### Workers

```ruby
workers = Sidekiq::Workers.new
# now spin up a lot of jobs
workers.size
workers.each do |process_id, thread_id, work|
  puts work['payload']['class']
end
```

### Stats

```ruby
stats = Sidekiq::Stats.new
stats.processed
stats.failed
stats.enqueued
stats.queues
stats.default_queue_latency
```

### History

```ruby
history = Sidekiq::Stats::History.new
history.processed
history.failed
```
