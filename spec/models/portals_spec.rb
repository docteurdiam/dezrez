require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Subscriber do

  it "pushes feeds to the Zoopla website" do
    Portals.new({}).push
  end

end