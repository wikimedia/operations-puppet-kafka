# == Class kafka::mirror
# Sets up a Kafka MirrorMaker and ensures that it is running.
#
# == Parameters:
# $enabled                    - If false, Kafka Mirror Maker service will not be
#                               started.  Default: true.
#
# $destination_brokers        - Hash of Kafka Broker to which you want to produce configs keyed by
#                               fqdn of each kafka broker node.  This Hash
#                               should be of the form:
#                               { 'hostA' => { 'id' => 1, 'port' => 12345 }, 'hostB' => { 'id' => 2 }, ... }
#                               'port' is optional, and will default to 9092.

# $jmx_port                    - Port on which to expose JMX metrics.  Default: 9999
#
class kafka::mirror(
    $enabled                               = true,
    $destination_brokers                   = $kafka::defaults::brokers,

    $jmx_port                              = $kafka::defaults::jmx_port,

    $topic_whitelist                       = $kafka::defaults::topic_whitelist,
    $topic_blacklist                       = $kafka::defaults::topic_blacklist,

    $producer_type                         = $kafka::defaults::producer_type,
    $producer_compression_codec            = $kafka::defaults::producer_compression_codec,
    $producer_serializer_class             = $kafka::defaults::producer_serializer_class,
    $producer_queue_buffering_max_ms       = $kafka::defaults::producer_queue_buffering_max_ms,
    $producer_queue_buffering_max_messages = $kafka::defaults::producer_queue_buffering_max_messages,
    $producer_queue_enqueue_timeout_ms     = $kafka::defaults::producer_queue_enqueue_timeout_ms,
    $producer_batch_num_messages           = $kafka::defaults::producer_batch_num_messages,

    # TODO: check on names here, can we make these consistent?
    $num_streams                           = $kafka::defaults::num_streams,
    $num_producers                         = $kafka::defaults::num_producers,
    $queue_size                            = $kafka::defaults::queue_size,

    $producer_properties_template          = $kafka::defaults::producer_properties_template,
    $default_template                      = $kafka::defaults::mirror_default_template

) inherits kafka::defaults
{
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

    file { '/etc/default/kafka-mirror':
        content => template($default_template),
        require => Package['kafka-mirror'],
    }

    # Make sure /etc/kafka/mirror is a directory.
    # MirrorMaker will read consumer and producer
    # properties files out of this directory.
    file { '/etc/kafka/mirror':
        ensure => 'directory',
        require => Package['kafka-mirror'],
    }

    # MirrorMaker will produce to this cluster
    # of Kafka Brokers.
    $brokers = $destination_brokers
    file { '/etc/kafka/mirror/producer.properties':
        content => template($producer_properties_template),
        require => Package['kafka-mirror'],
    }

    # Start the Kafka MirrorMaker daemon.
    # We don't want to subscribe to the config files here.
    # It will be better to manually restart Kafka MirrorMaker
    # when the config files changes.
    $kafka_mirror_ensure = $enabled ? {
        false   => 'stopped',
        default => 'running',
    }
    service { 'kafka-mirror':
        ensure     => $kafka_mirror_ensure,
        require    => [
            File['/etc/kafka/mirror/producer.properties'],
            File['/etc/default/kafka-mirror'],
        ],
        hasrestart => true,
        hasstatus  => true,
    }
}
