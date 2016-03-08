# hadoop-hbase-install_ami.sh | Basic installation of Apache Hadoop
# and HBase with native libraries for the x86_64 architecture and
# configuration of the host names. The script has to be executed
# in every node. 

# Copyright (C) 2016 brunneis (Rodrigo Martínez)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#!/bin/bash

### USAGE #####################################################
# curl -fsSL https://[...]/hadoop-hbase-install_ami.sh \      #
# | sudo bash -s MASTER_HOST SLAVE_HOST MASTER_IP \           # 
# SLAVE1_IP SLAVE2_IP ...                                     #
###############################################################

### ATENTION ##################################################
# Intended to be used in an new EC2 Amazon AMI instance.      #
###############################################################

if [ "$#" -lt 4 ] ; then 
	echo -e "> Error: the minimum number of parameters is four:\n"
	exit
fi

# HADOOP ACCOUNT
HADOOP_GROUP=hadoop
HADOOP_USER=hduser
HADOOP_PASSWORD=hduser

# ORACLE JDK
# JDK_VERSION=1.7.0_79
# JDK_BIN_ARCHIVE=jdk-7u79-linux-x64.tar.gz
# JDK_DOWNLOAD_LINK=http://download.oracle.com/otn-pub/java/jdk/7u79-b15/$JDK_BIN_ARCHIVE
JDK_VERSION=1.8.0_74
JDK_BIN_ARCHIVE=jdk-8u74-linux-x64.tar.gz
JDK_DOWNLOAD_LINK=http://download.oracle.com/otn-pub/java/jdk/8u74-b02/$JDK_BIN_ARCHIVE
JDK_INSTALL_DIR=/opt/oracle/java

# APACHE HADOOP
HADOOP_VERSION=2.7.2
HADOOP_BIN_ARCHIVE=hadoop-$HADOOP_VERSION-x86_64_ami.tar.gz
HADOOP_DOWNLOAD_LINK=https://dev.brunneis.com/hadoop/$HADOOP_BIN_ARCHIVE
HADOOP_INSTALL_DIR=/opt/apache/hadoop

# APACHE HBASE
HBASE_VERSION=1.1.3
HBASE_BIN_ARCHIVE=hbase-$HBASE_VERSION-bin.tar.gz
# HBASE_DOWNLOAD_LINK=http://apache.rediris.es/hbase/$HBASE_VERSION/$HBASE_BIN_ARCHIVE
HBASE_DOWNLOAD_LINK=http://www-us.apache.org/dist/hbase/$HBASE_VERSION/$HBASE_BIN_ARCHIVE
HBASE_INSTALL_DIR=/opt/apache/hbase

# SYSTEM UPDATE AND BASIC DEPENDENCIES
yum -y update && yum -y install zlib-devel gzip-devel bzip2-devel openssl-devel snappy-devel \
wget openssh-sever openssl sudo

# ORACLE JDK INSTALL
echo -e 'Installing Oracle JDK...\n'
mkdir -p $JDK_INSTALL_DIR
cd $JDK_INSTALL_DIR
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
$JDK_DOWNLOAD_LINK
tar xzf $JDK_BIN_ARCHIVE
rm -f $JDK_BIN_ARCHIVE
ln -sf jdk$JDK_VERSION current
echo export JAVA_HOME=$JDK_INSTALL_DIR/current > /etc/profile.d/oracle-jdk.sh
echo export JRE_HOME=$JDK_INSTALL_DIR/current/jre >> /etc/profile.d/oracle-jdk.sh
echo 'if ! echo $PATH | grep -q '$JDK_INSTALL_DIR'/current/bin:'$JDK_INSTALL_DIR'/current/jre/bin ; then
export PATH='$JDK_INSTALL_DIR'/current/bin:'$JDK_INSTALL_DIR'/current/jre/bin:$PATH ; fi' \
>> /etc/profile.d/oracle-jdk.sh
. /etc/profile.d/oracle-jdk.sh

# Add hadoop user (with sudo) and group
groupadd $HADOOP_GROUP
useradd -G $HADOOP_GROUP -p $(echo $HADOOP_PASSWORD | openssl passwd -1 -stdin) $HADOOP_USER

# APACHE HADOOP
echo -e 'Installing Hadoop...\n'
mkdir -p $HADOOP_INSTALL_DIR
cd $HADOOP_INSTALL_DIR
wget $HADOOP_DOWNLOAD_LINK
tar xzf $HADOOP_BIN_ARCHIVE
rm -f $HADOOP_BIN_ARCHIVE
ln -sf hadoop-${HADOOP_VERSION} current
echo 'export HADOOP_PREFIX='$HADOOP_INSTALL_DIR'/current' > /etc/profile.d/apache-hadoop.sh
echo 'export HADOOP_HOME=$HADOOP_PREFIX' >> /etc/profile.d/apache-hadoop.sh
echo 'export HADOOP_COMMON_HOME=$HADOOP_PREFIX' >> /etc/profile.d/apache-hadoop.sh
echo 'export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop' >> /etc/profile.d/apache-hadoop.sh
echo 'export HADOOP_HDFS_HOME=$HADOOP_PREFIX/share/hadoop/hdfs' >> /etc/profile.d/apache-hadoop.sh
echo 'export HADOOP_YARN_HOME=$HADOOP_PREFIX/share/hadoop/yarn' >> /etc/profile.d/apache-hadoop.sh
echo 'export HADOOP_MAPRED_HOME=$HADOOP_PREFIX' >> /etc/profile.d/apache-hadoop.sh
echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_PREFIX/lib/native' >> /etc/profile.d/apache-hadoop.sh
echo 'export HADOOP_OPTS=-Djava.library.path=$HADOOP_COMMON_LIB_NATIVE_DIR' >> /etc/profile.d/apache-hadoop.sh
echo 'if ! echo $PATH | grep -q $HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin ; then 
export PATH=$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin:$PATH; fi' >> /etc/profile.d/apache-hadoop.sh
. /etc/profile.d/apache-hadoop.sh
chown -R hduser:hadoop /opt/apache/hadoop

# APACHE HBASE
echo -e 'Installing HBase...\n'
mkdir -p $HBASE_INSTALL_DIR
cd $HBASE_INSTALL_DIR
wget $HBASE_DOWNLOAD_LINK
tar xzf $HBASE_BIN_ARCHIVE
rm -f $HBASE_BIN_ARCHIVE
ln -sf hbase-${HBASE_VERSION} current
echo 'export HBASE_INSTALL_DIR='$HBASE_INSTALL_DIR'/current' > /etc/profile.d/apache-hbase.sh
echo 'export HBASE_HOME=$HBASE_INSTALL_DIR' >> /etc/profile.d/apache-hbase.sh
echo 'export HBASE_LIBRARY_PATH=$HADOOP_PREFIX/lib/native' >> /etc/profile.d/apache-hbase.sh
echo 'if ! echo $PATH | grep -q $HBASE_INSTALL_DIR/bin ; then 
export PATH=$HBASE_INSTALL_DIR/bin:$PATH; fi' >> /etc/profile.d/apache-hbase.sh
rm -f $HBASE_INSTALL_DIR/current/lib/slf4j-log4j12-*.jar
chown -R hduser:hadoop /opt/apache/hbase

# HOST CONFIGURATION
echo -e 'Configuring host...\n'
MASTER_HOST=$1
SLAVE_HOST=$2
MASTER_IP=$3
NEW_HOST=${hostname}

# Determine the host name
for i in `seq 3 $#` ; do
	if [ "${!i}" == "$(hostname -I | xargs)" ] ; then
		if [ $i -eq 3 ]; then
			NEW_HOST=$MASTER_HOST
			# Allow sudo if it is the master
			echo $HADOOP_USER" ALL=(ALL) ALL" >> /etc/sudoers
			service sshd restart
			break
		else
			NEW_HOST=$SLAVE_HOST$(expr $i - 3)
			# Allow sudo without password for the slaves (temporarily)
			echo $HADOOP_USER" ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
			service sshd restart

			# Allow SSH access with password in every slave (temporarily)
			sed -ri 's/^PasswordAuthentication\sno/PasswordAuthentication yes/' /etc/ssh/sshd_config
			break
		fi
	fi
done
hostname $NEW_HOST
if cat /etc/sysconfig/network | grep -q HOSTNAME= ; 
then sed -i "s/HOSTNAME=.*/HOSTNAME=$NEW_HOST/g" /etc/sysconfig/network
else echo "HOSTNAME="$NEW_HOST >> /etc/sysconfig/network ; fi

# Add every node to /etc/hosts
echo -e $MASTER_IP"\t"$MASTER_HOST >> /etc/hosts
for i in `seq 4 $#` ; do
	echo -e "${!i}\t"$SLAVE_HOST$(expr $i - 3) >> /etc/hosts
done

echo "Done!"
exit