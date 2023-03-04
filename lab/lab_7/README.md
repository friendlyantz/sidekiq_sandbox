# Professor Gray's Satellite Data Processing

Hello again,

Your work with configuring our multi-process setup was very helpful, however, we're running in to some problems with the database.

Job latency is through the roof. We're running the Postgres database on an old IBM mainframe from the 60's, so unfortunately it cannot support more than 60 database connections at once.

**You must have a Postgres server running for this assignment. This assignment will
change the max connection count on that server to 60. When you are done with this
assignment, run `bundle exec ruby reset_max_conns.rb`**

If you are having trouble with hitting the connection limit when you think you shouldn't be, restart your database server.

You have only one requirement:

1. Reconfigure my application so that it executes successfully in less than 10 seconds. You may modify `app.rb` and change the number of worker processes (example: `foreman start -c enqueuer=1,worker=2` for 2).


