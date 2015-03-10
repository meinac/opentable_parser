require 'optparse'
require 'pry'
require 'json'
require 'aws'

require_relative 'parser'
require_relative 'models/model'
require_relative 'models/letter'
require_relative 'models/actor'

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