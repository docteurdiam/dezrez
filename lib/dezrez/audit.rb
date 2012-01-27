require 'logging'

class Audit

  def self.debug(msg)
    @@logger ||= Logging.logger(STDOUT)
    @@logger.debug(msg)
  end

  def self.info(msg)
    @@logger ||= Logging.logger(STDOUT)
    @@logger.info(msg)
  end

end