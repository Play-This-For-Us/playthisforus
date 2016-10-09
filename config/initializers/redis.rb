uri = URI.parse(ENV["REDISTOGO"] || "redis://localhost:6379/" )
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password) 
