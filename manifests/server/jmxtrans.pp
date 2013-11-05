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
# $outfile       - outfile to which Kafka stats will be written.
# $objects       - objects parameter to pass to jmxtrans::metrics.  Only use
#                  this if you need to override the default ones that this
#                  class provides.
#
# == Usage
# class { 'kafka::server::jmxtrans':
#     ganglia => 'ganglia.example.org:8649'
# }
#
class kafka::server::jmxtrans(
    $jmx_port    = $kafka::defaults::jmx_port,
    $ganglia     = undef,
    $graphite    = undef,
    $outfile     = undef,
    $objects     = undef,
) inherits kafka::defaults
{
    $jmx = "${::fqdn}:${jmx_port}"

    # query for metrics from Kafka's JVM
    jmxtrans::metrics::jvm { $jmx:
        outfile              => $outfile,
        ganglia              => $ganglia,
        graphite             => $graphite,
    }


    $kafka_objects = $objects ? {
        # if $objects was not set, then use this as the
        # default set of Kafka JMX MBean objects to query.
        undef   => [
            {
                'name'          => '\"kafka.log\":type=\"LogFlushStats\",name=\"LogFlushRateAndTimeMs\"',
                'resultAlias'   => 'kafka.log.LogFlushStats.LogFlush',
                'attrs'         => {
                    'Count'             => { 'slope' => 'positive', 'units' => 'calls/second' },
                    'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'calls/second' },
                    'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'calls/second' },
                    'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'calls/second' },
                    'MeanRate'          => { 'slope' => 'both',     'units' => 'calls/second' },
                },
            },
            {
                'name'          => '\"kafka.server\":type=\"BrokerTopicMetrics\",name=*',
                'resultAlias'   => 'kafka.server.BrokerTopicMetrics',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Count'             => { 'slope' => 'positive' },
                    'FifteenMinuteRate' => { 'slope' => 'both'     },
                    'FiveMinuteRate'    => { 'slope' => 'both'     },
                    'OneMinuteRate'     => { 'slope' => 'both'     },
                    'MeanRate'          => { 'slope' => 'both'     },
                },
            },
            {
                  'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"UnderReplicatedPartitions\"',
                  'resultAlias' => 'kafka.server.ReplicaManager.UnderReplicatedPartitions',
                  'attrs'       => {
                      'Value'           => { 'slope' => 'both', 'units' => 'partitions' },
                  },
            },
            {
                  'name'         => '\"kafka.server\":type=\"ReplicaManager\",name=\"PartitionCount\"',
                  'resultAlias'  => 'kafka.server.ReplicaManager.PartitionCount',
                  'attrs'        => {
                      'Value'           => { 'slope' => 'both', 'units' => 'partitions' },
                  },
            },
            {
                  'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"LeaderCount\"',
                  'resultAlias' => 'kafka.server.ReplicaManager.LeaderCount',
                  'attrs'       => {
                      'Value'           => { 'slope' => 'both', 'units' => 'leaders' },
                  },
            },
            {
                  'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"ISRShrinksPerSec\"',
                  'resultAlias' => 'kafka.server.ReplicaManager.ISRShrinks',
                  'attrs'       => {
                      'Count'             => { 'slope' => 'positive', 'units' => 'shrinks'        },
                      'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'shrinks/second' },
                      'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'shrinks/second' },
                      'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'shrinks/second' },
                      'MeanRate'          => { 'slope' => 'both',     'units' => 'shrinks/second' },
                  },
            },
            {
                  'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"IsrExpandsPerSec\"',
                  'resultAlias' => 'kafka.server.ReplicaManager.IsrExpands',
                  'attrs'       => {
                      'Count'             => { 'slope' => 'positive', 'units' => 'expands'        },
                      'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'expands/second' },
                      'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'expands/second' },
                      'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'expands/second' },
                      'MeanRate'          => { 'slope' => 'both',     'units' => 'expands/second' },
                  }
            },
            {
                'name'          => '\"kafka.server\":type=\"ReplicaFetcherManager\",name=*',
                'resultAlias'   => 'kafka.server.ReplicaFetcherManager',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Value'             => { 'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.server\":type=\"ProducerRequestPurgatory\",name=*',
                'resultAlias'   => 'kafka.server.ProducerRequestPurgatory',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Value'             => { 'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.server\":type=\"FetchRequestPurgatory\",name=*',
                'resultAlias'   => 'kafka.server.ProducerRequestPurgatory',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Value'             => { 'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.network\":type=\"RequestMetrics\",name=\"*-RequestsPerSec\"',
                'resultAlias'   => 'kafka.network.RequestMetrics',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Count'             => { 'slope' => 'positive', 'units' => 'requests'        },
                    'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'requests/second' },
                    'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'requests/second' },
                    'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'requests/second' },
                    'MeanRate'          => { 'slope' => 'both',     'units' => 'requests/second' },
                },
            },
            {
                'name'          => '\"kafka.controller\":type=\"KafkaController\",name=*',
                'resultAlias'   => 'kafka.controller.KafkaController',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Value'             => { 'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.controller\":type=\"ControllerStats\",name=\"LeaderElectionRateAndTimeMs\"',
                'resultAlias'   => 'kafka.controller.ControllerStats.LeaderElection',
                'attrs'         => {
                    'Count'             => { 'slope' => 'positive', 'units' => 'calls'        },
                    'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'calls/second' },
                    'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'calls/second' },
                    'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'calls/second' },
                    'MeanRate'          => { 'slope' => 'both',     'units' => 'calls/second' },
                },
            },
            {
                'name'          => '\"kafka.controller\":type=\"ControllerStats\",name=\"UncleanLeaderElectionsPerSec\"',
                'resultAlias'   => 'kafka.controller.ControllerStats.UncleanLeaderElection',
                'attrs'         => {
                    'Count'             => { 'slope' => 'positive', 'units' => 'elections'        },
                    'FifteenMinuteRate' => { 'slope' => 'both',     'units' => 'elections/second' },
                    'FiveMinuteRate'    => { 'slope' => 'both',     'units' => 'elections/second' },
                    'OneMinuteRate'     => { 'slope' => 'both',     'units' => 'elections/second' },
                    'MeanRate'          => { 'slope' => 'both',     'units' => 'elections/second' },
                },
            },
        ],
        # else use $objects
        default => $objects,
    }

    # query kafka for jmx metrics
    jmxtrans::metrics { "kafka-${::hostname}-${jmx_port}":
        jmx                  => $jmx,
        outfile              => $outfile,
        ganglia              => $ganglia,
        ganglia_group_name   => 'kafka',
        graphite             => $graphite,
        graphite_root_prefix => 'kafka',
        objects              => $kafka_objects,
    }
}