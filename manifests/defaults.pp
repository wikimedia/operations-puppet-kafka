# == Class kafka::defaults
# Default Kafka Configs.
#
class kafka::defaults {
    # default Kafka Broker Server Port.
    # This is used by server.pp as the default
    # $broker_port in server.properties.erb
    # if a host in the $kafka::hosts array
    # does not have a 'port' key set.
    $default_broker_port = 9092
    $brokers = {
        "${::fqdn}" => {
            'port' => $default_broker_port,
            'id'   => 1,
        },
    }

    $zookeeper_hosts                     = ['localhost:2181']
    $zookeeper_connection_timeout_ms     = 6000
    $zookeeper_session_timeout_ms        = 6000

    $zookeeper_chroot                    = undef

    $kafka_log_file                      = '/var/log/kafka/kafka.log'
    $producer_type                       = 'async'
    $producer_batch_num_messages         = 200
    $consumer_group_id                   = 'test-consumer-group'

    # Broker Server settings
    $java_home                           = undef
    $jmx_port                            = 9999
    $log_dirs                            = ['/var/spool/kafka']
    $heap_opts                           = undef
    $nofiles_ulimit                      = 8192

    $auto_create_topics_enable           = false

    $replica_lag_time_max_ms             = undef
    $replica_lag_max_messages            = undef
    $replica_socket_timeout_ms           = undef
    $replica_socket_receive_buffer_bytes = undef
    $num_replica_fetchers                = 1
    $replica_fetch_max_bytes             = 1048576

    $num_network_threads                 = 3
    # $num_io_threads                      = size($log_dirs) # this default is directly in server.pp
    $socket_send_buffer_bytes            = 1048576
    $socket_receive_buffer_bytes         = 1048576
    $socket_request_max_bytes            = 104857600

    $log_flush_interval_messages         = 10000
    $log_flush_interval_ms               = 3000

    $log_retention_hours                 = 168     # 1 week
    $log_retention_bytes                 = undef
    $log_segment_bytes                   = 536870912

    $log_cleanup_policy                  = 'delete'
    $log_cleanup_interval_mins           = 1

    $metrics_properties                  = undef

    $jvm_performance_opts                = undef

    # Kafka package version.
    $version                             = 'installed'

    # MirrorMaker settings
    $topic_whitelist                     = '.*'
    $topic_blacklist                     = undef
    $num_streams                         = 1
    $num_producers                       = 1
    $queue_size                          = 10000

    # Default puppet paths to template config files.
    # This allows us to use custom template config files
    # if we want to override more settings than this
    # module yet supports.
    $producer_properties_template        = 'kafka/producer.properties.erb'
    $consumer_properties_template        = 'kafka/consumer.properties.erb'
    $log4j_properties_template           = 'kafka/log4j.properties.erb'
    $server_properties_template          = 'kafka/server.properties.erb'
    $server_default_template             = 'kafka/kafka.default.erb'
    $mirror_default_template             = 'kafka/kafka-mirror.default.erb'

}
