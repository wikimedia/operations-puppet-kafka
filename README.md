**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [Kafka Puppet Module](#kafka-puppet-module)
- [Requirements](#requirements)
- [Usage](#usage)
    - [Kafka (Clients)](#kafka)
    - [Kafka Broker Servers](#kafka-broker-server)

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
