require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Property do

  before(:each) do
    @property = Property.new
    @property.id = 1868678
    @property.location = "Newcastle"
    @property.price = 500
    @property.bedrooms = 5
    @property.bathrooms = 4
    @property.postcode = "N4 3PS"
    @property.summary = "this is my summary"
    @property.description = "this is my description"
    @property.display_address = "Latimer Road, Tyining"
    @property.features = ["Kitchen", "Bar", "Garage", "Terrace"]
    @property.photos = [Photo.new(filename: "a.jpg"), Photo.new(filename: "b.jpg"), Photo.new(filename: "c.jpg")]
    @property.sale = "false"
    @property.trans_type_id = 2
  end

  describe "when writing out to a feed" do

    it "includes all required attributes" do
      expected = "99XX99_1868678^^^^^^N4^3PS^Kitchen^Bar^Garage^Terrace^^this is my summary^this is my description^99XX99^0^5^4^500^^0^^^Latimer Road, Tyining^1^^^^^0^^2^^99XX99_1868678_IMG_00.jpg^99XX99_1868678_IMG_01.jpg^99XX99_1868678_IMG_02.jpg^^^^^^^~\r\n"
      @property.write("99XX99", 5, 5, "zoopla").should == expected
    end

    it "limits the number of features written" do
      expected = "99XX99_1868678^^^^^^N4^3PS^Kitchen^Bar^this is my summary^this is my description^99XX99^0^5^4^500^^0^^^Latimer Road, Tyining^1^^^^^0^^2^^99XX99_1868678_IMG_00.jpg^99XX99_1868678_IMG_01.jpg^99XX99_1868678_IMG_02.jpg^^^^^^^~\r\n"
      @property.write("99XX99", 2, 5, "zoopla").should == expected
    end

    it "adds empty entries if not enough features" do
      expected = "99XX99_1868678^^^^^^N4^3PS^Kitchen^Bar^Garage^Terrace^^^this is my summary^this is my description^99XX99^0^5^4^500^^0^^^Latimer Road, Tyining^1^^^^^0^^2^^99XX99_1868678_IMG_00.jpg^99XX99_1868678_IMG_01.jpg^99XX99_1868678_IMG_02.jpg^^^^^^^~\r\n"
      @property.write("99XX99", 6, 5, "zoopla").should == expected
    end

    it "limits the number of photos written" do
      expected = "99XX99_1868678^^^^^^N4^3PS^Kitchen^Bar^Garage^Terrace^this is my summary^this is my description^99XX99^0^5^4^500^^0^^^Latimer Road, Tyining^1^^^^^0^^2^^99XX99_1868678_IMG_00.jpg^99XX99_1868678_IMG_01.jpg^^^^^~\r\n"
      @property.write("99XX99", 4, 2, "zoopla").should == expected
    end

    it "adds empty entries if not enough photos" do
      expected = "99XX99_1868678^^^^^^N4^3PS^Kitchen^Bar^Garage^Terrace^this is my summary^this is my description^99XX99^0^5^4^500^^0^^^Latimer Road, Tyining^1^^^^^0^^2^^99XX99_1868678_IMG_00.jpg^99XX99_1868678_IMG_01.jpg^99XX99_1868678_IMG_02.jpg^^^^^^^^~\r\n"
      @property.write("99XX99", 4, 6, "zoopla").should == expected
    end

  end

end
