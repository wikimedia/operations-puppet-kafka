# == Class kafka::server
# Sets up a Kafka Broker and ensures that it is running.
#
# == Parameters:

# $enabled                              - If false, Kafka Broker Server will not be
#                                         started.  Default: true.
#
# $brokers                              - Hash of Kafka Broker configs keyed by
#                                         fqdn of each kafka broker node.  This Hash
#                                         should be of the form:
#                                           { 'hostA' => { 'id' => 1, 'port' => 12345 }, 'hostB' => { 'id' => 2 }, ... }
#                                         'port' is optional, and will default to 9092.
#
# $log_dirs                             - Array of directories in which the broker will store its
#                                         received log event data.
#                                         (This is log.dir in server.properties).
#                                         Default: [/var/spool/kafka]
#
# $zookeeper_hosts                      - Array of zookeeper hostname/IP(:port)s.
#                                         Default: ['localhost:2181]
#
# $zookeeper_connection_timeout_ms      - Timeout in ms for connecting to zookeeper.
#                                         Default: 1000000
#
# $zookeeper_chroot                     - Path in zookeeper in which to keep Kafka data.
#                                         Default: undef (the root znode).  Note that if you set
#                                         this paramater, the znode will not be created for you.
#                                         You must do so manually yourself.  See the README
#                                         for instructions on how to do so.
#
# $jmx_port                             - Port on which to expose JMX metrics.  Default: 9999
#
# $heap_opts                            - Heap options to pass to JVM on startup.  Default: undef
#
# $nofiles_ulimit                       - If set, the kafka user's ulimit will be set to this, and the
#                                         kafka server will set this via ulimit -n.  You
#                                         will probably need to reboot for this to take effect.
#
# $auto_create_topics_enable            - If autocreation of topics is allowed.  Default: false
#
# $default_replication_factor           - The default replication factor for automatically created topics  Default: size(keys($brokers))
#
#
# $replica_lag_time_max_ms              - If a follower hasn't sent any fetch requests for this window
#                                         of time, the leader will remove the follower from ISR.
#                                         Default: undef
# $replica_lag_max_messages             - If a replica falls more than this many messages behind the leader,
#                                         the leader will remove the follower from ISR.
#                                         Default: undef
#
# $replica_socket_timeout_ms            - The socket timeout for network requests to the leader for
#                                         replicating data.  Default: undef
#
# $replica_socket_receive_buffer_bytes  - The socket receive buffer for network requests to the leader
#                                         for replicating data.  Default: undef
#
# $num_replica_fetchers                 - Number of threads used to replicate messages from leaders.
#                                         Default: 1
#
# $replica_fetch_max_bytes              - The number of bytes of messages to attempt to fetch for each
#                                         partition in the fetch requests the replicas send to the leader.
#                                         Default: 1024 * 1024
#
# $num_network_threads                  - The number of threads handling network
#                                         requests.  Default: 3
#
# $num_io_threads                       - The number of threads doing disk I/O.  Default: size($log_dirs)
#
# $socket_send_buffer_bytes             - The byte size of the send buffer (SO_SNDBUF)
#                                          used by the socket server.  Default: 1048576
#
# $socket_receive_buffer_bytes          - The byte size of receive buffer (SO_RCVBUF)
#                                         used by the socket server.  Default: 1048576
#
# $socket_request_max_bytes             - The maximum size of a request that the socket
#                                         server will accept.  Default: 104857600
#
# $log_flush_interval_messages          - The number of messages to accept before
#                                         forcing a flush of data to disk.  Default 10000
#
# $log_flush_interval_ms                - The maximum amount of time a message can sit
#                                         in a log before we force a flush: Default 1000 (1 second)
#
# $log_retention_hours                  - The minimum age of a log file to be eligible
#                                         for deletion.  Default 1 week
#
# $log_retention_size                   - A size-based retention policy for logs.
#                                         Default: undef (disabled)
#
# $log_segment_bytes                    - The maximum size of a log segment file. When
#                                         this size is reached a new log segment will
#                                         be created:  Default 536870912 (512MB)
#
# $log_cleanup_interval_mins            - The interval at which log segments are checked
#                                         to see if they can be deleted according to the
#                                         retention policies.  Default: 1
#
# $log_cleanup_policy                   - The default policy for handling log tails.
#                                         Can be either delete or dedupe.  Default: delete
#
# $metrics_properties                   - Config hash of Kafka metrics property key => value pairs.
#                                         Use this for configuring your own metrics reporter classes.
#                                         Default: undef
#
# $kafka_log_file                       - File in which to write Kafka logs (not event message data).
#                                         Default: /var/log/kafka/kafka.log

#
class kafka::server(
    $enabled                             = true,

    $brokers                             = $kafka::defaults::brokers,
    $log_dirs                            = $kafka::defaults::log_dirs,

    $zookeeper_hosts                     = $kafka::defaults::zookeeper_hosts,
    $zookeeper_connection_timeout_ms     = $kafka::defaults::zookeeper_connection_timeout_ms,
    $zookeeper_chroot                    = $kafka::defaults::zookeeper_chroot,

    $jmx_port                            = $kafka::defaults::jmx_port,
    $heap_opts                           = $kafka::defaults::heap_opts,
    $nofiles_ulimit                      = $kafka::defaults::nofiles_ulimit,

    $auto_create_topics_enable           = $kafka::defaults::auto_create_topics_enable,

    $default_replication_factor          = size(keys($brokers)),
    $replica_lag_time_max_ms             = $kafka::defaults::replica_lag_time_max_ms,
    $replica_lag_max_messages            = $kafka::defaults::replica_lag_max_messages,
    $replica_socket_timeout_ms           = $kafka::defaults::replica_socket_timeout_ms,
    $replica_socket_receive_buffer_bytes = $kafka::defaults::replica_socket_receive_buffer_bytes,
    $num_replica_fetchers                = $kafka::defaults::num_replica_fetchers,
    $replica_fetch_max_bytes             = $kafka::defaults::replica_fetch_max_bytes,

    $num_network_threads                 = $kafka::defaults::num_network_threads,
    $num_io_threads                      = size($log_dirs),
    $socket_send_buffer_bytes            = $kafka::defaults::socket_send_buffer_bytes,
    $socket_receive_buffer_bytes         = $kafka::defaults::socket_receive_buffer_bytes,
    $socket_request_max_bytes            = $kafka::defaults::socket_request_max_bytes,

    $log_flush_interval_messages         = $kafka::defaults::log_flush_interval_messages,
    $log_flush_interval_ms               = $kafka::defaults::log_flush_interval_ms,
    $log_retention_hours                 = $kafka::defaults::log_retention_hours,
    $log_retention_bytes                 = $kafka::defaults::log_retention_bytes,
    $log_segment_bytes                   = $kafka::defaults::log_segment_bytes,

    $log_cleanup_interval_mins           = $kafka::defaults::log_cleanup_interval_mins,
    $log_cleanup_policy                  = $kafka::defaults::log_cleanup_policy,

    $metrics_properties                  = $kafka::defaults::metrics_properties,
    $kafka_log_file                      = $kafka::defaults::kafka_log_file,

    $server_properties_template          = $kafka::defaults::server_properties_template,
    $default_template                    = $kafka::defaults::server_default_template,
    $log4j_properties_template           = $kafka::defaults::log4j_properties_template
) inherits kafka::defaults
{
    # Kafka class must be included before kafka::server.
    # Using 'require' here rather than an explicit class dependency
    # so that this class can be used without having to manually
    # include the base kafka class.  This is for elegance only.
    # You'd only need to manually include the base kafka class if
    # you need to explicitly set the version of the Kafka package
    # you want installed.
    require ::kafka

    # Get this broker's id and port out of the $kafka::hosts configuration hash
    $broker_id   = $brokers[$::fqdn]['id']

    # Using a conditional assignment selector with a
    # Hash value results in a puppet syntax error.
    # Using an if/else instead.
    if ($brokers[$::fqdn]['port']) {
        $broker_port = $brokers[$::fqdn]['port']
    }
    else {
        $broker_port = $kafka::defaults::default_broker_port
    }

    # Render out Kafka Broker config files.
    file { '/etc/default/kafka':
        content => template($default_template),
    }
    file { '/etc/kafka/server.properties':
        content => template($server_properties_template),
    }

    # This is the message data directory,
    # not to be confused with the $kafka_log_file,
    # which contains daemon process logs.
    file { $log_dirs:
        ensure  => 'directory',
        owner   => 'kafka',
        group   => 'kafka',
        mode    => '0755',
    }

    # log4j configuration for Kafka daemon
    # process logs (this uses $kafka_log_dir).
    file { '/etc/kafka/log4j.properties':
        content => template($log4j_properties_template),
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
        ensure     => 'running',
        require    => [
            File['/etc/kafka/server.properties'],
            File['/etc/kafka/log4j.properties'],
            File['/etc/default/kafka'],
            File[$log_dirs],
        ],
        hasrestart => true,
        hasstatus  => true,
    }
}
