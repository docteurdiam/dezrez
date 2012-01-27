require 'open-uri'
require 'cgi'

class Photo
  attr_accessor :remote_url, :filename

  def initialize(args = {})
    args.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end

  def download (download_directory)
    uri = URI.parse(@remote_url)
    uri_params = CGI.parse(uri.query)
    @filename = File.join(download_directory, "#{uri_params["PropertyID"][0]}.#{uri_params["PhotoID"][0]}.jpg")
    image = open(@filename , "wb")
    image.write(open(@remote_url + "&width=300").read)
    image.close
    self
  end

end