This jmxtrans JSON was generated using the [puppet-jmxtrans](https://github.com/wikimedia/puppet-jmxtrans)
puppet module and the ```kafka::server::jmxtrans``` class from this module.  If
you don't want to use the ```puppet-jmxtrans``` module, you may use this as a
starting point for your own jmxtrans JSON config file.

As is, this sends JMX metrics to both Ganglia and to a outfile.  You may add
your own ```outputWriters``` as needed.

```json
{ "servers":
  [ { "host": "broker1.exapmle.org"
    , "port": 9999
    , "queries":
      [
        { "obj": "\"kafka.log\":type=\"LogFlushStats\",name=\"LogFlushRateAndTimeMs\""
        , "attr": [ "Count" ]
        , "resultAlias": "kafka.log.LogFlushStats.LogFlush"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "POSITIVE"
              , "units": "calls/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.log\":type=\"LogFlushStats\",name=\"LogFlushRateAndTimeMs\""
        , "attr": [ "FifteenMinuteRate" ]
        , "resultAlias": "kafka.log.LogFlushStats.LogFlush"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "calls/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.log\":type=\"LogFlushStats\",name=\"LogFlushRateAndTimeMs\""
        , "attr": [ "FiveMinuteRate" ]
        , "resultAlias": "kafka.log.LogFlushStats.LogFlush"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "calls/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.log\":type=\"LogFlushStats\",name=\"LogFlushRateAndTimeMs\""
        , "attr": [ "MeanRate" ]
        , "resultAlias": "kafka.log.LogFlushStats.LogFlush"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "calls/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.log\":type=\"LogFlushStats\",name=\"LogFlushRateAndTimeMs\""
        , "attr": [ "OneMinuteRate" ]
        , "resultAlias": "kafka.log.LogFlushStats.LogFlush"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "calls/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"BrokerTopicMetrics\",name=*"
        , "attr": [ "Count" ]
        , "resultAlias": "kafka.server.BrokerTopicMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "POSITIVE"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"BrokerTopicMetrics\",name=*"
        , "attr": [ "FifteenMinuteRate" ]
        , "resultAlias": "kafka.server.BrokerTopicMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"BrokerTopicMetrics\",name=*"
        , "attr": [ "FiveMinuteRate" ]
        , "resultAlias": "kafka.server.BrokerTopicMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"BrokerTopicMetrics\",name=*"
        , "attr": [ "MeanRate" ]
        , "resultAlias": "kafka.server.BrokerTopicMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"BrokerTopicMetrics\",name=*"
        , "attr": [ "OneMinuteRate" ]
        , "resultAlias": "kafka.server.BrokerTopicMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"UnderReplicatedPartitions\""
        , "attr": [ "Value" ]
        , "resultAlias": "kafka.server.ReplicaManager.UnderReplicatedPartitions"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "partitions"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"PartitionCount\""
        , "attr": [ "Value" ]
        , "resultAlias": "kafka.server.ReplicaManager.PartitionCount"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "partitions"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"LeaderCount\""
        , "attr": [ "Value" ]
        , "resultAlias": "kafka.server.ReplicaManager.LeaderCount"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "leaders"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"ISRShrinksPerSec\""
        , "attr": [ "Count" ]
        , "resultAlias": "kafka.server.ReplicaManager.ISRShrinks"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "POSITIVE"
              , "units": "shrinks"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"ISRShrinksPerSec\""
        , "attr": [ "FifteenMinuteRate" ]
        , "resultAlias": "kafka.server.ReplicaManager.ISRShrinks"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "shrinks/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"ISRShrinksPerSec\""
        , "attr": [ "FiveMinuteRate" ]
        , "resultAlias": "kafka.server.ReplicaManager.ISRShrinks"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "shrinks/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"ISRShrinksPerSec\""
        , "attr": [ "MeanRate" ]
        , "resultAlias": "kafka.server.ReplicaManager.ISRShrinks"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "shrinks/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"ISRShrinksPerSec\""
        , "attr": [ "OneMinuteRate" ]
        , "resultAlias": "kafka.server.ReplicaManager.ISRShrinks"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "shrinks/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"IsrExpandsPerSec\""
        , "attr": [ "Count" ]
        , "resultAlias": "kafka.server.ReplicaManager.IsrExpands"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "POSITIVE"
              , "units": "expands"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"IsrExpandsPerSec\""
        , "attr": [ "FifteenMinuteRate" ]
        , "resultAlias": "kafka.server.ReplicaManager.IsrExpands"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "expands/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"IsrExpandsPerSec\""
        , "attr": [ "FiveMinuteRate" ]
        , "resultAlias": "kafka.server.ReplicaManager.IsrExpands"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "expands/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"IsrExpandsPerSec\""
        , "attr": [ "MeanRate" ]
        , "resultAlias": "kafka.server.ReplicaManager.IsrExpands"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "expands/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaManager\",name=\"IsrExpandsPerSec\""
        , "attr": [ "OneMinuteRate" ]
        , "resultAlias": "kafka.server.ReplicaManager.IsrExpands"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "expands/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ReplicaFetcherManager\",name=*"
        , "attr": [ "Value" ]
        , "resultAlias": "kafka.server.ReplicaFetcherManager"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"ProducerRequestPurgatory\",name=*"
        , "attr": [ "Value" ]
        , "resultAlias": "kafka.server.ProducerRequestPurgatory"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.server\":type=\"FetchRequestPurgatory\",name=*"
        , "attr": [ "Value" ]
        , "resultAlias": "kafka.server.ProducerRequestPurgatory"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.network\":type=\"RequestMetrics\",name=\"*-RequestsPerSec\""
        , "attr": [ "Count" ]
        , "resultAlias": "kafka.network.RequestMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "POSITIVE"
              , "units": "requests"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.network\":type=\"RequestMetrics\",name=\"*-RequestsPerSec\""
        , "attr": [ "FifteenMinuteRate" ]
        , "resultAlias": "kafka.network.RequestMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "units": "requests/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.network\":type=\"RequestMetrics\",name=\"*-RequestsPerSec\""
        , "attr": [ "FiveMinuteRate" ]
        , "resultAlias": "kafka.network.RequestMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "units": "requests/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.network\":type=\"RequestMetrics\",name=\"*-RequestsPerSec\""
        , "attr": [ "MeanRate" ]
        , "resultAlias": "kafka.network.RequestMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "units": "requests/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.network\":type=\"RequestMetrics\",name=\"*-RequestsPerSec\""
        , "attr": [ "OneMinuteRate" ]
        , "resultAlias": "kafka.network.RequestMetrics"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "units": "requests/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"KafkaController\",name=*"
        , "attr": [ "Value" ]
        , "resultAlias": "kafka.controller.KafkaController"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              , "typeNames": ["name"]
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "typeNames": ["name"]
              , "slope": "BOTH"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"LeaderElectionRateAndTimeMs\""
        , "attr": [ "Count" ]
        , "resultAlias": "kafka.controller.ControllerStats.LeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "POSITIVE"
              , "units": "calls"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"LeaderElectionRateAndTimeMs\""
        , "attr": [ "FifteenMinuteRate" ]
        , "resultAlias": "kafka.controller.ControllerStats.LeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "calls/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"LeaderElectionRateAndTimeMs\""
        , "attr": [ "FiveMinuteRate" ]
        , "resultAlias": "kafka.controller.ControllerStats.LeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "calls/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"LeaderElectionRateAndTimeMs\""
        , "attr": [ "MeanRate" ]
        , "resultAlias": "kafka.controller.ControllerStats.LeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "calls/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"LeaderElectionRateAndTimeMs\""
        , "attr": [ "OneMinuteRate" ]
        , "resultAlias": "kafka.controller.ControllerStats.LeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "calls/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"UncleanLeaderElectionsPerSec\""
        , "attr": [ "Count" ]
        , "resultAlias": "kafka.controller.ControllerStats.UncleanLeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "POSITIVE"
              , "units": "elections"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"UncleanLeaderElectionsPerSec\""
        , "attr": [ "FifteenMinuteRate" ]
        , "resultAlias": "kafka.controller.ControllerStats.UncleanLeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "elections/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"UncleanLeaderElectionsPerSec\""
        , "attr": [ "FiveMinuteRate" ]
        , "resultAlias": "kafka.controller.ControllerStats.UncleanLeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "elections/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"UncleanLeaderElectionsPerSec\""
        , "attr": [ "MeanRate" ]
        , "resultAlias": "kafka.controller.ControllerStats.UncleanLeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "elections/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      , { "obj": "\"kafka.controller\":type=\"ControllerStats\",name=\"UncleanLeaderElectionsPerSec\""
        , "attr": [ "OneMinuteRate" ]
        , "resultAlias": "kafka.controller.ControllerStats.UncleanLeaderElection"
        , "outputWriters":
          [
            { "@class": "com.googlecode.jmxtrans.model.output.KeyOutWriter"
            , "settings":
              { "outputFile": "/tmp/jmxtrans.out"
              }
            }
          , { "@class" : "com.googlecode.jmxtrans.model.output.GangliaWriter"
            , "settings":
              { "host": "ganglia.example.com"
              , "port": 8649
              , "slope": "BOTH"
              , "units": "elections/second"
              , "groupName": "kafka"
              }
            }
          ]
        }
      ]
    }
  ]
}
```