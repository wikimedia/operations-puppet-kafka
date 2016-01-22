# == Define kafka::mirror
# Sets up a Kafka MirrorMaker instance and ensures that it is running.
# You must declare your kafka::mirror::consumers before this class.
#
# NOTE: This does not work without systemd.  Make sure you are including
# this define on a node that supports systemd.
#
# TODO: support ensure => 'absent'
#
# == Usage
#
#   # Mirror the 'main' and 'secondary' Kafka clusters
#   # to the 'aggregate' Kafka cluster.
#   kafka::mirror::consumer { 'main':
#       mirror_name   => 'aggregate',
#       zookeeper_url => 'zk:2181/kafka/main',
#   }
#   kafka::mirror::consumer { 'secondary':
#       mirror_name   => 'aggregate',
#       zookeeper_url => 'zk:2181/kafka/secondary',
#   }
#
#   kafka::mirror { 'aggregate':
#       destination_brokers => ['ka01:9092','ka02:9092']
#       ...,
#   }
#
# == Parameters
#
# $destination_brokers         - Array of Kafka brokers hosts in your
#                                destination cluster.  These brokers
#                                will be used for bootstrapping the producers
#                                configs and metadata.
#
# $enabled                     - If false, kafka mirror-maker service will not
#                                be started.  Default: true.
#
# $whitelist                   - Java regex matching topics to mirror.
#                                You must set either this or $topic_blacklist
#                                Default: '.*'
#
# $blacklist                   - Java regex matching topics to not mirror.
#                                Default: undef
#                                You must set either this or $topic_whitelist
#
# $num_producers               - Number of producer threads. Default: 1
#
# $num_streams                 - Number of consumer threads. Default: 1
#
# $queue_size                  - Size of intermediate consumer -> producer
#                                queue.  Note that this is different than
#                                $queue_buffering_max_messages, which is the
#                                queue size of messages in async producers.
#                                Default: 10000
#
# $heap_opts                   - Heap options to pass to JVM on startup.
#                                Default: undef
#
# $request_required_acks       - Required number of acks for a produce request.
#                                Default: -1 (all replicas)
# $producer_type               - sync or async.  Default: async
#
# $compression_codec           - none, gzip, or snappy.  Default: snappy
#
# $batch_num_messages          - If async producer, the number of messages
#                                to batch together in a single produce request.
#                                Default: 200
#
# queue_buffering_max_ms       - Maximum time to buffer data when using async
#                                mode. For example a setting of 100 will try to
#                                batch together 100ms of messages to send at
#                                once. Default: 5000
#
# queue_buffering_max_messages - The maximum number of unsent messages that can
#                                be queued up the producer when using async
#                                mode before either the producer must be
#                                blocked or data must be dropped.
#                                Default: 10000
#
# queue_enqueue_timeout_ms     - The amount of time to block before dropping
#                                messages when running in async mode and the
#                                buffer has reached
#                                queue.buffering.max.messages. If set to 0
#                                events will be enqueued immediately or dropped
#                                if the queue is full (the producer send call
#                                will never block). If set to -1 the producer
#                                will block indefinitely and never willingly
#                                drop a send. Default: -1
#
# $jmx_port                    - Port on which to expose MirrorMaker
#                                JMX metrics. Default: 9998
#
define kafka::mirror(
    $destination_brokers,
    $enabled                      = true,

    $whitelist                    = '.*',
    $blacklist                    = undef,

    $num_producers                = 1,
    $num_streams                  = 1,
    $queue_size                   = 10000,
    $heap_opts                    = undef,

    # Producer Settings
    $request_required_acks        = -1,
    $producer_type                = 'async',
    $compression_codec            = 'snappy',

    # Async Producer Settings
    $batch_num_messages           = 200,
    $queue_buffering_max_ms       = 5000,
    $queue_buffering_max_messages = 10000,
    $queue_enqueue_timeout_ms     = -1,

    $jmx_port                     = 9998,

    $producer_properties_template = 'kafka/mirror/producer.properties.erb',
    $systemd_service_template     = 'kafka/mirror/kafka-mirror.systemd.erb',
    $default_template             = 'kafka/mirror/kafka-mirror.default.erb',
    $log4j_properties_template    = 'kafka/log4j.properties.erb',
)
{
    if (!$whitelist and !$blacklist) or ($whitelist and $blacklist) {
        fail('Must set only one of $whitelist or $blacklist.')
    }

    include kafka::mirror::init

    $mirror_name = $title
    file { "/etc/default/kafka-mirror-${mirror_name}":
        content => template($default_template),
        require => Package['kafka-mirror'],
    }

    file { "/etc/kafka/mirror/${mirror_name}":
        ensure  => 'directory',
        recurse => true,
        purge   => true,
    }

    # Log to custom log file for this MirrorMaker instance.
    $kafka_log_file = "/var/log/kafka/kafka-mirror-${mirror_name}.log"
    file { "/etc/kafka/mirror/${mirror_name}/log4j.properties":
        content => template($log4j_properties_template),
    }

    file { "/etc/kafka/mirror/${mirror_name}/producer.properties":
        content => template($producer_properties_template),
        require => Package['kafka-mirror'],
    }

    # Realize all consumer properties files for this MirrorMaker instance.
    # --consumer.configs will be passed a wildcard matching all of the
    # files in /etc/kafka/mirror/$mirror_name/consumer*.properties
    File <| tag == "kafka-mirror-${mirror_name}-consumer" |>

    # Render a systemd service unit file
    file { "/lib/systemd/system/kafka-mirror-${mirror_name}.service":
        content => template($systemd_service_template),
        require => Package['kafka-mirror'],
    }

    # systemd needs a reload to pick up changes to this file.
    exec { "systemd-reload-for-kafka-mirror-${mirror_name}":
        command     => '/bin/systemctl daemon-reload',
        refreshonly => true,
        subscribe   => File["/lib/systemd/system/kafka-mirror-${mirror_name}.service"],
    }

    # Start the Kafka MirrorMaker daemon.
    # We don't want to subscribe to the config files here.
    # It will be better to manually restart Kafka MirrorMaker
    # when the config files changes.
    $service_ensure = $enabled ? {
        false   => 'stopped',
        default => 'running',
    }
    service { "kafka-mirror-${mirror_name}":
        ensure     => $service_ensure,
        require    => [
            File["/etc/kafka/mirror/${mirror_name}/producer.properties"],
            Exec["systemd-reload-for-kafka-mirror-${mirror_name}"],
        ],
        hasrestart => true,
        hasstatus  => true,
    }
}
