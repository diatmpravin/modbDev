# Make sure Resque for this site uses the same Redis
# connection that the rest of the site uses.
Resque.redis = Redis::Client.build
