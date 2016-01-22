# == Define kafka::mirror::consumer
# kafka::mirror::consumers are grouped together by $mirror_name.
# $mirror_name should match the title of the kafka::mirror instance
# you want this consumer to be associated with.
#
# == Usage:
#   kafka::mirror::consumer { 'clusterA':
#       mirror_name   => 'aggregate',
#       zookeeper_url => 'zk:2181/kafka/clusterA',
#   }
#
# == Parameters:
# $zookeeper_url                    - URL to Kafka in zookeeper, including
#                                     chroot.
#
# $zookeeper_connection_timeout_ms  - Timeout in ms for connecting to zookeeper.
#                                     Default: 6000
#
# $zookeeper_session_timeout_ms     - Timeout in ms for session to zookeeper.
#                                     Default: 6000
#
# $auto_commit_enable               - If true, periodically commit to zookeeper
#                                     the offset of messages already fetched by
#                                     the consumer. Default: true
# $auto_commit_interval_ms          - The frequency in ms that the consumer
#                                     offsets are committed to zookeeper.
#                                     Default: 6000
# $auto_offset_reset                - smallest, largest, or throw exception.
#                                     Default: largest
#
define kafka::mirror::consumer(
    $mirror_name,
    $zookeeper_url,
    $zookeeper_connection_timeout_ms    = 6000,
    $zookeeper_session_timeout_ms       = 6000,
    $auto_commit_enable                 = true,
    $auto_commit_interval_ms            = 6000,
    $auto_offset_reset                  = 'largest',
    $consumer_properties_template       = 'kafka/mirror/consumer.properties.erb'
)
{
    # Kafka class must be included before kafka::mirror::consumer.
    # Using 'require' here rather than an explicit dependency
    # so that this class can be used without having to manually
    # include the base kafka class.  This is for elegance only.
    # You'd only need to manually include the base kafka class if
    # you need to explicitly set the version of the Kafka package
    # you want installed.
    require ::kafka

    @file { "/etc/kafka/mirror/${$mirror_name}/consumer.${title}.properties":
        content => template($consumer_properties_template),
        tag     => ["kafka-mirror-${mirror_name}-consumer"],
        before  => Service["kafka-mirror-${mirror_name}"]
    }
}
