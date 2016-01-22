**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [Kafka Puppet Module](#kafka-puppet-module)
- [Requirements](#requirements)
- [Usage](#usage)
    - [Kafka (Clients)](#kafka)
    - [Kafka Broker Servers](#kafka-broker-server)
    - [Custom Zookeeper Chroot](#custom-zookeeper-chroot)
    - [Kafka Mirror](#kafka-mirror)

# Kafka Puppet Module

A Puppet module for installing and managing [Apache Kafka](http://kafka.apache.org/) brokers.

This module is currently being maintained by The Wikimedia Foundation in Gerrit at
[operations/puppet/kafka](https://gerrit.wikimedia.org/r/#/admin/projects/operations/puppet/kafka)
and mirrored here on [GitHub](https://github.com/wikimedia/puppet-kafka).
It was originally developed for 0.7.2 at https://github.com/wikimedia/puppet-kafka-0.7.2.


# Requirements
- Java
- An Kafka 0.8 package.
  You can build a .deb package using the
  [operations/debs/kafka debian branch](https://github.com/wikimedia/operations-debs-kafka/tree/debian),
  or just install using this [prebuilt .deb](http://apt.wikimedia.org/wikimedia/pool/main/k/kafka/)
- A running zookeeper cluster.  You can set one up using WMF's
  [puppet-zookeeper module](https://github.com/wikimedia/puppet-zookeeper).

# Usage

## Kafka (Clients)

```puppet
# Install the kafka libraries and client packages.
class { 'kafka': }
```

This will install the kafka-common and kafka-cli which includes
/usr/bin/kafka, useful for running client (console-consumer,
console-producer, etc.) commands.

## Kafka Broker Server

```puppet
# Include Kafka Broker Server.
class { 'kafka::server':
    log_dirs         => ['/var/spool/kafka/a', '/var/spool/kafka/b'],
    brokers          => {
        'kafka-node01.example.com' => { 'id' => 1, 'port' => 12345 },
        'kafka-node02.example.com' => { 'id' => 2 },
    },
    zookeeper_hosts  => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
    zookeeper_chroot => '/kafka/cluster_name',
}
```

`log_dirs` defaults to a single `['/var/spool/kafka]`, but you may
specify multiple Kafka log data directories here.  This is useful for spreading
your topic partitions across multiple disks.

The `brokers` parameter is a Hash keyed by `$::fqdn`.  Each value is another Hash
that contains config settings for that kafka host.  `id` is required and must
be unique for each Kafka Broker Server host.  `port` is optional, and defaults
to 9092.

Each Kafka Broker Server's `broker_id` and `port` properties in server.properties
will be set based by looking up the node's `$::fqdn` in the hosts
Hash passed into the `kafka` base class.

`zookeeper_hosts` is an array of Zookeeper host:port pairs.
`zookeeper_chroot` is optional, and allows you to specify a Znode under
which Kafka will store its metadata in Zookeeper.  This is useful if you
want to use a single Zookeeper cluster to manage multiple Kafka clusters.


## Kafka Mirror

Kafka MirrorMaker will allow you to mirror data from multiple Kafka clusters
into another.  This is useful for cross DC replication and for aggregation.

```puppet
# Mirror the 'main' and 'secondary' Kafka clusters
# to the 'aggregate' Kafka cluster.
kafka::mirror::consumer { 'main':
    mirror_name   => 'aggregate',
    zookeeper_url => 'zk:2181/kafka/main',
}
kafka::mirror::consumer { 'secondary':
    mirror_name   => 'aggregate',
    zookeeper_url => 'zk:2181/kafka/secondary',
}
kafka::mirror { 'aggregate':
    destination_brokers => ['ka01:9092','ka02:9092'],
    whitelist           => 'these_topics_only.*',
}
```
Note that the kafka-mirror service does not subscribe to its config files.  If
you make changes, you will have to restart the service manually.

## jmxtrans monitoring

`kafka::server::jmxtrans` and `kafka::mirror::jmxtrans`  configure
useful jmxtrans JSON config objects that can be used to tell jmxtrans to send
to any output writer (Ganglia, Graphite, etc.).  To you use this, you will need
the [puppet-jmxtrans](https://github.com/wikimedia/puppet-jmxtrans) module.

```puppet
# Include this class on each of your Kafka Broker Servers.
class { '::kafka::server::jmxtrans':
    ganglia => 'ganglia.example.com:8649',
}
```
This will install jmxtrans and render JSON config files for sending
JVM and Kafka Broker stats to Ganglia.
See [kafka-jmxtrans.json.md](kafka-jmxtrans.json.md) for a fully
rendered jmxtrans Kafka Broker JSON config file.

```
# Declare this define on hosts where you run Kafka MirrorMaker.
kafka::mirror::jmxtrans { 'aggregate':
    statsd => 'statsd.example.org:8125'
}

```
This will install jmxtrans and render JSON config files for sending JVM and
Kafka MirrorMaker (consumers and producer) stats to statsd.
