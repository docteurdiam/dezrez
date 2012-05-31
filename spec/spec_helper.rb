require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'fakeweb'
require 'dezrez'

FakeWeb.allow_net_connect = false
base_request = "http://www.dezrez.com/DRApp/DotNetSites/WebEngine/property/"

url = base_request + "Default.aspx?apiKey=E1D57034-6C07-44C4-A458-425CAE9D9247&eaid=1322&xslt=-1&perpage=100&sessionGUID=1&rentalPeriod=6"
FakeWeb.register_uri(:get, url, :body => File.open(File.join('spec/fixtures/all_results.xml'), 'r') { |file| file.read })

db_config = YAML::load(File.open(File.join(File.dirname(__FILE__),'../config','database.yml')))["test"]
ActiveRecord::Base.establish_connection(db_config)

Dir[File.join('spec/fixtures/photos/*')].each do |filename|
  basename = File.basename(filename, ".jgp")
  property_id = basename.split(".")[0]
  photo_id = basename.split(".")[1]
  url = "http://data.dezrez.com/PictureResizer.ASP?PropertyID=#{property_id}&PhotoID=#{photo_id}&AgentID=398&BranchID=603&width=300"
  FakeWeb.register_uri(:get, url, :body => File.open(filename, 'rb') { |file| file.read })
end

Dir[File.join('spec/fixtures/properties/*')].each do |filename|
  basename = File.basename(filename, ".xml")
  url = base_request + "Property.aspx?apiKey=E1D57034-6C07-44C4-A458-425CAE9D9247&eaid=1322&xslt=-1&perpage=100&rentalPeriod=6&sessionGUID=1&pid=#{basename}"
  FakeWeb.register_uri(:get, url, :body => File.open(filename, 'r') { |file| file.read })
end

