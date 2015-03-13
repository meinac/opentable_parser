require 'console_progress_bar'
require 'aws-sdk'

class Pusher

  def initialize
    @sqs_client = Aws::SQS::Client.new
    @queue_url = @sqs_client.get_queue_url(queue_name: ENV['LEAF_SOCIAL_LETTER_QUEUE']).queue_url
    @pbar = ConsoleProgressBar::ProgressBar.new
  end

  def push(letters)
    recent_letter = letters.first
    push_into_sqs(letters)
    recent_letter && push_to_api(recent_letter)
  end

  def push_into_sqs(letters)
    counter = @pbar.counter(total: letters.length, increment_size: 10)
    while((entries = letters.pop(10)).length != 0)
      @sqs_client.send_message_batch(
        queue_url: @queue_url,
        entries: entries.map.with_index do |letter, index|
          {id: index.to_s, message_body: letter.to_s}
        end
      )
      counter.increase
    end
  end

  def push_to_api(recent_letter)
    ApiConsumer.push_recent_date(recent_letter[:user_id], recent_letter[:created_at].strftime("%Y-%m-%dT%H:%M:%S"))
  end

end