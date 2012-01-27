require 'net/ftp'
require 'zip/zip'
require 'logging'

class Portals

  def push
    properties = Subscriber.new.pull(@config[:image_directory])
    branch_id = @config[:portals][:zoopla][:branch_id]
    feed = Feed.build(properties, branch_id)
    Audit.debug "[#{DateTime.now.strftime("%H:%M:%S")}] Created the feed #{feed.filename}."
    zipfile_name = self.create_zip_archive(feed, properties)
    Audit.debug "[#{DateTime.now.strftime("%H:%M:%S")}] Created the zip archive #{zipfile_name}."
    transfer(zipfile_name)
  end

  private

  def create_zip_archive(feed, properties)
    branch_id = @config[:portals][:zoopla][:branch_id]
    zipfile_name = File.join("/tmp", branch_id + ".zip")
    File.delete(zipfile_name) if File.exists?(zipfile_name)
    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
      zipfile.add(File.basename(feed.filename), feed.filename)
      properties.each do |property|
        property.photos.each_with_index do |photo, index|
          zipfile.add("#{branch_id}_#{property.id}_IMG_#{sprintf("%02d", index)}.jpg", photo.filename)
        end
      end
    end
    zipfile_name
  end

  def transfer(filename)
    username = @config[:portals][:zoopla][:username]
    password = @config[:portals][:zoopla][:password]
    url = @config[:portals][:zoopla][:url]
    ftp = Net::FTP.new
    ftp.connect(url, 21)
    ftp.login(username, password)
    ftp.putbinaryfile(filename, filename)
    ftp.close
  end

end