require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Post do

  before(:each) do
    @property = Property.new
    @property.id = 1868678
    @property.location = "Newcastle"
    @property.price = 500
    @property.bedrooms = 5
    @property.bathrooms = 4
    @property.summary = "this is my summary"
    @property.description = "this is my description"
    @property.display_address = "Latimer Road, Tyining"
    @property.sale = "false"
  end

  describe "when generating posts" do

    before(:each) do
      Post.delete_all("post_type = 'listing'")
    end

    it "saves the generated posts" do
      Post.generate(@property, "http://localhost/diamondresidential/")
      Post.where('post_type = ?', 'listing').count.should == 1
    end

    it "saves the associated postmeta" do
      Post.generate(@property, "http://localhost/diamondresidential/")
      Post.where('post_type = ?', 'listing').first.post_meta.count.should == 15
    end

  end

end
