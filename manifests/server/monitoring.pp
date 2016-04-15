# == Class kafka::server::monitoring
# Wikimedia Foundation specific monitoring class.
# Only include this if you are using this kafka puppet module
# with the Wikimedia puppet repository from
# github.com/wikimedia/operations-puppet.
#
# == Parameters
# $jmx_port            - Default: 9999
# $nagios_servicegroup - Nagios Service group to use for alerts.  Default: undef
# $group_prefix        - $group_prefix passed to kafka::server::jmxtrans.
#                        This will be used for graphite based alerts.
#                        Default: undef
#
class kafka::server::monitoring(
    $jmx_port            = 9999,
    $nagios_servicegroup = undef,
    $group_prefix        = undef,
) {
    # Generate icinga alert if Kafka Server is not running.
    nrpe::monitor_service { 'kafka':
        description  => 'Kafka Broker Server',
        nrpe_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -C java -a "kafka.Kafka /etc/kafka/server.properties"',
        require      => Class['::kafka::server'],
        critical     => true,
    }

    if !defined(Nrpe::Monitor_service['jmxtrans']) {
        # Generate icinga alert if this jmxtrans instance is not running.
        nrpe::monitor_service { 'jmxtrans':
            description  => 'jmxtrans',
            nrpe_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -C java --ereg-argument-array "-jar.+jmxtrans-all.jar"',
            require      => Service['jmxtrans'],
        }
    }

    # jmxtrans statsd writer emits fqdns in keys
    # by substiting '.' with '_' and suffixing the jmx port.
    $graphite_broker_key = regsubst("${::fqdn}_${jmx_port}", '\.', '_', 'G')

    # Alert if any Kafka has under replicated partitions.
    # If it does, this means a broker replica is falling behind
    # and will be removed from the ISR.
    monitoring::graphite_threshold { 'kafka-broker-UnderReplicatedPartitions':
        description => 'Kafka Broker Under Replicated Partitions',
        metric      => "${group_prefix}kafka.${graphite_broker_key}.kafka.server.ReplicaManager.UnderReplicatedPartitions.Value",
        warning     => '1',
        critical    => '10',
        # Alert if any undereplicated for more than 50%
        # of the time in the last 30 minutes.
        from        => '30min',
        percentage  => 50,
        require     => Class['::kafka::server::jmxtrans'],
        group       => $nagios_servicegroup,
    }

    # Alert if any Kafka Broker replica lag is too high
    monitoring::graphite_threshold { 'kafka-broker-Replica-MaxLag':
        description => 'Kafka Broker Replica Max Lag',
        metric      => "${group_prefix}kafka.${graphite_broker_key}.kafka.server.ReplicaFetcherManager.MaxLag.Value",
        # As of 2014-02 replag could catch up at more than 1000 msgs / sec,
        # (probably more like 2 or 3 K / second). At that rate, 1M messages
        # behind should catch back up in at least 30 minutes.
        # TODO: Parameterize this for different volumes?
        warning     => '1000000',
        critical    => '5000000',
        # Alert if large replica lag for more than 50%
        # of the time in the last 30 minutes.
        from        => '30min',
        percentage  => 50,
        require     => Class['::kafka::server::jmxtrans'],
        group       => $nagios_servicegroup,
        # This check is too noisy because of
        # https://phabricator.wikimedia.org/T121407.
        # TODO: Re-enable after 0.9 upgrade.
        ensure      => 'absent',
    }

    # monitor disk statistics
    if $::standard::has_ganglia {
        ganglia::plugin::python { 'diskstat': }
    }
}
