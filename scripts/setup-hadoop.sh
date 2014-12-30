#!/bin/bash
source "/vagrant/scripts/common.sh"

function installLocalHadoop {
	echo "install hadoop from local file"
	FILE=/vagrant/resources/$HADOOP_ARCHIVE
	tar -xzf $FILE -C /usr/local
}

function installRemoteHadoop {
	echo "install hadoop from remote file"
	curl -o /vagrant/resources/$HADOOP_ARCHIVE -O -L $HADOOP_MIRROR_DOWNLOAD
	tar -xzf /vagrant/resources/$HADOOP_ARCHIVE -C /usr/local
}

function setupHadoop {
	echo "creating hadoop directories"
	mkdir /var/hadoop
	mkdir /var/hadoop/hadoop-datanode
	mkdir /var/hadoop/hadoop-namenode
	mkdir /var/hadoop/mr-history
	mkdir /var/hadoop/mr-history/done
	mkdir /var/hadoop/mr-history/tmp
	
	echo "copying over hadoop configuration files"
	cp -f $HADOOP_RES_DIR/* $HADOOP_CONF
}

function setupEnvVars {
	echo "creating hadoop environment variables"
	cp -f $HADOOP_RES_DIR/hadoop.sh /etc/profile.d/hadoop.sh
}

function installHadoop {
	if resourceExists $HADOOP_ARCHIVE; then
		installLocalHadoop
	else
		installRemoteHadoop
	fi
	ln -s /usr/local/$HADOOP_VERSION /usr/local/hadoop
}


echo "setup hadoop"
installHadoop
setupHadoop
setupEnvVars