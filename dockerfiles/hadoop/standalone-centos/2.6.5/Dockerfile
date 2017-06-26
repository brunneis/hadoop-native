# Hadoop Standalone (Vanilla) on CentOS 7 with native libraries for x86_64.
# Copyright (C) 2016-2017 Rodrigo Martínez <dev@brunneis.com>
#
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

FROM brunneis/hadoop-x86-64-base:2.6.5
MAINTAINER "Rodrigo Martínez" <dev@brunneis.com>

################################################
# HADOOP STANDALONE 2.6.5
################################################

RUN \
	echo -e '\n' | ssh-keygen -P '' \
	&& echo -e "Host *\n UserKnownHostsFile /dev/null\n \
		StrictHostKeyChecking no" > /root/.ssh/config \
	&& sed -i 's/.*session.*required.*pam_loginuid.so.*/session \
		optional pam_loginuid.so/g' /etc/pam.d/sshd \
	&& echo -e  'y\n' | ssh-keygen -P '' -q -t rsa -f \
		/etc/ssh/ssh_host_rsa_key \
	&& echo -e  'y\n' | ssh-keygen -P '' -q -t ecdsa -f \
		/etc/ssh/ssh_host_ecdsa_key \
	&& echo -e  'y\n' | ssh-keygen -P '' -q -t ed25519 -f \
		/etc/ssh/ssh_host_ed25519_key \
	&& mv ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys \
	&& echo "<configuration><property><name>fs.defaultFS</name>\
		<value>hdfs://localhost:8020</value></property></configuration>" \
	> $HADOOP_PREFIX/etc/hadoop/core-site.xml \
	&& echo "<configuration><property><name>dfs.replication</name>\
		<value>1</value></property></configuration>" \
	> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml \
	&& echo "<configuration><property><name>mapreduce.framework.name</name>\
		<value>yarn</value></property></configuration>" \
	> $HADOOP_PREFIX/etc/hadoop/mapred-site.xml \
	&& echo "<configuration><property><name>yarn.nodemanager.aux-services</name>\
		<value>mapreduce_shuffle</value></property>\n\
		<property><name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\
		<value>org.apache.hadoop.mapred.ShuffleHandler</value></property>\n\
		<property><name>yarn.resourcemanager.hostname</name>\
		<value>localhost</value></property></configuration>" \
	> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml \
	&& sed -i 's@export JAVA_HOME.*$@export JAVA_HOME=/usr@' \
		$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

RUN $HADOOP_PREFIX/bin/hdfs namenode -format

VOLUME ["/tmp"]

COPY entrypoint.sh /
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
