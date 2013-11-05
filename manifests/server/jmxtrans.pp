# == Class kafka::server::jmxtrans
# Sets up a jmxtrans instance for a Kafka Server Broker.
# this requires the jmxtrans puppet module found at
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
        undef   => [
            {
                'name'          => '\"kafka.log\":type=\"LogFlushStats\",name=\"LogFlushRateAndTimeMs\"',
                "resultAlias"   => 'kafka.log.LogFlushStats.LogFlushRateAndTimeMs',
                'attrs'         => {
                    'Count' => { 'units' => 'flushes',   'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.server\":type=\"BrokerTopicMetrics\",name=*',
                "resultAlias"   => 'kafka.server.BrokerTopicMetrics',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Count' => { 'slope' => 'both' },
                },
            },
            {
                  'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"UnderReplicatedPartitions\"',
                  "resultAlias" => 'kafka.server.ReplicaManager.UnderReplicatedPartitions',
                  'attrs'       => {
                      'Value' => { 'units' => 'partitions', 'slope' => 'both' },
                  },
            },
            {
                  'name'         => '\"kafka.server\":type=\"ReplicaManager\",name=\"PartitionCount\"',
                  "resultAlias"   => 'kafka.server.ReplicaManager.PartitionCount',
                  'attrs'        => {
                      'Value' => { 'units' => 'partitions', 'slope' => 'both' },
                  },
            },
            {
                  'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"LeaderCount\"',
                  "resultAlias"   => 'kafka.server.ReplicaManager.LeaderCount',
                  'attrs'       => {
                      'Value' => { 'units' => 'leaders', 'slope' => 'both' },
                  },
            },
            {
                  'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"ISRShrinksPerSec\"',
                  "resultAlias"   => 'kafka.server.ReplicaManager.ISRShrinksPerSec',
                  'attrs'       => {
                      'Count' => { 'units' => 'shrinks', 'slope' => 'both' },
                  },
            },
            {
                  'name'        => '\"kafka.server\":type=\"ReplicaManager\",name=\"IsrExpandsPerSec\"',
                  "resultAlias"   => 'kafka.server.ReplicaManager.IsrExpandsPerSec',
                  'attrs'       => {
                      'Count' => { 'units' => 'expands', 'slope' => 'both' },
                  },
            },
            {
                'name'          => '\"kafka.server\":type=\"ReplicaFetcherManager\",name=\"Replica-MaxLag\"',
                "resultAlias"   => 'kafka.server.ReplicaFetcherManager.Replica-MaxLag',
                'attrs'         => {
                    'Value' => { 'units' => 'messages',   'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.server\":type=\"ProducerRequestPurgatory\",name=\"PurgatorySize\"',
                "resultAlias"   => 'kafka.server.ProducerRequestPurgatory.PurgatorySize',
                'attrs'         => {
                    'Value' => { 'units' => 'messages', 'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.server\":type=\"FetchRequestPurgatory\",name=\"PurgatorySize\"',
                "resultAlias"   => 'kafka.server.FetchRequestPurgatory.PurgatorySize',
                'attrs'         => {
                    'Value' => { 'units' => 'messages', 'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.network\":type=\"RequestMetrics\",name=*',
                "resultAlias"   => 'kafka.network.RequestMetrics',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Count' => { 'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.controller\":type=\"KafkaController\",name=*',
                "resultAlias"   => 'kafka.controller.KafkaController',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Value' => { 'slope' => 'both' },
                },
            },
            {
                'name'          => '\"kafka.controller\":type=\"ControllerStats\",name=*',
                "resultAlias"   => 'kafka.controller.ControllerStats',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Count' => { 'slope' => 'both' },
                },
            },
        ],
        default => $query_objects,
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