class PostMeta < ActiveRecord::Base
  set_table_name "wp_postmeta"
  belongs_to :post

end