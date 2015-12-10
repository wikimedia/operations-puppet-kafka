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
See below for information on how to create this Znode in Zookeeper.



## Custom Zookeeper Chroot

If Kafka will share a Zookeeper cluster with other users, you might want to
create a Znode in zookeeper in which to store your Kafka cluster's data.
You can set the `zookeeper_chroot` parameter on the `kafka` class to do this.

First, you'll need to create the znode manually yourself.  You can use
`zkCli.sh` that ships with Zookeeper, or you can use the kafka built in
`zookeeper-shell`:


```
$ kafka zookeeper-shell <zookeeper_host>:2182
Connecting to kraken-zookeeper
Welcome to ZooKeeper!
JLine support is enabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: kraken-zookeeper(CONNECTED) 0] create /my_kafka kafka
Created /my_kafka
```

You can use whatever chroot znode path you like.  The second argument
(`data`) is arbitrary.  I used 'kafka' here.

Then:
```puppet
class { 'kafka::server':
    brokers => {
        'kafka-node01.example.com' => { 'id' => 1, 'port' => 12345 },
        'kafka-node02.example.com' => { 'id' => 2 },
    },
    zookeeper_hosts => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
    # set zookeeper_chroot on the kafka class.
    zookeeper_chroot => '/kafka/clusterA',
}
```

## Kafka Mirror

Kafka MirrorMaker is usually used for inter data center Kafka cluster replication
and aggregation.  You can consume from any number of source Kafka clusters, and
produce to a single destination Kafka cluster.

```puppet
# Configure kafka-mirror to produce to Kafka Brokers which are
# part of our kafka aggregator cluster.
class { 'kafka::mirror':
    destination_brokers => {
        'kafka-aggregator01.example.com' => { 'id' => 11 },
        'kafka-aggregator02.example.com' => { 'id' => 12 },
    },
    topic_whitelist => 'webrequest.*',
}

# Configure kafka-mirror to consume from both clusterA and clusterB
kafka::mirror::consumer { 'clusterA':
    zookeeper_hosts  => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
    zookeeper_chroot => ['/kafka/clusterA'],
}
kafka::mirror::consumer { 'clusterB':
    zookeeper_hosts  => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
    zookeeper_chroot => ['/kafka/clusterB'],
}
```

## jmxtrans monitoring

This module contains a class called `kafka::server::jmxtrans`.  It contains
a useful jmxtrans JSON config object that can be used to tell jmxtrans to send
to any output writer (Ganglia, Graphite, etc.).  To you use this, you will need
the [puppet-jmxtrans](https://github.com/wikimedia/puppet-jmxtrans) module.

```puppet
# Include this class on each of your Kafka Broker Servers.
class { '::kafka::server::jmxtrans':
    ganglia => 'ganglia.example.com:8649',
}
```

This will install jmxtrans and start render JSON config files for sending
JVM and Kafka Broker stats to Ganglia.
See [kafka-jmxtrans.json.md](kafka-jmxtrans.json.md) for a fully
rendered jmxtrans Kafka JSON config file.
