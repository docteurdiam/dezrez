require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Photo do

  describe "when downloading" do

    it "copies images to the local filesystem" do
      photo = Photo.new
      photo.remote_url = "http://data.dezrez.com/PictureResizer.ASP?PropertyID=2069973&PhotoID=6&AgentID=398&BranchID=603"
      photo.download('/tmp')
      File.exists?('/tmp/2069973.6.jpg').should be_true
    end

    it "updates the filename location" do
      photo = Photo.new
      photo.remote_url = "http://data.dezrez.com/PictureResizer.ASP?PropertyID=2069973&PhotoID=6&AgentID=398&BranchID=603"
      photo.download('/tmp')
      photo.filename.should == '/tmp/2069973.6.jpg'
    end

  end
end