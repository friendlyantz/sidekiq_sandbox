# Professor Gray's Satellite Data Processing

Thank you so much for helping me with that instrumentation. Now, I've got a slightly different problem.

I've got satellite data from our orbiting radio telescopes. There are four different types of radio telescopes. Each one has a different, corresponding Sidekiq job class.

In each job, we spend some time in a C-language extension, making calculations with the data. This C-extension unlocks the GVL (whatever that is).

I need you to figure out the optimal `concurrency` setting for each type of job, maximizing throughput in terms of jobs per second. My only requirement: for all job types, service time (latency of the job itself) cannot be greater than 1.8 seconds. The actual computation work, in the absence of any concurrency, takes about 0.6 seconds.

Your deliverable will be to fill out this table with the concurrency setting which meets my latency requirements but minimizes the amount of time to process 1000 units of each job type:

| Job Type | % time in C extension (estimated) | `concurrency` |
|----------|-----------------------------------|---------------|
| A        | 10%                               |               |
| B        | 30%                               |               |
| C        | 60%                               |               |
| D        | 90%                               |               |

You're pretty smart, so you should be able to guess the answer before even testing it.

Run the test program with `concurrency=1` by running `$ time bundle exec sidekiq -r ./concurrency_test.rb -c 1 <JOB TYPE>`, where `<JOB_TYPE>` is any one of A, B, C or D. I've designed this test to take, at most, about 60 seconds. It will fail automatically if you exceed my latency requirement (check the logs).

You may want to try even higher concurrency settings, even if they increase latency beyond my requirements, simply for your own education. Note how latency increases at ever-higher concurrencies.

You might also try disabling my latency limit and seeing if higher concurrencies increase throughput or not.