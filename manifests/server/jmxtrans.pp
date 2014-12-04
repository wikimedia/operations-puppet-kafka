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
                'attrs'         => {
                    'Count'             => { 'slope' => 'positive', 'bucketType' => 'g' },
                    'FifteenMinuteRate' => { 'slope' => 'both',     'bucketType' => 'g' },
                    'FiveMinuteRate'    => { 'slope' => 'both',     'bucketType' => 'g' },
                    'OneMinuteRate'     => { 'slope' => 'both',     'bucketType' => 'g' },
                    'MeanRate'          => { 'slope' => 'both',     'bucketType' => 'g' },
                },
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
                'attrs'         => {
                    'Value'             => { 'slope' => 'both', 'bucketType' => 'g' },
                },
            },
            {
                'name'          => '\"kafka.server\":type=\"ProducerRequestPurgatory\",name=*',
                'resultAlias'   => 'kafka.server.ProducerRequestPurgatory',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Value'             => { 'slope' => 'both', 'bucketType' => 'g' },
                },
            },
            {
                'name'          => '\"kafka.server\":type=\"FetchRequestPurgatory\",name=*',
                'resultAlias'   => 'kafka.server.FetchRequestPurgatory',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Value'             => { 'slope' => 'both', 'bucketType' => 'g' },
                },
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
                'attrs'         => {
                    'Value'             => { 'slope' => 'both', 'bucketType' => 'g' },
                },
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
