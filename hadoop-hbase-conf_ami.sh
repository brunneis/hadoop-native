# hadoop-hbase-conf_ami.sh | Copy the ssh key of the master in
# every slave node and distribute the base templates of the 
# configuration files for Hadoop and HBase. 

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
# curl -fsSL https://[...]/hadoop-hbase-conf_ami.sh \         #
# | bash -s SLAVE1_HOSTNAME SLAVE2_HOSTNAME                   #
###############################################################

### ATENTION ##################################################
# Intended to be used in an EC2 Amazon AMI instance after     #
# the execution of hadoop-hbase-install_ami.sh.               #
# The script has to be executed in the master as the hadoop   #
# user.                                                       #
###############################################################

# HADOOP ACCOUNT
HADOOP_PASSWORD=hduser
HADOOP_USER=$(whoami)

# SSHPASS SCRIPT VARIABLES
SSHPASS_VERSION=1.05
SSHPASS_BIN_ARCHIVE=sshpass-$SSHPASS_VERSION-bin-x86_64_ami.tar.gz
SSHPASS_DOWNLOAD_LINK=https://dev.brunneis.com/ssh/$SSHPASS_BIN_ARCHIVE

# [HBase] regionservers
HBASE_REGIONSERVERS_FILE=$HBASE_INSTALL_DIR/conf/regionservers

# [HBase] hbase-env.sh
HBASE_ENV_TEMPLATE=$(curl -fsSL https://dev.brunneis.com/templates/hbase/hbase-env.sh_template)
HBASE_ENV_FILE=$HBASE_INSTALL_DIR/conf/hbase-env.sh
declare -A HBASE_ENV_PROPERTIES=(
#["HBASE_HEAPSIZE"]=4G
#["HBASE_OPTS"]='"$HBASE_OPTS -Xgcpolicy:balanced -XX:+UseConcMarkSweepGC"'
#["HBASE_REGIONSERVER_OPTS"]='"-Xms4G -Xmx4g"'
["HBASE_MANAGES_ZK"]=true
)

# [HBase] hbase-site.xml
HBASE_SITE_TEMPLATE=$(curl -fsSL https://dev.brunneis.com/templates/hbase/hbase-site.xml_template)
HBASE_SITE_FILE=$HBASE_INSTALL_DIR/conf/hbase-site.xml
declare -A HBASE_SITE_PROPERTIES=(
["hbase-master"]=$(hostname -I | xargs):60000
["hbase.rootdir"]="hdfs://$(hostname -I | xargs):8020/user/$HADOOP_USER/hbase-datastore"
["hbase.cluster.distributed"]=true
["hbase.zookeeper.property.clientPort"]=2181
["hbase.zookeeper.quorum"]=$(cat $HBASE_REGIONSERVERS_FILE | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/,/g')
["hbase.zookeeper.property.maxClientCnxns"]=1000
["hbase.regionserver.region.split.policy"]=org.apache.hadoop.hbase.regionserver.ConstantSizeRegionSplitPolicy
["hbase.hregion.max.filesize"]=21474836480
)

# [Hadoop] slaves
HADOOP_SLAVES_FILE=$HADOOP_PREFIX/etc/hadoop/slaves

# [Hadoop] core-site.xml
HADOOP_CORE_SITE_TEMPLATE=$(curl -fsSL https://dev.brunneis.com/templates/hadoop/core-site.xml_template)
HADOOP_CORE_SITE_FILE=$HADOOP_PREFIX/etc/hadoop/core-site.xml
declare -A HADOOP_CORE_SITE_PROPERTIES=(
["fs.defaultFS"]="hdfs://$(hostname -I | xargs):8020"
["file.blocksize"]=134217728
)

# [Hadoop] hdfs-site.xml
HADOOP_HDFS_SITE_TEMPLATE=$(curl -fsSL https://dev.brunneis.com/templates/hadoop/hdfs-site.xml_template)
HADOOP_HDFS_SITE_FILE=$HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
declare -A HADOOP_HDFS_SITE_PROPERTIES=(
["dfs.datanode.data.dir"]="file://$HADOOP_PREFIX/hadoop-data/hdfs/datanode"
["dfs.namenode.name.dir"]="file://$HADOOP_PREFIX/hadoop-data/hdfs/namenode"
#["dfs.namenode.http-address"]=$(hostname)
["dfs.blocksize"]=134217728
)

# [Hadoop] mapred-site.xml
HADOOP_MAPRED_SITE_TEMPLATE=$(curl -fsSL https://dev.brunneis.com/templates/hadoop/mapred-site.xml_template)
HADOOP_MAPRED_SITE_FILE=$HADOOP_PREFIX/etc/hadoop/mapred-site.xml
declare -A HADOOP_MAPRED_SITE_PROPERTIES=(
#["yarn.app.mapreduce.am.resource.cpu-vcores"]=1
#["yarn.app.mapreduce.am.resource.mb"]=512
#["mapreduce.map.cpu.vcores"]=1
#["mapreduce.map.memory.mb"]=512
#["mapreduce.map.java.opts"]=-Xmx512m
#["mapreduce.reduce.cpu.vcores"]=1
#["mapreduce.reduce.memory.mb"]=512
#["mapreduce.reduce.java.opts"]=-Xmx512m
#["mapreduce.task.io.sort.mb"]=256
#["mapreduce.jobtracker.address"]=$(hostname -I | xargs):8021
["mapreduce.task.timeout"]=1800000
#["mapreduce.jobhistory.address"]=$(hostname -I | xargs):10020
["mapreduce.framework.name"]=yarn
)

# [Hadoop] yarn-site.xml
HADOOP_YARN_SITE_TEMPLATE=$(curl -fsSL https://dev.brunneis.com/templates/hadoop/yarn-site.xml_template)
HADOOP_YARN_SITE_FILE=$HADOOP_PREFIX/etc/hadoop/yarn-site.xml
declare -A HADOOP_YARN_SITE_PROPERTIES=(
#["yarn.scheduler.capacity.resource-calculator"]=org.apache.hadoop.yarn.util.resource.DominantResourceCalculator
#["yarn.nodemanager.resource.cpu-vcores"]=1
#["yarn.nodemanager.resource.memory-mb"]=512
#["yarn.scheduler.minimum-allocation-vcores"]=1
#["yarn.scheduler.maximum-allocation-vcores"]=1
#["yarn.scheduler.increment-allocation-vcores"]=1
#["yarn.scheduler.minimum-allocation-mb"]=512
#["yarn.scheduler.maximum-allocation-mb"]=512
#["yarn.scheduler.increment-allocation-mb"]=512
["yarn.nodemanager.aux-services"]=mapreduce_shuffle
["yarn.resourcemanager.hostname"]=$(hostname -I | xargs)
#["yarn.log-aggregation-enable"]=true
#["yarn.resourcemanager.webapp.address"]=$(hostname)
)

# [HBase] regionservers generation
echo $(hostname) > $HBASE_REGIONSERVERS_FILE
echo $(hostname) > $HADOOP_SLAVES_FILE
for i in $@ ; do
	echo $i >> $HBASE_REGIONSERVERS_FILE
	echo $i >> $HADOOP_SLAVES_FILE
done

# [HBase] hbase-env.sh generation
echo "$HBASE_ENV_TEMPLATE" > $HBASE_ENV_FILE
for property in "${!HBASE_ENV_PROPERTIES[@]}"; do
	echo "export $property=${HBASE_ENV_PROPERTIES["$property"]}" >> $HBASE_ENV_FILE
done

# [HBase] hbase-site.xml generation
echo "$HBASE_SITE_TEMPLATE" > $HBASE_SITE_FILE
echo -e "<configuration>\n" >> $HBASE_SITE_FILE
for property in "${!HBASE_SITE_PROPERTIES[@]}"; do
	echo -e "\t<property>" >> $HBASE_SITE_FILE
	echo -e "\t\t<name>$property</name>" >> $HBASE_SITE_FILE	
	echo -e "\t\t<value>${HBASE_SITE_PROPERTIES["$property"]}</value>" >> $HBASE_SITE_FILE
	echo -e "\t</property>\n" >> $HBASE_SITE_FILE
done
echo "</configuration>" >> $HBASE_SITE_FILE

# [Hadoop] hdfs-site.xml generation
echo "$HADOOP_HDFS_SITE_TEMPLATE" > $HADOOP_HDFS_SITE_FILE
echo -e "<configuration>\n" >> $HADOOP_HDFS_SITE_FILE
for property in "${!HADOOP_HDFS_SITE_PROPERTIES[@]}"; do
	echo -e "\t<property>" >> $HADOOP_HDFS_SITE_FILE
	echo -e "\t\t<name>$property</name>" >> $HADOOP_HDFS_SITE_FILE	
	echo -e "\t\t<value>${HADOOP_HDFS_SITE_PROPERTIES["$property"]}</value>" >> $HADOOP_HDFS_SITE_FILE
	echo -e "\t</property>\n" >> $HADOOP_HDFS_SITE_FILE
done
echo "</configuration>" >> $HADOOP_HDFS_SITE_FILE

# [Hadoop] mapred-site.xml generation
echo "$HADOOP_MAPRED_SITE_TEMPLATE" > $HADOOP_MAPRED_SITE_FILE
echo -e "<configuration>\n" >> $HADOOP_MAPRED_SITE_FILE
for property in "${!HADOOP_MAPRED_SITE_PROPERTIES[@]}"; do
	echo -e "\t<property>" >> $HADOOP_MAPRED_SITE_FILE
	echo -e "\t\t<name>$property</name>" >> $HADOOP_MAPRED_SITE_FILE	
	echo -e "\t\t<value>${HADOOP_MAPRED_SITE_PROPERTIES["$property"]}</value>" >> $HADOOP_MAPRED_SITE_FILE
	echo -e "\t</property>\n" >> $HADOOP_MAPRED_SITE_FILE
done
echo "</configuration>" >> $HADOOP_MAPRED_SITE_FILE

# [Hadoop] yarn-site.xml generation
echo "$HADOOP_YARN_SITE_TEMPLATE" > $HADOOP_YARN_SITE_FILE
echo -e "<configuration>\n" >> $HADOOP_YARN_SITE_FILE
for property in "${!HADOOP_YARN_SITE_PROPERTIES[@]}"; do
	echo -e "\t<property>" >> $HADOOP_YARN_SITE_FILE
	echo -e "\t\t<name>$property</name>" >> $HADOOP_YARN_SITE_FILE	
	echo -e "\t\t<value>${HADOOP_YARN_SITE_PROPERTIES["$property"]}</value>" >> $HADOOP_YARN_SITE_FILE
	echo -e "\t</property>\n" >> $HADOOP_YARN_SITE_FILE
done
echo "</configuration>" >> $HADOOP_YARN_SITE_FILE

# [Hadoop] core-site.xml generation
echo "$HADOOP_CORE_SITE_TEMPLATE" > $HADOOP_CORE_SITE_FILE
echo -e "<configuration>\n" >> $HADOOP_CORE_SITE_FILE
for property in "${!HADOOP_CORE_SITE_PROPERTIES[@]}"; do
	echo -e "\t<property>" >> $HADOOP_CORE_SITE_FILE
	echo -e "\t\t<name>$property</name>" >> $HADOOP_CORE_SITE_FILE	
	echo -e "\t\t<value>${HADOOP_CORE_SITE_PROPERTIES["$property"]}</value>" >> $HADOOP_CORE_SITE_FILE
	echo -e "\t</property>\n" >> $HADOOP_CORE_SITE_FILE
done
echo "</configuration>" >> $HADOOP_CORE_SITE_FILE

# Allow the master to SSH itself without password
echo -e 'y\n' | ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
ssh-keyscan 0.0.0.0 >> ~/.ssh/known_hosts
ssh-keyscan localhost >> ~/.ssh/known_hosts
ssh-keyscan $(hostname) >> ~/.ssh/known_hosts

# Download sshpass binary
wget $SSHPASS_DOWNLOAD_LINK
tar xzf $SSHPASS_BIN_ARCHIVE
rm -f $SSHPASS_BIN_ARCHIVE
cp sshpass-$SSHPASS_VERSION/bin/sshpass .
rm -rf sshpass-$SSHPASS_VERSION

# Copy the SSH key from the master to each slave
for slave in $@ ; do
	./sshpass -p $HADOOP_PASSWORD ssh-copy-id $slave -o StrictHostKeyChecking=no
done
rm -f sshpass

for slave in $@ ; do
	# Disable SSH access with password in every slave
	ssh $slave "sudo sed -ri 's/^PasswordAuthentication\syes/PasswordAuthentication no/' /etc/ssh/sshd_config"

	# Disable sudo without password in every slave
	ssh $slave "sudo sed -ri 's/^$HADOOP_USER\sALL=\(ALL\)\sNOPASSWD:\sALL/$HADOOP_USER ALL=(ALL) ALL/' /etc/sudoers"

	# Allow the slave to SSH itself without password
	ssh $slave "echo -e 'y\n' | ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
	ssh $slave "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
	ssh $slave "chmod 0600 ~/.ssh/authorized_keys"
	ssh $slave "ssh-keyscan $slave >> ~/.ssh/known_hosts"

	# Copy the HBase configuration files to each slave
	scp $HBASE_REGIONSERVERS_FILE $slave:$HBASE_REGIONSERVERS_FILE
	scp $HBASE_ENV_FILE $slave:$HBASE_ENV_FILE
	scp $HBASE_SITE_FILE $slave:$HBASE_SITE_FILE

	# Copy the Hadoop configuration files to each slave
	scp $HADOOP_SLAVES_FILE $slave:$HADOOP_SLAVES_FILE
	scp $HADOOP_CORE_SITE_FILE $slave:$HADOOP_CORE_SITE_FILE
	scp $HADOOP_HDFS_SITE_FILE $slave:$HADOOP_HDFS_SITE_FILE
	scp $HADOOP_MAPRED_SITE_FILE $slave:$HADOOP_MAPRED_SITE_FILE
	scp $HADOOP_YARN_SITE_FILE $slave:$HADOOP_YARN_SITE_FILE
done

echo "Done!"
exit
