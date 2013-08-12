**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [Kafka Puppet Module](#kafka-puppet-module)
- [Requirements](#requirements)
- [Usage](#usage)
    - [Kafka (Clients)](#kafka)
    - [Kafka Broker Servers](#kafka-broker-server)
    - [Custom Zookeeper Chroot](#custom-zookeeper-chroot)


# Kafka Puppet Module

A Puppet module for installing and managing [Apache Kafka](http://kafka.apache.org/) brokers.

This module is currently being maintained by The Wikimedia Foundation in Gerrit at
[operations/puppet/kafka](https://gerrit.wikimedia.org/r/#/admin/projects/operations/puppet/kafka)
and mirrored here on [GitHub](https://github.com/wikimedia/puppet-kafka).
It was originally developed for 0.7.2 at https://github.com/wikimedia/puppet-kafka-0.7.2.


# Requirements
- Java
- An Kafka 0.8 package.
  0.8 is not yet released (as of 2013-06-13), but you can build a .deb package using
  [operations/debs/kafka debian branch](https://github.com/wikimedia/operations-debs-kafka/tree/debian)
- A running zookeeper cluster.  You can set one up using WMF's
  [puppet-zookeeper module](https://github.com/wikimedia/puppet-zookeeper).

# Usage

## Kafka (Clients)

```puppet
# Install the kafka package and configure kafka.
class { 'kafka':
    hosts => {
        'kafka-node01.domain.org' => { 'id' => 1, 'port' => 12345 },
        'kafka-node02.domain.org' => { 'id' => 2 },
    },
    zookeeper_hosts => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
}
```

The ```hosts``` parameter is a Hash keyed by ```$::fqdn```.  Each value is another Hash
that contains config settings for that kafka host.  ```id``` is required and must
be unique for each Kafka Broker Server host.  ```port``` is optional, and defaults
to 9092.

```zookeeper_hosts``` is an array of Zookeeper host:port pairs.

## Kafka Broker Server

```puppet
# kafka::server requires the main kafka class.
class { 'kafka':
    hosts => {
        'kafka-node01.domain.org' => { 'id' => 1, 'port' => 12345 },
        'kafka-node02.domain.org' => { 'id' => 2 },
    },
    zookeeper_hosts => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
}

# Include Kafka Broker Server.
class { 'kafka::server': }
```

Each Kafka Broker Server's ```broker_id``` and ```port``` properties in server.properties
will be set based by looking up the node's ```$::fqdn``` in the hosts 
Hash passed into the ```kafka``` base class.

## Custom Zookeeper Chroot

If Kafka will share a Zookeeper cluster with other users, you might want to
create a znode in zookeeper in which to store your Kafka cluster's data.
You can set the ```zookeeper_chroot``` parameter on the ```kafka``` class to do this.

First, you'll need to create the znode manually yourself.  You can use
```zkCli.sh``` that ships with Zookeeper, or you can use the kafka built in
```zookeeper-shell```:

```bash
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
(```data```) is arbitrary.  I used 'kafka' here.

Then:
```puppet
class { 'kafka':
    hosts => {
        'kafka-node01.domain.org' => { 'id' => 1, 'port' => 12345 },
        'kafka-node02.domain.org' => { 'id' => 2 },
    },
    zookeeper_hosts => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
    # set zookeeper_chroot on the kafka class.
    zookeeper_chroot => '/my_kafka',
}
```

