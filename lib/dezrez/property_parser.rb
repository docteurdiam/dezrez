require 'nokogiri'

class PropertyParser

  def parse_search_results(contents)
    doc = Nokogiri::XML(contents)
    properties = doc.xpath('//property').map do |root|
      return nil if root['price'] == 0
      property = Property.new
      property.id = root['id'].to_i
      property.featured = root['featured'] == "true" # Correspond to slideshow on website
      property.updated_at = root['updated']
      property.bedrooms = root['bedrooms'].to_i
      property.bathrooms = root['bathrooms'].to_i
      property.property_type = root['propertyType'].to_i
      property.house_number = root.xpath('num').text
      property.address_1 = root.xpath('sa1').text
      property.address_2 = root.xpath('sa2').text
      property.town = root.xpath('town').text
      property.postcode = root.xpath('postcode').text
      property.location = root.xpath('locationcodes').text
      property.display_address = root.xpath('useAddress').text
      property.summary = root.xpath('summaryDescription').text
      property.sale = root['sale']
      if property.sale == "true"
        property.trans_type_id = 1
      else
        property.trans_type_id = 2
      end
      property
    end
    properties.compact
  end

  def parse_listing(download_directory, property, contents)
    doc = Nokogiri::XML(contents)
    property.description = doc.xpath("//property/text/description").map {|x| x.text}.join("<br/>")
    property.price = doc.xpath('//property/@priceVal')[0].value.to_i
    doc.xpath("//property/media/picture[(@category='primary') or (@category='secondary')]").each do |picture|
      photo = Photo.new
      photo.remote_url = picture.text
      photo.download(download_directory)
      property.photos << photo
    end
    property.features = doc.xpath("//property/text/areas/area/feature/heading").map do |heading|
      heading.text
    end
    property
  end

end
