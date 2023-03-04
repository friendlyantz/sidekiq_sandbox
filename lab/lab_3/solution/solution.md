To guess at a solution, consider:

1. The job takes about 0.6 seconds to run.
2. With concurrency=10, Amdahl's Law suggests each process will have a parallelism of about 2.
3. That means that a 100% utilized process will be processing about (2/0.6) jobs per second (or, slightly more than 3).
4. Looking at enqueue.rb, we're enqueueing a job every 0.1 seconds, so 10 jobs per second.
5. Therefore, we'll need at least 3 processes, because we need to be processing work faster than it is enqueued.

Trying `foreman start -c enqueuer=1,worker=2`, we see that queue latency soon exceeds 60 seconds. Bummer. Trying `foreman start -c enqueuer=1,worker=3`, we see that latency doesn't increase at all. Jackpot!