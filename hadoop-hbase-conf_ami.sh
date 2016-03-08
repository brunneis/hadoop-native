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
# | sudo bash -s SLAVE1_HOSTNAME SLAVE2_HOSTNAME ...          #
###############################################################

### ATENTION ##################################################
# Intended to be used in an EC2 Amazon AMI instance after     #
# the execution of hadoop-hbase-install_ami.sh.               #
# The script has to be executed in the master.                #
###############################################################

# HADOOP ACCOUNT
HADOOP_USER=hduser
HADOOP_GROUP=hadoop
# HADOOP_PASSWORD is defined after login as HADOOP_USER

# SSHPASS SCRIPT VARIABLES
SSHPASS_VERSION=1.05
SSHPASS_BIN_ARCHIVE=sshpass-$SSHPASS_VERSION-bin-x86_64_ami.tar.gz
SSHPASS_DOWNLOAD_LINK=https://dev.brunneis.com/ssh/$SSHPASS_BIN_ARCHIVE

# Copy sshpass binary to the home directory of the hadoop user
cd /home/$HADOOP_USER
wget $SSHPASS_DOWNLOAD_LINK
tar xzf $SSHPASS_BIN_ARCHIVE
rm -f $SSHPASS_BIN_ARCHIVE
cp sshpass-$SSHPASS_VERSION/bin/sshpass .
rm -rf sshpass-$SSHPASS_VERSION

# Make the hadoop user the owner of sshpass
chown $HADOOP_USER:$HADOOP_GROUP sshpass

# Write the host names of the nodes in the regionservers file
# of the HBase configuration
echo $(hostname) > $HBASE_INSTALL_DIR/conf/regionservers
for i in $@ ; do
	echo $i >> $HBASE_INSTALL_DIR/conf/regionservers
done

# Make the hadoop user the owner of the regionservers
chown $HADOOP_USER:$HADOOP_GROUP $HBASE_INSTALL_DIR/conf/regionservers

su - $HADOOP_USER
HADOOP_PASSWORD=hduser
HADOOP_USER=$(whoami)

# Allow the master to SSH itself without password
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys

for slave in $(cat $HBASE_INSTALL_DIR/conf/regionservers) ; do
	./sshpass -p $HADOOP_PASSWORD ssh-copy-id $slave -o StrictHostKeyChecking=no
done
rm -f sshpass

for slave in $(cat slaves) ; do
	# Disable SSH access with password in every slave
	ssh $slave "sudo sed -ri 's/^PasswordAuthentication\syes/PasswordAuthentication no/' /etc/ssh/sshd_config"
	# Disable sudo without password in every slave
	ssh $slave "sudo sed -ri 's/^$HADOOP_USER\sALL=\(ALL\)\sNOPASSWD:\sALL/$HADOOP_USER ALL=(ALL) ALL/' /etc/sudoers"
	# Allow the slave to SSH itself without password
	ssh $slave "ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa"
	ssh $slave "cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys"
	ssh $slave "chmod 0600 ~/.ssh/authorized_keys"
done
rm -f slaves

echo "Done!"
exit
