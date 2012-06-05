require 'active_record'
require 'logging'

Logging.color_scheme( 'bright',
   :levels => {
     :info => :green,
     :warn => :yellow,
     :error => :red
   },
   :date => :blue,
   :logger => :cyan,
   :message => :white
 )

Logging.appenders.stdout(
  'stdout',
  :layout => Logging.layouts.pattern(
    :pattern => '[%d] %-5l %c: %m\n',
    :color_scheme => 'bright'
  )
)

Logging.appenders.file(
  'logfile',
  :filename => '/var/log/dezrez/audit.log',
  :layout => Logging.layouts.pattern(
    :pattern => '[%d] %-5l %c: %m\n'
  )
)

require 'dezrez/post'
require 'dezrez/photo'
require 'dezrez/property'
require 'dezrez/property_parser'
require 'dezrez/portals'
require 'dezrez/post'
require 'dezrez/post_meta'
require 'dezrez/feed'
require 'dezrez/version'
require 'dezrez/subscriber'

