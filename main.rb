require 'optparse'
require_relative 'parser'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"
  opts.on('-b', '--business NAME', 'Business id') { |v| options[:business] = v }
end.parse!

if options[:business].nil?
  puts "Wrong number of arguments use -h to see usage"
  exit
end

url = "http://www.opentable.com/#{options[:business]}"

parser = Parser.new(url)
parser.run