# == Class kafka::client
# Installs kafka-client package.
#
class kafka::client {
    # Kafka class must be included before kafka::client.
    # Using 'require' here rather than an explicit class dependency
    # so that this class can be used without having to manually
    # include the base kafka class.  This is for elegance only.
    # You'd only need to manually include the base kafka class if
    # you need to explicitly set the version of the Kafka package
    # you want installed.
    require ::kafka

    package { 'kafka-client':
        ensure => $::kafka::version
    }
}
