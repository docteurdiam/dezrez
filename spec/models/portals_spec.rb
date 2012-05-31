require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Subscriber do

  it "pushes feeds to the Zoopla website" do
    Portals.new({"image_directory" => "/home/diam/0-ONE/sites/diamond-residential/wp-content/uploads", "website" => "http://localhost/diamondresidential/", "portals" => {"deployment" => {"username" => "hhh", "password" => "dvbfvbvf", "branch_id" => 51272, "url" => "ftp.d.com"}}}).push("deployment")
  end

end
