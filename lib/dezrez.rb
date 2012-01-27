require 'active_record'
db_config = YAML::load(File.open(File.join(File.dirname(__FILE__),'../config','database.yml')))["test"]
ActiveRecord::Base.establish_connection(db_config)

require 'dezrez/post'
require 'dezrez/photo'
require 'dezrez/property'
require 'dezrez/property_parser'
require 'dezrez/portals'
require 'dezrez/post'
require 'dezrez/post_meta'
require 'dezrez/feed'
require 'dezrez/version'
require 'dezrez/subscriber'
require 'dezrez/audit'
