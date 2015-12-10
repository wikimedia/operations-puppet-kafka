# == Class kafka
# Installs kafka-common and kafka-cli packages.
# You might not need to include this class directly.
# Use just kafka::server to set up a Kafka Broker, or just
# kafka::mirror to set upa Kafka MirrorMaker service should suffice.
#
# == Parameters:
#
# $version   - Kafka package version number.  Set this
#              if you need to override the default
#              package version.  If you override this,
#              the version must be >= 0.8.  Default: installed.
class kafka(
    $version = $kafka::defaults::version
)
{
    package { ['kafka-common', 'kafka-cli']:
        ensure => $version,
    }
}
