#!/bin/bash

#java
JAVA_ARCHIVE=jdk-7u51-linux-x64.gz
#hadoop
HADOOP_PREFIX=/usr/local/hadoop
HADOOP_CONF=$HADOOP_PREFIX/etc/hadoop
HADOOP_VERSION=hadoop-2.4.1
HADOOP_ARCHIVE=$HADOOP_VERSION.tar.gz
HADOOP_MIRROR_DOWNLOAD=http://www.gtlib.gatech.edu/pub/apache/hadoop/common/hadoop-2.4.1/hadoop-2.4.1.tar.gz
HADOOP_RES_DIR=/vagrant/resources/hadoop
#spark
SPARK_VERSION=spark-1.0.1
SPARK_ARCHIVE=$SPARK_VERSION-bin-hadoop2.tgz
SPARK_MIRROR_DOWNLOAD=http://www.google.com/url?q=http%3A%2F%2Fmirrors.ibiblio.org%2Fapache%2Fspark%2Fspark-1.0.1%2Fspark-1.0.1.tgz&sa=D&sntz=1&usg=AFQjCNHcDNB1l9iRsGJyQzF7g-wLC15_Ag
SPARK_RES_DIR=/vagrant/resources/spark
SPARK_CONF_DIR=/usr/local/spark/conf
#ssh
SSH_RES_DIR=/vagrant/resources/ssh
RES_SSH_COPYID_ORIGINAL=$SSH_RES_DIR/ssh-copy-id.original
RES_SSH_COPYID_MODIFIED=$SSH_RES_DIR/ssh-copy-id.modified
RES_SSH_CONFIG=$SSH_RES_DIR/config

function resourceExists {
	FILE=/vagrant/resources/$1
	if [ -e $FILE ]
	then
		return 0
	else
		return 1
	fi
}

function fileExists {
	FILE=$1
	if [ -e $FILE ]
	then
		return 0
	else
		return 1
	fi
}

#echo "common loaded"