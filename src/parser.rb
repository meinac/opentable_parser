require 'nokogiri'
require 'open-uri'
require 'date'

class Parser

  def initialize(url)
    @url = url
    @pusher = Pusher.new
    @letters = []
  end

  def run
    parse(Nokogiri::HTML(open(@url)))
  end

  def parse(document)
    reviews = document.css('#reviews-results div.review')
    reviews.each do |review|
      parse_review(review)
    end
    next_link = document.css('a.pagination-next')[0]
    if next_link && next_link['href']
      parse(Nokogiri::HTML(open(next_link['href'])))
    else
      @pusher.push(@letters)
    end
  end

  def parse_review(document)
    user_name = document.css('.review-user-info span').text
    date = parse_date(document.css('.review-meta span.color-light').text.sub('Dined on ', ''))
    title = document.css('.review-title').text
    review = document.css('.review-content p').text

    rating = document.css('.review-stars-results-num')
    food_rating = rating[0].text
    ambience_rating = rating[1].text
    service_rating = rating[2].text

    @letters << {
      actor_name: user_name, 
      provider: :opentable,
      type: :comment,
      created_at: date,
      title: title,
      review: review,
      food_rating: food_rating,
      ambience_rating: ambience_rating,
      service_rating: service_rating
    }
  end

  def parse_date(date_string)
    date_string =~ /Dined (.+) days ago/ ? date = DateTime.now - $1.to_i : DateTime.parse(date_string)
  end

end