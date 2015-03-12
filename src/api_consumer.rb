require 'httparty'
require 'json'

class ApiConsumer

  def self.get_parsables
    begin
      response = HTTParty.get('http://10.0.1.249:3000/api/opentable/list')
      response.code == 200 ? JSON.parse(response.body) : []
    rescue
      []
    end
  end

  def self.push_recent_date(user_id, date)
    HTTParty.post('http://10.0.1.249:3000/api/opentable/update', body: {user_id: user_id, last_fetch: date}.to_json)
  end

end