require 'net/ftp'
require 'zip/zip'
require 'logging'

class Portals

  def initialize(config)
    @config = config
  end

  def push(portal)
    properties = Subscriber.new.pull(@config["image_directory"])
    branch_id = @config["portals"][portal]["branch_id"]
    Audit.debug("Creating the feed.")
    feed = Feed.build(properties, branch_id, portal)
    Audit.info "Created the feed #{feed.filename}."
    zipfile_name = create_zip_archive(feed, properties, portal)
    Audit.info "Created the zip archive #{zipfile_name}."
    transfer(zipfile_name)
  end

  private

  def create_zip_archive(feed, properties, portal)
    branch_id = @config["portals"][portal]["branch_id"]
    output_dir = "/tmp/" + portal
    Dir.mkdir(output_dir) unless File.exists?(output_dir)
    zipfile_name = File.join(output_dir, branch_id + ".zip")
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
    username = @config["portals"]["zoopla"]["username"]
    password = @config["portals"]["zoopla"]["password"]
    Audit.debug("Transferring the feed to Zoopla using credentials #{username}/#{password}")
    url = @config["portals"]["zoopla"]["url"]
    ftp = Net::FTP.new
    ftp.connect(url, 21)
    ftp.login(username, password)
    destination = File.basename(filename)
    Audit.debug("Copying file #{filename} to #{destination}")
    ftp.putbinaryfile(filename, destination)
    ftp.close
  end

end