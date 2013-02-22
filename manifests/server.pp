# == Class kafka::server
# Sets up a Kafka Broker Server and ensures that it is running.
#
# == Parameters:
# $enabled                     - If false, Kafka Broker Server will not be
#                                started.  Default: true.
#
# $log_dir                     - Directory in which the broker will store its
#                                received log event data.
#                                (This is log.dir in server.properties).
#                                Default: /var/spool/kafka
#
# $jmx_port                    - Port on which to expose JMX metrics.  Default: 9999
#
# $num_partitions              - The number of logical event partitions per
#                                topic per server.  Default: 1
#
# $num_network_threads         - The number of threads handling network
#                                requests.  Default: 2
#
# $num_io_threads              - The number of threads doing disk I/O.  Default: 2
#
# $socket_send_buffer_bytes    - The byte size of the send buffer (SO_SNDBUF)
#                                used by the socket server.  Default: 1048576
#
# $socket_receive_buffer_bytes - The byte size of receive buffer (SO_RCVBUF)
#                                used by the socket server.  Default: 1048576
#
# $socket_request_max_bytes    - The maximum size of a request that the socket
#                                server will accept.  Default: 104857600
#
# $log_flush_interval_messages - The number of messages to accept before
#                                forcing a flush of data to disk.  Default 10000
#
# $log_flush_interval_ms       - The maximum amount of time a message can sit
#                                in a log before we force a flush: Default 1000 (1 second)
#
# $log_retention_hours         - The minimum age of a log file to be eligible
#                                for deletion.  Default 1 week
#
# $log_retention_size          - A size-based retention policy for logs.
#                                Default: undef (disabled)
#
# $log_segment_bytes           - The maximum size of a log segment file. When
#                                this size is reached a new log segment will
#                                be created:  Default 536870912 (512MB)
#
# $log_cleanup_interval_mins   - The interval at which log segments are checked
#                                to see if they can be deleted according to the
#                                retention policies.  Default: 1
#
# $log_cleanup_policy          - The default policy for handling log tails.
#                                Can be either delete or dedupe.  Default: delete
#
# $metrics_dir                 - Directory in which to store metrics CSVs.  Default: undef (metrics disabled)
#
class kafka::server(
    $enabled                         = true,
    $log_dir                         = $kafka::defaults::log_dir,
    $jmx_port                        = $kafka::defaults::jmx_port,
    $num_partitions                  = $kafka::defaults::num_partitions,

    $num_network_threads             = $kafka::defaults::num_network_threads,
    $num_io_threads                  = $kafka::defaults::num_io_threads,
    $socket_send_buffer_bytes        = $kafka::defaults::socket_send_buffer_bytes,
    $socket_receive_buffer_bytes     = $kafka::defaults::socket_receive_buffer_bytes,
    $socket_request_max_bytes        = $kafka::defaults::socket_request_max_bytes,

    $log_flush_interval_messages     = $kafka::defaults::log_flush_interval_messages,
    $log_flush_interval_ms           = $kafka::defaults::log_flush_interval_ms,
    $log_retention_hours             = $kafka::defaults::log_retention_hours,
    $log_retention_bytes             = $kafka::defaults::log_retention_bytes,
    $log_segment_bytes               = $kafka::defaults::log_segment_bytes,

    $log_cleanup_interval_mins       = $kafka::defaults::log_cleanup_interval_mins,
    $log_cleanup_policy              = $kafka::defaults::log_cleanup_policy,

    $metrics_dir                     = $kafka::defaults::metrics_dir,

    $server_properties_template      = $kafka::defaults::server_properties_template,
    $default_template                = $kafka::defaults::default_template
) inherits kafka::defaults
{
    # kafka class must be included before kafka::servver
    Class['kafka'] -> Class['kafka::server']

    # define local variables from kafka class for use in ERb template.
    $zookeeper_hosts                 = $kafka::zookeeper_hosts
    $zookeeper_connection_timeout_ms = $kafka::zookeeper_connection_timeout_ms

    # Get this broker's id and port out of the $kafka::hosts configuration hash
    $broker_id   = $kafka::hosts[$::fqdn]['id']

    # Using a conditional assignment selector with a
    # Hash value results in a puppet syntax error.
    # Using an if/else instead.
    if ($kafka::hosts[$::fqdn]['port']) {
        $broker_port = $kafka::hosts[$::fqdn]['port']
    }
    else {
        $broker_port = $kafka::defaults::default_broker_port
    }

    file { '/etc/default/kafka':
        content => template($default_template)
    }
    file { '/etc/kafka/server.properties':
        content => template($server_properties_template),
    }

    file { $log_dir:
        ensure  => 'directory',
        owner   => 'kafka',
        group   => 'kafka',
        mode    => '0755',
    }

    # If we are using Kafka Metrics Reporter, ensure
    # that the $metrics_dir exists.
    if ($metrics_dir and !defined(File[$metrics_dir])) {
        file { $metrics_dir:
            ensure  => 'directory',
            owner   => 'kafka',
            group   => 'kafka',
            mode    => '0755',
        }
    }

    # Start the Kafka server.
    # We don't want to subscribe to the config files here.
    # It will be better to manually restart Kafka when
    # the config files changes.
    $kafka_ensure = $enabled ? {
        false   => 'stopped',
        default => 'running',
    }
    service { 'kafka':
        ensure     => $kafka_ensure,
        require    => [
            File['/etc/kafka/server.properties'],
            File['/etc/default/kafka'],
            File[$log_dir]
        ],
    }
}
