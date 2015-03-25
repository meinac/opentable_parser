require 'nokogiri'
require 'open-uri'
require 'date'

class Parser

  MAX_TRY_COUNT = 5

  def initialize(**parsable)
    @url = parsable[:url]
    @user_id = parsable[:user_id]
    @last_fetch = parsable[:last_fetch] || DateTime.new(1970, 1, 1)
    @pusher = Pusher.new
    @letters = []
  end

  def run
    if @url
      @parse_started_at = DateTime.now
      puts "Parse #{@url} for review time > #{@last_fetch}"
      parse(get_document(@url))
    end
  end

  def parse(document)
    keep_parsing = true
    reviews = document.css('#reviews-results div.review')
    reviews.each do |review|
      if !parse_review(review)
        keep_parsing = false
        break
      end
    end
    next_link = document.css('a.pagination-next')[0]
    if keep_parsing && next_link && next_link['href']
      parse(get_document(next_link['href']))
    else
      @pusher.push(@letters, @parse_started_at)
    end
  end

  def parse_review(document)
    date = parse_date(document.css('.review-meta span.color-light').text.sub('Dined on ', ''))
    if date > @last_fetch
      @letters << {
        user_id: @user_id,
        user: {
          name: document.css('.review-user-info span').text
        },
        provider: :opentable,
        type: :comment,
        created_at: date,
        title: document.css('.review-title').text,
        content: document.css('.review-content p').text,
        rating: {
          food_rating: document.css('.review-stars-results-num')[0].text,
          ambience_rating: document.css('.review-stars-results-num')[1].text,
          service_rating: document.css('.review-stars-results-num')[2].text
        }
      }
    end
  end

  private

    def parse_date(date_string)
      date_string =~ /Dined (.+) days ago/ ? date = DateTime.now - $1.to_i : DateTime.parse(date_string)
    end

    def get_document(url, try_count = 0)
      begin
        Nokogiri::HTML(open(url))
      rescue
        try_count == MAX_TRY_COUNT ? Nokogiri::HTML('') : get_document(url, try_count + 1)
      end
    end

end