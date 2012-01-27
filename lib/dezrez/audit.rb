require 'logging'

class Audit

  def self.debug(msg)
    @@logger ||= Logging.logger(STDOUT)
    @@logger.debug(msg)
  end

end