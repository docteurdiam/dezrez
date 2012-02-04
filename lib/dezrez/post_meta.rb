class PostMeta < ActiveRecord::Base
  self.table_name = "wp_postmeta"
  belongs_to :post
end