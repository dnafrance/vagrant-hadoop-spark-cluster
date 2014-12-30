#!/bin/bash
# http://unix.stackexchange.com/questions/59003/why-ssh-copy-id-prompts-for-the-local-user-password-three-times
# http://linuxcommando.blogspot.com/2008/10/how-to-disable-ssh-host-key-checking.html
# http://linuxcommando.blogspot.ca/2013/10/allow-root-ssh-login-with-public-key.html
# http://stackoverflow.com/questions/12118308/command-line-to-execute-ssh-with-password-authentication
# http://www.cyberciti.biz/faq/noninteractive-shell-script-ssh-password-provider/
source "/vagrant/scripts/common.sh"
START=3
TOTAL_NODES=2

while getopts s:t: option
do
	case "${option}"
	in
		s) START=${OPTARG};;
		t) TOTAL_NODES=${OPTARG};;
	esac
done
#echo "total nodes = $TOTAL_NODES"

function installSSHPass {
	yum -y install wget
	wget http://pkgs.repoforge.org/sshpass/sshpass-1.05-1.el6.rf.i686.rpm
	rpm -ivh sshpass-1.05-1.el6.rf.i686.rpm
	yum -y install sshpass
}

function overwriteSSHCopyId {
	cp -f $RES_SSH_COPYID_MODIFIED /usr/bin/ssh-copy-id
}

function setupHosts {
	echo "modifying /etc/hosts file"
	for i in $(seq 1 $TOTAL_NODES)
	do 
		if [ $i -lt 10 ]; then
			entry="10.211.55.10${i} node${i}"
		elif [ $ i < 100]; then
			entry="10.211.55.1${i} node${i}"
		else
			entry="10.211.55.${i} node${i}"
		fi
		echo "adding ${entry}"
		echo "${entry}" >> /etc/hosts
	done
}

function createSSHKey {
	echo "generating ssh key"
	ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
	cp -f $RES_SSH_CONFIG ~/.ssh
}

function sshCopyId {
	echo "executing ssh-copy-id"
	for i in $(seq $START $TOTAL_NODES)
	do 
		node="node${i}"
		echo "copy ssh key to ${node}"
		ssh-copy-id -i ~/.ssh/id_rsa.pub $node
	done
}

echo "setup ssh"
installSSHPass
createSSHKey
overwriteSSHCopyId
sshCopyId
