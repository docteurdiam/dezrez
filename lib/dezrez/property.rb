class Property
  attr_accessor :id
  attr_accessor :features
  attr_accessor :summary
  attr_accessor :house_number
  attr_accessor :updated_at
  attr_accessor :property_type
  attr_accessor :description
  attr_accessor :location
  attr_accessor :display_address
  attr_accessor :town
  attr_accessor :address_2
  attr_accessor :address_1
  attr_accessor :price
  attr_accessor :remote_id
  attr_accessor :bathrooms
  attr_accessor :bedrooms
  attr_accessor :photos
  attr_accessor :featured
  attr_accessor :postcode
  attr_accessor :trans_type_id
  
  def initialize
    @features = []
    @photos = []
    @@logger = Logging.logger[self]
    @@logger.add_appenders('stdout', 'logfile')
  end


  def prop_sub_id
    case property_type
      when nil then 0
      when 1,2,3,8,25,26,27,56 then 1 # Terraced
      when 4,7,17,18,28,31,32,33,34,54,55,61,2,12,20,26,36 then 3 # Semi-Detached
      when 5,6,29,30,50,53,65,66 then 4 # Detached
      when 15,16,39 then 15 # Detached Bungalow
      when 14,38 then 14 # Semi-Detached Bungalow
      when 11,12,13,35,36,37 then 13 # Terraced Bungalow
      when 9,10,43,46,58,59 then 7 # Ground Flat
      when 9,10,44,45,47,48,58,59 then 8 # Flat
      when 9,10,58,59,67,72 then 9 # Studio
      when 71 then 47 # Retirement Property
      when 9,10,58,59,67,72 then 29 # Penthouse
      when 49,50,52,68 then 11 # Maisonette
      when 35,36,37,38,39 then 24 # Chalet
      when 40,41,42 then 43 # Barn Conversion
      else 0
    end
  end

  def self.classify(property_type)
    case property_type
      when 1 then "Terraced (House)"
      when 2 then "End Terrace (House)"
      when 3 then "Mid Terrace (House)"
      when 4 then "Semi-Detached (House)"
      when 5 then "Detached (House)"
      when 6 then "Remote Detached (House)"
      when 7 then "End Link (House)"
      when 8 then "Mid Link (House)"
      when 9 then "Flat"
      when 10 then "Apartment"
      when 43 then "Ground Floor Purpose Build (Flat)"
      when 46 then "Ground Floor Converted (Flat)"
      when 25 then "Terraced (Town House)"
      when 53 then "Mansion"
      when 62 then "Villa (Detached)"
      when 63 then "Villa (Link-Detached)"
      when 64 then "Villa (Semi-Detached)"
      when 65 then "Village House"
      when 66 then "Link Detached"
      when 67 then "Studio"
      when 68 then "Maisonette"
      when 71 then "Retirement Flat"
      when 72 then "Bedsit"
      when 73 then "Park Home/Mobile Home"
      else
        @@logger.debug("No property type could be found with ID #{property_type}")
        nil
    end
  end

  def self.locate(location)
    codes = location.scan(/\d+/)
    if codes.empty?
      nil
    else
      case codes[0].to_i
        when 1 then "St Johns Wood"
        when 2 then "Maida Vale"
        when 3 then "Little Venice"
        when 4 then "West Hampstead"
        when 5 then "Hampstead"
        when 6 then "Belsize Park"
        when 7 then "Primrose Hill"
        when 8 then "Queens Park"
        when 9 then "Notting Hill"
        when 10 then "Bayswater"
        else
          @@logger.debug("No location could be found with ID #{codes[0].to_i}")
          nil
      end
    end
  end

  def write(branch_id, max_feature_count, max_photo_count, portal)
    feature_subset = write_features(max_feature_count)
    photo_subset = write_photos(branch_id, max_photo_count)
    if portal == "zoopla"
      contents = "#{branch_id}_#{id}^#{house_number}^#{address_1}^#{address_2}^^#{town}^#{postcode_1}^"
    else
      contents = "#{branch_id}_#{id}^#{house_number}^#{address_1} #{address_2.to_s}^^^#{Property.locate(location)}^#{postcode_1}^"
    end
    contents = contents + "#{postcode_2}^#{feature_subset}^#{summary}^#{description}^"
    contents = contents + "#{branch_id}^0^#{bedrooms}^#{bathrooms}^#{price}^^#{prop_sub_id}^^^#{display_address}^1^^^^^0^^#{trans_type_id}^^"
    contents + "#{photo_subset}^^^^^~\r\n"
  end

  def postcode_1
    postcode.split(" ")[0]
  end

  def postcode_2
    postcode.split(" ")[1]
  end

  def write_features(max_feature_count)
    contents = ""
    for i in 1..max_feature_count
      if features.size >= i
        if i == 1
          contents = features[0]
        else
          contents += "^#{features[i - 1]}"
        end
      else
        contents += "^"
      end
    end
    contents
  end

  def write_photos(branch_id, max_photo_count)
    contents = ""
    for i in 1..max_photo_count
      if photos.size >= i
        if i == 1
          contents = "#{branch_id}_#{id}_IMG_00.jpg"
        else
          contents += "^#{branch_id}_#{id}_IMG_#{sprintf("%02d", i - 1)}.jpg"
        end
      else
        contents += "^"
      end
    end
    contents
  end

end
