# == Class kafka::server::jmxtrans
# Sets up a jmxtrans instance for a Kafka Server Broker
# running on the current host.
# Note: This requires the jmxtrans puppet module found at
# https://github.com/wikimedia/puppet-jmxtrans.
#
# == Parameters
# $jmx_port      - Kafka JMX port
# $ganglia       - Ganglia host:port
# $graphite      - Graphite host:port
# $statsd        - statsd host:port
# $outfile       - outfile to which Kafka stats will be written.
# $objects       - objects parameter to pass to jmxtrans::metrics.  Only use
#                  this if you need to override the default ones that this
#                  class provides.
# $run_interval  - How often jmxtrans should run.        Default: 15
# $log_level     - level at which jmxtrans should log.   Default: info
# $legacy_jmx    - JMX Bean names changed in 0.8.2.  If this is true
#                  he old Bean names will be used.  Default: false.
#
# == Usage
# class { 'kafka::server::jmxtrans':
#     ganglia => 'ganglia.example.org:8649'
# }
#
class kafka::server::jmxtrans(
    $jmx_port       = $kafka::defaults::jmx_port,
    $ganglia        = undef,
    $graphite       = undef,
    $statsd         = undef,
    $outfile        = undef,
    $group_prefix   = undef,
    $objects        = undef,
    $run_interval   = 15,
    $log_level      = 'info',
    $legacy_jmx     = false,
) inherits kafka::defaults
{
    $jmx = "${::fqdn}:${jmx_port}"

    class {'::jmxtrans':
        run_interval => $run_interval,
        log_level    => $log_level,
    }

    # query for metrics from Kafka's JVM
    jmxtrans::metrics::jvm { $jmx:
        ganglia              => $ganglia,
        graphite             => $graphite,
        statsd               => $statsd,
        outfile              => $outfile,
        group_prefix         => $group_prefix,
    }

    # DRY up some often used JMX attributes.
    $kafka_rate_jmx_attrs = {
        'Count'             => { 'slope' => 'positive', 'bucketType' => 'g' },
        'FifteenMinuteRate' => { 'slope' => 'both',     'bucketType' => 'g' },
        'FiveMinuteRate'    => { 'slope' => 'both',     'bucketType' => 'g' },
        'OneMinuteRate'     => { 'slope' => 'both',     'bucketType' => 'g' },
        'MeanRate'          => { 'slope' => 'both',     'bucketType' => 'g' },
    }
    $kafka_timing_jmx_attrs = {
        '50thPercentile'     => { 'slope' => 'both',     'bucketType' => 'g' },
        '75ththPercentile'   => { 'slope' => 'both',     'bucketType' => 'g' },
        '95thPercentile'     => { 'slope' => 'both',     'bucketType' => 'g' },
        '98thPercentile'     => { 'slope' => 'both',     'bucketType' => 'g' },
        '99thPercentile'     => { 'slope' => 'both',     'bucketType' => 'g' },
        '999thPercentile'    => { 'slope' => 'both',     'bucketType' => 'g' },
        'Count'              => { 'slope' => 'positive', 'bucketType' => 'g' },
        'Max'                => { 'slope' => 'both',     'bucketType' => 'g' },
        'Mean'               => { 'slope' => 'both',     'bucketType' => 'g' },
        'Min'                => { 'slope' => 'both',     'bucketType' => 'g' },
        'StdDev'             => { 'slope' => 'both',     'bucketType' => 'g' },
    }
    $kafka_value_jmx_attrs = {
        'Value'             => { 'slope' => 'both',     'bucketType' => 'g' },
    }

    # If we are not using a pre 0.8.2 version of Kafka, then we can use
    # these JMX metric names.
    if !$legacy_jmx {
        $kafka_objects = $objects ? {
            # if $objects was not set, then use this as the
            # default set of Kafka JMX MBean objects to query.
            undef   => [
                # All Topic Metrics
                {
                    'name'          => 'kafka.server:type=BrokerTopicMetrics,name=*',
                    'resultAlias'   => 'kafka.server.BrokerTopicMetrics-AllTopics',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },
                # Per Topic Metrics
                {
                    'name'          => 'kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec,topic=*',
                    'resultAlias'   => 'kafka.server.BrokerTopicMetrics.BytesInPerSec',
                    'typeNames'     => ['topic'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },
                {
                    'name'          => 'kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec,topic=*',
                    'resultAlias'   => 'kafka.server.BrokerTopicMetrics.BytesOutPerSec',
                    'typeNames'     => ['topic'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },
                {
                    'name'          => 'kafka.network:type=BrokerTopicMetrics,name=BytesRejectedPerSec,topic=*',
                    'resultAlias'   => 'kafka.network.BrokerTopicMetrics.BytesRejectedPerSec',
                    'typeNames'     => ['topic'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },
                {
                    'name'          => 'kafka.network:type=BrokerTopicMetrics,name=FailedFetchRequestsPerSec,topic=*',
                    'resultAlias'   => 'kafka.network.BrokerTopicMetrics.FailedFetchRequestsPerSec',
                    'typeNames'     => ['topic'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },
                {
                    'name'          => 'kafka.network:type=BrokerTopicMetrics,name=FailedProduceRequestsPerSec,topic=*',
                    'resultAlias'   => 'kafka.network.BrokerTopicMetrics.FailedProduceRequestsPerSec',
                    'typeNames'     => ['topic'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },
                {
                    'name'          => 'kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec,topic=*',
                    'resultAlias'   => 'kafka.server.BrokerTopicMetrics.MessagesInPerSec',
                    'typeNames'     => ['topic'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },

                # ReplicaManager Metrics
                {
                    'name'          => 'kafka.server:type=ReplicaManager,name=*',
                    'resultAlias'   => 'kafka.server.ReplicaManager',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },

                # ReplicaFetcherManager
                {
                    'name'          => 'kafka.server:type=ReplicaFetcherManager,name=*,clientId=Replica',
                    'resultAlias'   => 'kafka.server.ReplicaFetcherManager',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },

                # Producer/Fetch Request Purgatory Metrics
                {
                    'name'          => 'kafka.server:type=ProducerRequestPurgatory,name=*',
                    'resultAlias'   => 'kafka.server.ProducerRequestPurgatory',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },
                {
                    'name'          => 'kafka.server:type=FetchRequestPurgatory,name=*',
                    'resultAlias'   => 'kafka.server.FetchRequestPurgatory',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },

                # Request Handler Percent Idle
                {
                    'name'          => 'kafka.server:type=KafkaRequestHandlerPool,name=*',
                    'resultAlias'   => 'kafka.server.KafkaRequestHandlerPool',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },


                # Request Metrics

                # Requests Type Metrics
                {
                    'name'          => 'kafka.network:type=RequestMetrics,name=RequestsPerSec,request=*',
                    'resultAlias'   => 'kafka.network.RequestMetrics.RequestsPerSec',
                    'typeNames'     => ['request'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },
                # Request/Response Local Time Metrics
                {
                    'name'          => 'kafka.network:type=RequestMetrics,name=LocalTimeMs,request=*',
                    'resultAlias'   => 'kafka.network.RequestMetrics.LocalTimeMs',
                    'typeNames'     => ['request'],
                    'attrs'         => $kafka_timing_jmx_attrs,
                },
                # Request/Response Remote Time Metrics
                {
                    'name'          => 'kafka.network:type=RequestMetrics,name=RemoteTimeMs,request=*',
                    'resultAlias'   => 'kafka.network.RequestMetrics.RemoteTimeMs',
                    'typeNames'     => ['request'],
                    'attrs'         => $kafka_timing_jmx_attrs,
                },
                # Request Queue Time Metrics
                {
                    'name'          => 'kafka.network:type=RequestMetrics,name=RequestQueueTimeMs,request=*',
                    'resultAlias'   => 'kafka.network.RequestMetrics.RequestQueueTimeMs',
                    'typeNames'     => ['request'],
                    'attrs'         => $kafka_timing_jmx_attrs,
                },
                # Response Queue Time Metrics
                {
                    'name'          => 'kafka.network:type=RequestMetrics,name=ResponseQueueTimeMs,request=*',
                    'resultAlias'   => 'kafka.network.RequestMetrics.ResponseQueueTimeMs',
                    'typeNames'     => ['request'],
                    'attrs'         => $kafka_timing_jmx_attrs,
                },
                # Response Send Time Metrics
                {
                    'name'          => 'kafka.network:type=RequestMetrics,name=ResponseSendTimeMs,request=*',
                    'resultAlias'   => 'kafka.network.RequestMetrics.ResponseSendTimeMs',
                    'typeNames'     => ['request'],
                    'attrs'         => $kafka_timing_jmx_attrs,
                },
                # Request/Response Total Time Metrics
                {
                    'name'          => 'kafka.network:type=RequestMetrics,name=TotalTimeMs,request=*',
                    'resultAlias'   => 'kafka.network.RequestMetrics.TotalTimeMs',
                    'typeNames'     => ['request'],
                    'attrs'         => $kafka_timing_jmx_attrs,
                },

                # Log Flush Metrics
                {
                    'name'          => 'kafka.log:type=LogFlushStats,name=*',
                    'resultAlias'   => 'kafka.log.Log.LogFlushStats',
                    'typeNames'     => ['name'],
                    'attrs'         => merge($kafka_timing_jmx_attrs, $kafka_rate_jmx_attrs),
                },

                # Per topic-partition Metrics
                {
                    'name'          => 'kafka.log:type=Log,name=LogStartOffset,topic=*,partition=*',
                    'resultAlias'   => 'kafka.log.Log.LogStartOffset',
                    'typeNames'     => ['topic', 'partition'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },
                {
                    'name'          => 'kafka.log:type=Log,name=LogEndOffset,topic=*,partition=*',
                    'resultAlias'   => 'kafka.log.Log.LogEndOffset',
                    'typeNames'     => ['topic', 'partition'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },
                {
                    'name'          => 'kafka.log:type=Log,name=Size,topic=*,partition=*',
                    'resultAlias'   => 'kafka.log.Log.Size',
                    'typeNames'     => ['topic', 'partition'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },


                # Controller Info
                {
                    'name'          => 'kafka.controller:type=KafkaController,name=*',
                    'resultAlias'   => 'kafka.controller.KafkaController',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },
                # Controller Metrics
                {
                    'name'          => 'kafka.controller:type=ControllerStats,name=*',
                    'resultAlias'   => 'kafka.controller.ControllerStats',
                    'typeNames'     => ['name'],
                    'attrs'         => merge($kafka_timing_jmx_attrs, $kafka_rate_jmx_attrs),
                },

                # Per topic-partition UnderReplicated Partition Metrics
                # TODO: fix this metric.  It should work!
                {
                    'name'          => 'kafka.cluster:type=Partition,name=UnderReplicated,topic=*,partition=*',
                    'resultAlias'   => 'kafka.cluster.Partition.UnderReplicated',
                    'typeNames'     => ['topic, partition'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },

                # Per topic-partitions replica lag
                # TODO: fix this metric.  It should work!
                {
                    'name'          => 'kafka.server:type=FetcherLagMetrics,name=ConsumerLag,clientId=*,topic=*,partition=*',
                    'resultAlias'   => 'kafka.server.FetcherLagMetrics.ConsumerLag',
                    'typeNames'     => ['clientId', 'topic, partition'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },
            ],
            default => $objects,
        }
    }
    # Else use the pre 0.8.2 Kafka JMX metric names.
    else {
        $kafka_objects = $objects ? {
            # if $objects was not set, then use this as the
            # default set of Kafka JMX MBean objects to query.
            undef   => [
                {
                    'name'          => '\"kafka.log\":type=\"LogFlushStats\",name=\"LogFlushRateAndTimeMs\"',
                    'resultAlias'   => 'kafka.log.LogFlushStats.LogFlush',
                    'attrs'         => {
                        'Count'             => { 'slope' => 'positive', 'units' => 'calls/second', 'bucketType' => 'g' },
                        'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'calls/second', 'bucketType' => 'g' },
                        'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'calls/second', 'bucketType' => 'g' },
                        'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'calls/second', 'bucketType' => 'g' },
                        'MeanRate'          => { 'slope' => 'both',     'units' => 'calls/second', 'bucketType' => 'g' },
                    },
                },
                {
                    'name'          => '\"kafka.server\":type=\"BrokerTopicMetrics\",name=*',
                    'resultAlias'   => 'kafka.server.BrokerTopicMetrics',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_rate_jmx_attrs,
                },
                {
                      'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"UnderReplicatedPartitions\"',
                      'resultAlias' => 'kafka.server.ReplicaManager.UnderReplicatedPartitions',
                      'attrs'       => {
                          'Value'           => { 'slope' => 'both', 'units' => 'partitions', 'bucketType' => 'g' },
                      },
                },
                {
                      'name'         => '\"kafka.server\":type=\"ReplicaManager\",name=\"PartitionCount\"',
                      'resultAlias'  => 'kafka.server.ReplicaManager.PartitionCount',
                      'attrs'        => {
                          'Value'           => { 'slope' => 'both', 'units' => 'partitions', 'bucketType' => 'g' },
                      },
                },
                {
                      'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"LeaderCount\"',
                      'resultAlias' => 'kafka.server.ReplicaManager.LeaderCount',
                      'attrs'       => {
                          'Value'           => { 'slope' => 'both', 'units' => 'leaders', 'bucketType' => 'g' },
                      },
                },
                {
                      'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"ISRShrinksPerSec\"',
                      'resultAlias' => 'kafka.server.ReplicaManager.ISRShrinks',
                      'attrs'       => {
                          'Count'             => { 'slope' => 'positive', 'units' => 'shrinks',        'bucketType' => 'g' },
                          'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'shrinks/second', 'bucketType' => 'g' },
                          'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'shrinks/second', 'bucketType' => 'g' },
                          'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'shrinks/second', 'bucketType' => 'g' },
                          'MeanRate'          => { 'slope' => 'both',     'units' => 'shrinks/second', 'bucketType' => 'g' },
                      },
                },
                {
                      'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"IsrExpandsPerSec\"',
                      'resultAlias' => 'kafka.server.ReplicaManager.ISRExpands',
                      'attrs'       => {
                          'Count'             => { 'slope' => 'positive', 'units' => 'expands',        'bucketType' => 'g' },
                          'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'expands/second', 'bucketType' => 'g' },
                          'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'expands/second', 'bucketType' => 'g' },
                          'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'expands/second', 'bucketType' => 'g' },
                          'MeanRate'          => { 'slope' => 'both',     'units' => 'expands/second', 'bucketType' => 'g' },
                      }
                },
                {
                    'name'          => '\"kafka.server\":type=\"ReplicaFetcherManager\",name=*',
                    'resultAlias'   => 'kafka.server.ReplicaFetcherManager',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },
                {
                    'name'          => '\"kafka.server\":type=\"ProducerRequestPurgatory\",name=*',
                    'resultAlias'   => 'kafka.server.ProducerRequestPurgatory',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },
                {
                    'name'          => '\"kafka.server\":type=\"FetchRequestPurgatory\",name=*',
                    'resultAlias'   => 'kafka.server.FetchRequestPurgatory',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },
                {
                    'name'          => '\"kafka.network\":type=\"RequestMetrics\",name=\"*-RequestsPerSec\"',
                    'resultAlias'   => 'kafka.network.RequestMetrics',
                    'typeNames'     => ['name'],
                    'attrs'         => {
                        'Count'             => { 'slope' => 'positive', 'units' => 'requests',        'bucketType' => 'g' },
                        'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'requests/second', 'bucketType' => 'g' },
                        'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'requests/second', 'bucketType' => 'g' },
                        'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'requests/second', 'bucketType' => 'g' },
                        'MeanRate'          => { 'slope' => 'both',     'units' => 'requests/second', 'bucketType' => 'g' },
                    },
                },
                {
                    'name'          => '\"kafka.network\":type=\"RequestMetrics\",name=\"*Ms\"',
                    'resultAlias'   => 'kafka.network.RequestMetrics',
                    'typeNames'     => ['name'],
                    'attrs'         => {
                        'Count'             => { 'slope' => 'positive', 'units' => 'ms',     'bucketType' => 'g' },
                        'Mean'              => { 'slope' => 'both',     'units' => 'ms'    , 'bucketType' => 'g' },
                        'StdDev'            => { 'slope' => 'both',     'units' => 'stddev', 'bucketType' => 'g' },
                    },
                },
                {
                    'name'          => '\"kafka.controller\":type=\"KafkaController\",name=*',
                    'resultAlias'   => 'kafka.controller.KafkaController',
                    'typeNames'     => ['name'],
                    'attrs'         => $kafka_value_jmx_attrs,
                },
                {
                    'name'          => '\"kafka.controller\":type=\"ControllerStats\",name=\"LeaderElectionRateAndTimeMs\"',
                    'resultAlias'   => 'kafka.controller.ControllerStats.LeaderElection',
                    'attrs'         => {
                        'Count'             => { 'slope' => 'positive', 'units' => 'calls',        'bucketType' => 'g' },
                        'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'calls/second', 'bucketType' => 'g' },
                        'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'calls/second', 'bucketType' => 'g' },
                        'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'calls/second', 'bucketType' => 'g' },
                        'MeanRate'          => { 'slope' => 'both',     'units' => 'calls/second', 'bucketType' => 'g' },
                    },
                },
                {
                    'name'          => '\"kafka.controller\":type=\"ControllerStats\",name=\"UncleanLeaderElectionsPerSec\"',
                    'resultAlias'   => 'kafka.controller.ControllerStats.UncleanLeaderElection',
                    'attrs'         => {
                        'Count'             => { 'slope' => 'positive', 'units' => 'elections',        'bucketType' => 'g' },
                        'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'elections/second', 'bucketType' => 'g' },
                        'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'elections/second', 'bucketType' => 'g' },
                        'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'elections/second', 'bucketType' => 'g' },
                        'MeanRate'          => { 'slope' => 'both',     'units' => 'elections/second', 'bucketType' => 'g' },
                    },
                },
            ],
            # else use $objects
            default => $objects,
        }
    }

    # query kafka for jmx metrics
    jmxtrans::metrics { "kafka-${::hostname}-${jmx_port}":
        jmx                  => $jmx,
        outfile              => $outfile,
        ganglia              => $ganglia,
        ganglia_group_name   => "${group_prefix}kafka",
        graphite             => $graphite,
        graphite_root_prefix => "${group_prefix}kafka",
        statsd               => $statsd,
        statsd_root_prefix   => "${group_prefix}kafka",
        objects              => $kafka_objects,
    }
}
