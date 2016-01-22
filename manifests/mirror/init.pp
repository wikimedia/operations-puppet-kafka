# == Class kafka::mirror::init
# This class only exists because kafka::mirror is a define.  These
# resources are common to every kafka mirror define and we don't
# want to declare them more than once.
#
class kafka::mirror::init {
    # Kafka class must be included before kafka::mirror.
    # Using 'require' here rather than an explicit class dependency
    # so that this class can be used without having to manually
    # include the base kafka class.  This is for elegance only.
    # You'd only need to manually include the base kafka class if
    # you need to explicitly set the version of the Kafka package
    # you want installed.
    require ::kafka

    package { 'kafka-mirror':
        ensure => $::kafka::version
    }

    # Remove the kafka-mirror .deb provided kafka-mirror files.
    # This define will install instance specific ones.
    file { [
            '/etc/init.d/kafka-mirror',
            '/lib/systemd/system/kafka-mirror.service',
            '/etc/default/kafka-mirror',
        ]:
        ensure => 'absent'
    }

    # Have puppet manage totally manage this directory.
    # Anything it doesn't know about will be removed.
    file { '/etc/kafka/mirror':
        ensure  => 'directory',
        recurse => true,
        purge   => true,
        force   => true,
    }
}
