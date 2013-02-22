# Kafka Puppet Module

A Puppet module for installing and managing [Apache Kafka](http://kafka.apache.org/) brokers.
This module is maintained at https://github.com/wikimedia/puppet-kafka.

This module is currently being maintained by The Wikimedia Foundation at
[operations/puppet/kafka](https://gerrit.wikimedia.org/r/gitweb?p=operations%2Fpuppet%2Fkafka.git;a=summary)
and mirrored on [GitHub](https://github.com/wikimedia/operations-puppet-kafka).
It was originally developed for 0.7.2 at https://github.com/wikimedia/puppet-kafka.


## Requirements:
- Java
- An Kafka 0.8 package.
  0.8 is not yet released (as of 2013-06-13), but you can build a .deb package using
  [operations/debs/kafka debian branch](https://github.com/wikimedia/operations-debs-kafka/tree/debian)

## Usage:

### Just the package and client configs:
```puppet
# install the kafka package and configure kafka.
class { 'kafka':
  hosts => {
    'kafka-node01.domain.org' => { 'id' => 1, 'port' => 12345 },
    'kafka-node02.domain.org' => { 'id' => 2 },
  },
  zookeeper_hosts => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
}

The ```hosts``` parameter is a Hash keyed by ```$::fqdn```.  Each value is another Hash
that contains config settings for that kafka host.  ```id``` is required and must
be unique for each Kafka Broker Server host.  ```port``` is optional, and defaults
to 9092.

```zookeeper_hosts``` is an array of Zookeeper host:port pairs.
```

### Start a kafka broker server
```puppet
# kafka::server requires base kafka class
class { 'kafka':
  hosts => {
    'kafka-node01.domain.org' => { 'id' => 1, 'port' => 12345 },
    'kafka-node02.domain.org' => { 'id' => 2 },
  },
  zookeeper_hosts => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
}
class { 'kafka::server': }
```

Each Kafka Broker Server's ```broker_id``` and ```port``` properties in server.properties
will be set based by looking up the node's ```$::fqdn``` in the hosts 
Hash passed into the ```kafka``` base class.
