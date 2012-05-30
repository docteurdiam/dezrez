class Post < ActiveRecord::Base
  self.table_name = "wp_posts"
  has_many :post_meta, :class_name => "PostMeta", :dependent => :destroy
  has_many :tags

  def self.clear_existing_listings
    Post.delete_all("post_type = 'listing'")
  end

  def self.generate(properties, website)
    properties.each do |property|
      post = Post.new
      post.post_date = post.post_date_gmt = post.post_modified = post.post_modified_gmt = DateTime.now
      post.post_author = 1
      post.post_type = 'listing'
      post.post_name = property.id
      post.guid = "#{website}/?post_type=listing&#038;p=#{property.id}"
      post.post_content = property.description
      post.post_title =  property.display_address
      post.create_postmeta(property)
      post.save!
      post.reload
      post.associate_taxonomy(property.location, 'property_location')
      post.associate_taxonomy('#{buyorrent(property.sale)}', 'property_buyorrent')
      post.associate_price_range(property.price)
      property.photos.each do |photo|
          attachment = Post.new
          attachment.post_date = attachment.post_date_gmt = attachment.post_modified = attachment.post_modified_gmt = DateTime.now
          attachment.post_author = 1
          attachment.post_parent = post.id
          attachment.post_type = 'attachment'
          attachment.post_name = File.basename(photo.filename)
          attachment.post_title = File.basename(photo.filename)
          attachment.post_status = 'inherit'
          attachment.post_mime_type = 'image/jpeg'
          attachment.guid = photo.remote_url + "&width=300"
          attachment.create_photo_meta(File.basename(photo.filename))
          attachment.save!
        end
    end
  end

  def associate_price_range(price)
    sql = %{
              SELECT
                wp_term_taxonomy.term_taxonomy_id,
                wp_terms.name
              FROM wp_terms
              JOIN wp_term_taxonomy ON wp_term_taxonomy.term_id = wp_terms.term_id
              WHERE taxonomy = 'property_pricerange'
    }
    rows = self.connection.select_all(sql)
    rows.each do |row|
      boundaries = row["name"].split("-")
      if price > boundaries[0].to_i && price < boundaries[1].to_i
        sql = "INSERT INTO wp_term_relationships (object_id, term_taxonomy_id) VALUES (#{self.id}, #{row["term_taxonomy_id"]})"
        self.connection.execute(sql)
      end
    end
  end

  def associate_taxonomy(key, category)
    return if key.blank?
    key = Property.locate(key) if category == "property_location"
    sql = %{
              SELECT term_taxonomy_id
              FROM wp_terms
              JOIN wp_term_taxonomy ON wp_term_taxonomy.term_id = wp_terms.term_id
              WHERE name = '#{key}' AND taxonomy = '#{category}'
    }
    taxonomy_id =  self.connection.select_value(sql)
    if taxonomy_id
      sql = "INSERT INTO wp_term_relationships (object_id, term_taxonomy_id) VALUES (#{self.id}, #{taxonomy_id})"
      self.connection.execute(sql)
    end
  end

  def create_photo_meta(filename)
    self.post_meta.build({meta_key: '_wp_attached_file', meta_value: filename})
  end

  def create_postmeta(property)
    entries = [
            {meta_key: 'price_value', meta_value: property.price},
            {meta_key: 'baths_value', meta_value: property.bathrooms},
            {meta_key: 'cr_value', meta_value: 'Residential'},
            {meta_key: 'google_location_value', meta_value: property.postcode},
            {meta_key: 'beds_value', meta_value: property.bedrooms},
            {meta_key: 'propertytype_value', meta_value: Property.classify(property.property_type.to_i)},
            {meta_key: 'address_1_value', meta_value: property.address_1},
            {meta_key: 'address_2_value', meta_value: property.address_2},
            {meta_key: 'postcode_value', meta_value: property.postcode},
            {meta_key: 'slideshow_value', meta_value: property.featured ? 'Yes' : 'No'},
            {meta_key: 'rob_value', meta_value: 'Rent'},
            {meta_key: 'streetview_value', meta_value: 'Yes'},
            {meta_key: 'toolong_value', meta_value: 'No'},
            {meta_key: 'location_level1_value', meta_value: Property.locate(property.location)},
            {meta_key: 'citystatezip_value', meta_value: property.town},
            {meta_key: 'deckpatio_value', meta_value: 'No Deck or Patio'}
    ]
    entries.each_index do |i|
      self.post_meta.build(entries[i])
    end
  end
  
  
  def buyorrent(value)
    case value
      when "true" then "Buy"
      when "false" then "Rent"
      else
        @@logger.debug("The property status Rent or Buy Could not be found")
        nil
    end
  end

end
