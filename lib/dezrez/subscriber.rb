require 'nokogiri'
require 'httparty'
require 'logging'

class Subscriber

  include HTTParty
  default_params apiKey: 'E1D57034-6C07-44C4-A458-425CAE9D9247', eaid: 1322, xslt: -1, perpage: 100
  base_uri "http://www.dezrez.com/DRApp/DotNetSites/WebEngine/property/"

  SEARCH_URL = "/Default.aspx"
  DETAILS_URL = "/Property.aspx"

  def initialize
    @session_guid = 1
    @logger = Logging.logger[self]
    @logger.add_appenders('stdout', 'logfile')
  end

  def reset
    Property.delete_all
    Photo.delete_all
    Post.delete_all("post_type = 'listing'")
    Post.delete_all("post_parent != 0 AND post_parent NOT IN (select id FROM wp_posts)")
    Post.connection.execute("DELETE FROM wp_postmeta WHERE post_id NOT IN (select id FROM wp_posts)")
  end

  def pull(download_directory, rentperiod)
    response = Subscriber.get(SEARCH_URL, :query => {:sessionGUID => @session_guid, :rentalPeriod => rentperiod})
    properties = PropertyParser.new.parse_search_results(response.body)
    @logger.info "Parsed #{properties.size} search results from the DezRez API."
    lettings = properties.map do |property|
      response = Subscriber.get(DETAILS_URL, :query => {:sessionGUID => @session_guid, :pid => property.id, :rentalPeriod => rentperiod})
      PropertyParser.new.parse_listing(download_directory, property, response.body)
    end
    @logger.info "Parsed #{lettings.size} individual properties from the DezRez API."
    lettings
  end

end


