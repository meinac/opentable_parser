require 'httparty'
require 'json'

class ApiConsumer

  def self.get_parsables
    begin
      response = HTTParty.get('http://localhost:3000/api/opentable_list')
      response.code == 200 ? JSON.parse(response.body) : []
    rescue
      []
    end
  end

end