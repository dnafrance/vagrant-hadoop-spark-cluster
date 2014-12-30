vagrant-hadoop-spark-cluster
============================

# 1. Introduction
### Vagrant project to spin up a cluster of 4, 32-bit CentOS6.5 Linux virtual machines with Hadoop v2.6.0 and Spark v1.1.1. 
Ideal for development cluster on a laptop with at least 4GB of memory.

1. node1 : HDFS NameNode + Spark Master
2. node2 : YARN ResourceManager + JobHistoryServer + ProxyServer
3. node3 : HDFS DataNode + YARN NodeManager + Spark Slave
4. node4 : HDFS DataNode + YARN NodeManager + Spark Slave

# 2. Prerequisites and Gotchas to be aware of
1. At least 1GB memory for each VM node. Default script is for 4 nodes, so you need 4GB for the nodes, in addition to the memory for your host machine.
2. Vagrant 1.7 or higher, Virtualbox 4.3.2 or higher
3. Preserve the Unix/OSX end-of-line (EOL) characters while cloning this project; scripts will fail with Windows EOL characters.
4. Project is tested on Ubuntu 32-bit 14.04 LTS host OS; not tested with VMware provider for Vagrant.
5. The Vagrant box is downloaded to the ~/.vagrant.d/boxes directory. On Windows, this is C:/Users/{your-username}/.vagrant.d/boxes.

# 3. Getting Started
1. [Download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. [Download and install Vagrant](http://www.vagrantup.com/downloads.html).
3. Run ```vagrant box add centos65 http://files.brianbirkinbine.com/vagrant-centos-65-i386-minimal.box```
4. Git clone this project, and change directory (cd) into this project (directory).
5. [Download Hadoop 2.6 into the /resources directory](http://apache.crihan.fr/dist/hadoop/common/stable/hadoop-2.6.0.tar.gz)
6. [Download Spark 1.1.1 into the /resources directory](http://d3kbcqa49mib13.cloudfront.net/spark-1.1.1-bin-hadoop2.4.tgz)
7. [Download Java 1.8 into the /resources directory](http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jdk-8u25-linux-i586.tar.gz)
8. Run ```vagrant up``` to create the VM.
9. Run ```vagrant ssh``` to get into your VM.
10. Run ```vagrant destroy``` when you want to destroy and get rid of the VM.


# 4. Modifying scripts for adapting to your environment
You need to modify the scripts to adapt the VM setup to your environment.  

1. [List of available Vagrant boxes](http://www.vagrantbox.es)

2. ./Vagrantfile  
To add/remove slaves, change the number of nodes:  
line 5: ```numNodes = 4```  
To modify VM memory change the following line:  
line 13: ```v.customize ["modifyvm", :id, "--memory", "1024"]```  
3. /scripts/common.sh  
To use a different version of Java, change the following line depending on the version you downloaded to /resources directory.  
line 4: JAVA_ARCHIVE=jdk-8u25-linux-i586.tar.gz  
To use a different version of Hadoop you've already downloaded to /resources directory, change the following line:  
line 8: ```HADOOP_VERSION=hadoop-2.6.0```  
To use a different version of Hadoop to be downloaded, change the remote URL in the following line:  
line 10: ```HADOOP_MIRROR_DOWNLOAD=http://apache.crihan.fr/dist/hadoop/common/stable/hadoop-2.6.0.tar.gz```  
To use a different version of Spark, change the following lines:  
line 13: ```SPARK_VERSION=spark-1.1.1```  
line 14: ```SPARK_ARCHIVE=$SPARK_VERSION-bin-hadoop2.4.tgz```  
line 15: ```SPARK_MIRROR_DOWNLOAD=../resources/spark-1.1.1-bin-hadoop2.4.tgz```  

3. /scripts/setup-java.sh  
To install from Java downloaded locally in /resources directory, if different from default version (1.8.0_25), change the version in the following line:  
line 18: ```ln -s /usr/local/jdk1.8.0_25 /usr/local/java```  
To modify version of Java to be installed from remote location on the web, change the version in the following line:  
line 12: ```yum install -y jdk-8u25-linux-i586```  

4. /scripts/setup-centos-ssh.sh  
To modify the version of sshpass to use, change the following lines within the function installSSHPass():  
line 23: ```wget http://pkgs.repoforge.org/sshpass/sshpass-1.05-1.el6.rf.i686.rpm```  
line 24: ```rpm -ivh sshpass-1.05-1.el6.rf.i686.rpm```  

5. /scripts/setup-spark.sh  
To modify the version of Spark to be used, if different from default version (built for Hadoop2.4), change the version suffix in the following line:  
line 32: ```ln -s /usr/local/$SPARK_VERSION-bin-hadoop2.4 /usr/local/spark```  

# 5. Post Provisioning
After you have provisioned the cluster, you need to run some commands to initialize your Hadoop cluster. SSH into node1 using  
```vagrant ssh node-1```
Commands below require root permissions. Change to root access using ```sudo su``` or create a new user and grant permissions if you want to use a non-root access. In such a case, you'll need to do this on VMs.

Issue the following command. 

1. $HADOOP_PREFIX/bin/hdfs namenode -format myhadoop

## Start Hadoop Daemons (HDFS + YARN)
SSH into node1 and issue the following commands to start HDFS.

1. $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
2. $HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode

SSH into node2 and issue the following commands to start YARN.

1. $HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager
2. $HADOOP_YARN_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager
3. $HADOOP_YARN_HOME/sbin/yarn-daemon.sh start proxyserver --config $HADOOP_CONF_DIR
4. $HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver --config $HADOOP_CONF_DIR

### Test YARN
Run the following command to make sure you can run a MapReduce job.

```
yarn jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar pi 2 100
```

## Start Spark in Standalone Mode
SSH into node1 and issue the following command.

1. $SPARK_HOME/sbin/start-all.sh

### Test Spark on YARN
You can test if Spark can run on YARN by issuing the following command. Try NOT to run this command on the slave nodes.
```
$SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn-cluster \
    --num-executors 10 \
    --executor-cores 2 \
    lib/spark-examples*.jar \
    100
```
	
### Test Spark using Shell
Start the Spark shell using the following command. Try NOT to run this command on the slave nodes.

```
$SPARK_HOME/bin/spark-shell --master spark://node1:7077
```

Then go here https://spark.apache.org/docs/latest/quick-start.html to start the tutorial. Most likely, you will have to load data into HDFS to make the tutorial work (Spark cannot read data on the local file system).

# 6. Web UI
You can check the following URLs to monitor the Hadoop daemons.

1. [NameNode] (http://10.211.55.101:50070/dfshealth.html)
2. [ResourceManager] (http://10.211.55.102:8088/cluster)
3. [JobHistory] (http://10.211.55.102:19888/jobhistory)
4. [Spark] (http://10.211.55.101:8080)

# 7. References
This project was put together with great pointers from all around the internet. All references made inside the files themselves.
Primaily this project is forked from [Jee Vang's vagrant project](https://github.com/vangj/vagrant-hadoop-2.4.1-spark-1.0.1)

# 8. Copyright Stuff
Copyright 2014 Maloy Manna

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
