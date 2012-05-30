require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PropertyParser do

  it "parses search results" do
    contents = File.read(File.dirname(__FILE__) + "/../fixtures/all_results.xml")
    PropertyParser.new.parse_search_results(contents)
  end

  it "creates properties from search results" do
    contents = File.read(File.dirname(__FILE__) + "/../fixtures/all_results.xml")
    properties = PropertyParser.new.parse_search_results(contents)
    property = properties[1]
    property.bedrooms.should == 2
    property.bathrooms.should == 1
    property.featured.should be_false
    property.id.should == 258204
    property.house_number.should == "2"
    property.address_1.should == "Paulin Drive "
    property.town.should == "LONDON"
    property.postcode.should == "N21 1AA"
    property.location.should == "(RB),(Ref) "
    property.display_address.should == "Paulin Drive, LONDON"
    property.sale.should == "false"
    property.trans_type_id.should == 2
    property.summary.should == "A modern end terrace property situated on the sought after huntley homes development in the oadby area of Leicester.The property benefits from 2 good size bedrooms, A spacious lounge / diner, Modern fitted kitchen with built in oven and hob and gas fired central heating.An early appointment to view is strongly recommended.A modern end terrace property situated on the sought after huntley homes development in the oadby area of Leicester.The property benefits from 2 good size bedrooms, A spacious lounge / diner, Modern fitted kitchen with built in oven and hob and gas fired central heating.An early appointment to view is strongly recommended. "
  end

  it "creates listings from search results" do
    contents = File.read(File.dirname(__FILE__) + "/../fixtures/properties/2069973.xml")
    property = Property.new
    property = PropertyParser.new.parse_listing("/tmp", property, contents)
    property.price.should == 525000
    property.photos.size.should == 5
    property.features.size.should == 12
    property.photos[0].remote_url.should == "http://data.dezrez.com/PictureResizer.ASP?PropertyID=2069973&PhotoID=1&AgentID=398&BranchID=603"
  end

end
