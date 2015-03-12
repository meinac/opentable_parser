require 'nokogiri'
require 'open-uri'
require 'date'

class Parser

  def initialize(**parsable)
    @url = parsable[:url]
    @user_id = parsable[:user_id]
    @last_fetch = parsable[:last_fetch] || DateTime.new(1970, 1, 1)
    @pusher = Pusher.new
    @letters = []
    puts "Parse #{@url} for review time > #{@last_fetch}"
  end

  def run
    parse(Nokogiri::HTML(open(@url)))
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
      parse(Nokogiri::HTML(open(next_link['href'])))
    else
      @pusher.push(@letters)
    end
  end

  def parse_review(document)
    date = parse_date(document.css('.review-meta span.color-light').text.sub('Dined on ', ''))
    if date > @last_fetch
      @letters << {
        user_id: @user_id,
        actor_name: document.css('.review-user-info span').text, 
        provider: :opentable,
        type: :comment,
        created_at: date,
        title: document.css('.review-title').text,
        review: document.css('.review-content p').text,
        food_rating: document.css('.review-stars-results-num')[0].text,
        ambience_rating: document.css('.review-stars-results-num')[1].text,
        service_rating: document.css('.review-stars-results-num')[2].text
      }
    end
  end

  def parse_date(date_string)
    date_string =~ /Dined (.+) days ago/ ? date = DateTime.now - $1.to_i : DateTime.parse(date_string)
  end

end