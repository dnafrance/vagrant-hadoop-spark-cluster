#!/bin/bash
# http://linux.about.com/od/Bash_Scripting_Solutions/a/How-To-Pass-Arguments-To-A-Bash-Script.htm
# http://stackoverflow.com/questions/169511/how-do-i-iterate-over-a-range-of-numbers-defined-by-variables-in-bash
# http://www.cyberciti.biz/faq/bash-for-loop/
# https://docs.vagrantup.com/v2/provisioning/shell.html
# http://www.cyberciti.biz/faq/bash-prepend-text-lines-to-file/
source "/vagrant/scripts/common.sh"
TOTAL_NODES=2

while getopts t: option
do
	case "${option}"
	in
		t) TOTAL_NODES=${OPTARG};;
	esac
done

function setupHosts {
	echo "modifying /etc/hosts file"
	for i in $(seq 1 $TOTAL_NODES)
	do 
		entry="10.211.55.10${i} node${i}"
		echo "adding ${entry}"
		echo "${entry}" >> /etc/nhosts
	done
	echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" >> /etc/nhosts
	echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/nhosts
	#cat /etc/hosts >> /etc/nhosts
	cp /etc/nhosts /etc/hosts
	rm -f /etc/nhosts
}


echo "setup centos hosts file"
setupHosts