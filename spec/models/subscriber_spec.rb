require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Subscriber do

  it "pulls down properties from the DezRez website" do
    properties = Subscriber.new.pull("/home/okouam/diamond-residential/wp-content/uploads")
    properties.size.should == 26
  end

  it "fetches the attributes for properties from the DezRez website" do
    properties = Subscriber.new.pull("/home/okouam/diamond-residential/wp-content/uploads")
    properties[0].id.should == 1919875
    properties[0].house_number.should == "6"
    properties[0].location.should == "(GP)(TC)(RB) "
    properties[0].description.should == "A handsome Georgian style residence offering substantial accommodation on a plot approaching three quarters of an acre, enjoying an excellent location close to the heart of Virginia Water village. Bel Air is a uniquely designed home which was completed for the current owner in 2009; the property boasts excellent, well planned accommodation on all four storeys and in our opinion the architectural design of the facade is simply exquisite. Property such as this is a very rare commodity. <br/>4 bedrooms<br/>2 reception rooms<br/>5 bathrooms<br/>Detached<br/>Garden<br/>Land<br/>Private Parking<br/>0.75 acres<br/><br/><br/><br/>Lease Length:<br/>Break Clause:<br/>Service Charge:<br/>Rateable Value:<br/>Rates Payable:"
  end

end