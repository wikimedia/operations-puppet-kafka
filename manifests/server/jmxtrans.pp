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
) inherits kafka::defaults
{
    $jmx = "${::fqdn}:${jmx_port}"

    # query for metrics from Kafka's JVM
    jmxtrans::metrics::jvm { $jmx:
        outfile              => $outfile,
        ganglia              => $ganglia,
        graphite             => $graphite,
    }

    # query kafka for jmx metrics
    jmxtrans::metrics { "kafka-${::hostname}-${jmx_port}":
        jmx                  => $jmx,
        outfile              => $outfile,
        ganglia              => $ganglia,
        ganglia_group_name   => 'kafka',
        graphite             => $graphite,
        graphite_root_prefix => 'kafka',
        objects              => [
            {
                'name'          => 'kafka.log:type=LogFlushStats,name=LogFlushRateAndTimeMs',
                'attrs'         => {
                    'Count' => { 'units' => 'flushes',   'slope' => 'both' },
                },
            },
            {
                'name'          => 'kafka.server:type=kafka.BrokerTopicMetrics,name=*',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Count' => { 'slope' => 'both' },
                },
            },
            {
                  'name'        => 'kafka.server:type=ReplicaManager,name=UnderReplicatedPartitions',
                  'attrs'       => {
                      'Value' => { 'units' => 'partitions', 'slope' => 'both' },
                  },
            },
            {
                  'name'         => 'kafka.server:type=ReplicaManager,name=PartitionCount',
                  'attrs'        => {
                      'Value' => { 'units' => 'partitions', 'slope' => 'both' },
                  },
            },
            {
                  'name'        => 'kafka.server:type=ReplicaManager,name=LeaderCount',
                  'attrs'       => {
                      'Value' => { 'units' => 'leaders', 'slope' => 'both' },
                  },
            },
            {
                  'name'        => 'kafka.server:type=ReplicaManager,name=ISRShrinksPerSec',
                  'attrs'       => {
                      'Count' => { 'units' => 'shrinks', 'slope' => 'both' },
                  },
            },
            {
                  'name'        => 'kafka.server:type=ReplicaManager,name=IsrExpandsPerSec',
                  'attrs'       => {
                      'Count' => { 'units' => 'expands', 'slope' => 'both' },
                  },
            },
            {
                'name'          => 'kafka.server:type=ReplicaFetcherManager,name=Replica-MaxLag',
                'attrs'         => {
                    'Value' => { 'units' => 'messages',   'slope' => 'both' },
                },
            },
            {
                'name'          => 'kafka.server:type=ProducerRequestPurgatory,name=PurgatorySize',
                'attrs'         => {
                    'Value' => { 'units' => 'messages', 'slope' => 'both' },
                },
            },
            {
                'name'          => 'kafka.server:type=FetchRequestPurgatory,name=PurgatorySize',
                'attrs'         => {
                    'Value' => { 'units' => 'messages', 'slope' => 'both' },
                },
            },
            {
                'name'          => 'kafka.network:type=RequestMetrics,name=*',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Count' => { 'slope' => 'both' },
                },
            },
            {
                'name'          => 'kafka.controller:type=KafkaController,name=*',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Value' => { 'slope' => 'both' },
                },
            },
            {
                'name'          => 'kafka.controller:type=ControllerStats,name=*',
                'typeNames'     => ['name'],
                'attrs'         => {
                    'Count' => { 'slope' => 'both' },
                },
            },
        ]
    }
}