# == Define kafka::mirror::consumer
# Kafka MirrorMaker takes multiple consumer.property files.
# Each one of these property files defines a Zookeeper URL
# (hosts/chroot) from which information about a Kafka Broker
# cluster may be read.  This is a define so that nay number
# of source Kafka clusters may be configured.
#
# == Usage:
#   kafka::mirror::consumer { 'clusterA':
#       $zookeeper_hosts  => ['zk1.example.com', 'zk2.example.com', 'zk3.example.com'],
#       $zookeeper_chroot => '/kafka/clusterA',
#   }
#
# == Parameters:
# $zookeeper_hosts                  - Array of zookeeper hostname/IP(:port)s.
#
# $zookeeper_chroot                 - Znode Path in zookeeper in which to keep Kafka data.
#                                     Default: undef (the root znode).  Note that if you set
#                                     this paramater, the Znode will not be created for you.
#                                     You must do so manually yourself.  See the README
#                                     for instructions on how to do so.
#
# $zookeeper_connection_timeout_ms  - Timeout in ms for connecting to zookeeper.
#                                     Default: 1000000
#
# $consumer_group_id                - Consumer ID.  This will be used to save the
#                                     consumed high water mark for this consumer
#                                     in Zookeeper.
#
define kafka::mirror::consumer(
    $zookeeper_hosts,
    $zookeeper_chroot                   = undef,
    $zookeeper_connection_timeout_ms    = 1000000,
    $consumer_group_id                  = "mirror${zookeeper_chroot}",
    $consumer_properties_template       = 'kafka/consumer.properties.erb'
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

    file { "/etc/kafka/mirror/consumer.${name}.properties":
        content => template($consumer_properties_template),
        before  => Service['kafka-mirror'],
    }
}