# default twitter username, uncomment and set name to skip typing username
# TWITTER_USERNAME = 'yourusername'
# default seach term if not set in the command line
search = ['fail']

if ARGV.empty?
  SEARCH = search
else
  SEARCH = ARGV
end

require 'rubygems'
# shared connection to PureData 
require 'highline/import'
require 'socket'
require 'character'
hostname = '127.0.0.1'
port = '3939'
sock = TCPSocket.open hostname, port

# Twitter streaming api gem
require 'tweetstream' 

unless defined?(TWITTER_USERNAME)
  TWITTER_USERNAME = ask("Twitter Username:").chomp
end

puts "Using twitter username '#{TWITTER_USERNAME}'."
#password = gets.chomp
password = ask("Enter password: ") { |q| q.echo = false }
password = password.chomp

TweetStream.configure do |config|
  config.username = TWITTER_USERNAME
  config.password = password
  config.auth_method = :basic
end

ts = TweetStream::Client.new
puts 'initialization finished'
puts "search: #{SEARCH.join(', ')}"

trap("INT") do
  puts "got signal INT"
  ts.stop
  return
end 

interrupted = false
trap("INT") do 
  interrupted = true
end

ts.track(SEARCH) do |status|
  if interrupted == true
    ts.stop
    return
  end
  string = "[#{status.user.screen_name}] #{status.text}"
  puts ''
  Character.send_string(string, sock, 0.15)
end


 