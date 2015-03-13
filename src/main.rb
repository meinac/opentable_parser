require 'pry'
require 'active_support/all'

require_relative 'parser'
require_relative 'pusher'
require_relative 'api_consumer'

while(true)
  ApiConsumer.get_parsables.each do |parsable|
    parser = Parser.new(parsable.symbolize_keys)
    parser.run
  end
end
