# == Define kafka::mirror::monitoring
# Wikimedia Foundation specific monitoring class.
# Only include this if you are using this kafka puppet module
# with the Wikimedia puppet repository from
# github.com/wikimedia/operations-puppet.
#
# == Parameters
# $title               - Should be the same as the kafka::mirror instance
#                        you want.
#                        to monitor.
# $group_prefix        - $group_prefix passed to kafka::mirror::jmxtrans.
#                        This will be used for graphite based alerts.
#                        Default: undef
#
define kafka::mirror::monitoring(
    $group_prefix        = undef,
) {
    # Generate icinga alert if Kafka Server is not running.
    nrpe::monitor_service { "kafka-mirror-${title}":
        description  => "Kafka MirrorMaker ${title}",
        nrpe_command => "/usr/lib/nagios/plugins/check_procs -c 1:1 -C java  --ereg-argument-array 'kafka.tools.MirrorMaker.+/etc/kafka/mirror/${title}/producer\.properties'",
        require      => Kafka::Mirror[$title],
    }

    if !defined(Nrpe::Monitor_service['jmxtrans']) {
        # Generate icinga alert if this jmxtrans instance is not running.
        nrpe::monitor_service { 'jmxtrans':
            description  => 'jmxtrans',
            nrpe_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -C java --ereg-argument-array "-jar.+jmxtrans-all.jar"',
            require      => Service['jmxtrans'],
        }
    }
}
