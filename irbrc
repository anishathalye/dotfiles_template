begin
  gem "pry"
rescue => ex
  $stderr.puts ex.message
else
  require "pry"
  Pry.start
  exit!
end