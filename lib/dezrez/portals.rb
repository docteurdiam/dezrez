require 'net/ftp'
require 'zip/zip'
require 'logging'

class Portals

  def initialize(config)
    @config = config
    @logger = Logging.logger[self]
    @logger.add_appenders('stdout', 'logfile')
  end

  def push(portal, rentperiod)
    properties = Subscriber.new.pull(@config["image_directory"], rentperiod)
    branch_id = @config["portals"][portal]["branch_id"]
    @logger.info("Creating the feed.")
    feed = Feed.new.build(properties, branch_id, portal)
    @logger.info "Created the feed #{feed.filename}."
    zipfile_name = create_zip_archive(feed, properties, portal)
    @logger.info "Created the zip archive #{zipfile_name}."
    transfer(zipfile_name, portal)
  end

  private

  def create_zip_archive(feed, properties, portal)
    branch_id = @config["portals"][portal]["branch_id"]
    output_dir = "/tmp/" + portal
    Dir.mkdir(output_dir) unless File.exists?(output_dir)
    zipfile_name = File.join(output_dir, branch_id.to_s + ".zip")
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

  def transfer(filename, portal)
    username = @config["portals"][portal]["username"]
    password = @config["portals"][portal]["password"]
    @logger.info("Transferring the feed to #{portal.titleize} using credentials #{username}/#{password}")
    url = @config["portals"][portal]["url"]
    ftp = Net::FTP.new
    ftp.connect(url, 21)
    ftp.login(username, password)
    destination = File.basename(filename)
    @logger.info("Moving file #{filename} to #{destination} via FTP")
    ftp.putbinaryfile(filename, destination)
    ftp.close
  end

end
