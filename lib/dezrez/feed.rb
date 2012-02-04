class Feed

  def initialize
    @logger = Logging.logger[self]
    @logger.add_appenders('stdout', 'logfile')
  end

  attr_accessor :filename

  def build(properties, branch_id, portal)
    max_image_count = properties.map {|x| x.photos.size}.max
    @logger.info("A property in the feed will contain at most #{max_image_count} images.")
    max_feature_count = properties.map {|x| x.features.size}.max
    max_feature_count = 10 if max_feature_count > 10
    @logger.info("A property in the feed will contain at most #{max_feature_count} features.")
    feed = Feed.new
    feed.filename = File.join("/tmp", generate_name(branch_id))
    @logger.info("The feed will be located at #{feed.filename}")
    file = File.open(feed.filename, "w")
    file.write "#HEADER#\r\n"
    file.write "Version : 3\r\n"
    file.write"EOF : '^'\r\n"
    file.write"EOR : '~'\r\n"
    file.write "Property Count : #{properties.count}\r\n"
    file.write "Generated Date : #{DateTime.now.strftime("%Y-%m-%d %H:%M:%S")}\r\n"
    file.write "\r\n"
    file.write "#DEFINITION#\r\n"
    file.write "AGENT_REF^"
    file.write "ADDRESS_1^ADDRESS_2^ADDRESS_3^ADDRESS_4^TOWN^POSTCODE1^POSTCODE2^"
    1.upto(max_feature_count) do |i|
      file.write  "FEATURE#{i}^"
    end
    file.write "SUMMARY^DESCRIPTION^"
    file.write "BRANCH_ID^"
    file.write "STATUS_ID^BEDROOMS^BATHROOMS^PRICE^PRICE_QUALIFIER^PROP_SUB_ID^CREATE_DATE^UPDATE_DATE^DISPLAY_ADDRESS^PUBLISHED_FLAG^LET_DATE_AVAILABLE^LET_BOND^LET_TYPE_ID^LET_FURN_ID^LET_RENT_FREQUENCY^TENURE_TYPE_ID^TRANS_TYPE_ID^NEW_HOME_FLAG^"
    0.upto(max_image_count - 1) do |i|
      file.write "MEDIA_IMAGE_#{sprintf("%02d", i)}^"
    end
    file.write "MEDIA_IMAGE_60^MEDIA_IMAGE_TEXT_60^MEDIA_DOCUMENT_50^MEDIA_DOCUMENT_TEXT_50^~\r\n"
    file.write "\r\n"
    file.write "#DATA#\r\n"
    properties.each do |property|
      file.write property.write(branch_id, max_feature_count, max_image_count, portal) + "\r\n"
    end
    file.write "#END#"
    file.close
    feed
  end

  private

  def generate_name(branch_id)
    "#{branch_id}#{DateTime.now.strftime("%Y%m%d%M%S")}.BLM"
  end

end