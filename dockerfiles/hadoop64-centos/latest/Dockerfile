# Hadoop for orchestration (latest stable, vanilla) on CentOS 7 with native libraries for x86_64.
# Copyright (C) 2016 Rodrigo Martínez <dev@brunneis.com>
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

FROM centos:7.2.1511
MAINTAINER "Rodrigo Martínez" <dev@brunneis.com>

################################################
# HADOOP FOR ORCHESTRATION
################################################

# Environment variables
ENV LANG=en_US.UTF-8 \
LANGUAGE=en_US:en \
LC_ALL=en_US.UTF-8 \
JAVA_HOME=/usr \
HADOOP_HOME=/opt/hadoop/default
ENV LD_LIBRARY_PATH=$HADOOP_HOME/lib/native \
PATH=$PATH:$HADOOP_HOME/bin\
:$HADOOP_HOME/sbin

# Install Hadoop
RUN \
	localedef -c -f UTF-8 -i en_US en_US.UTF-8 \
	&& export HADOOP_VERSION="$(curl https://dist.apache.org/repos/dist/release/hadoop/common/stable2 | awk '{print $2}')" \
	&& export HADOOP_ARCHIVE="$HADOOP_VERSION.tar.gz" \
	&& export HADOOP_ARCHIVE_URL="https://dist.apache.org/repos/dist/release/hadoop/common/$HADOOP_VERSION/$HADOOP_ARCHIVE" \
	&& export HADOOP_SHA_URL="$HADOOP_ARCHIVE_URL.asc" \
	&& export HADOOP_KEYS="https://dist.apache.org/repos/dist/release/hadoop/common/KEYS" \
	&& yum -y update \
	&& yum -y install \
		wget \
		ca-certificates \
		java-1.8.0-openjdk-devel \
		openssh-server \
		openssh-clients \
		which \
		snappy \
	&& yum clean all \
	&& wget $HADOOP_ARCHIVE_URL \
	&& wget $HADOOP_SHA_URL \
	&& wget $HADOOP_KEYS \
	&& gpg --import KEYS \
	&& gpg --verify $HADOOP_ARCHIVE.asc \
	&& mkdir /opt/hadoop \
	&& tar xvf $HADOOP_ARCHIVE -C /opt/hadoop \
	&& rm -f $HADOOP_ARCHIVE \
	&& rm -f $HADOOP_ARCHIVE.asc \
	&& rm -f KEYS \
	&& ln -s /opt/hadoop/*hadoop* /opt/hadoop/default \
	&& rm -rf /opt/hadoop/default/lib/native
	
# Native x86_64 libraries
ADD lib-native-x86_64.tar.gz /opt/hadoop/default/lib
RUN ln -s /lib64/libcrypto.so.10 /opt/hadoop/default/lib/native/libcrypto.so

# Configuration volume
VOLUME ["/opt/hadoop/default/etc/hadoop"]

# Data volume
VOLUME ["/data"]

# SSH volume
VOLUME ["/ssh"]

# The container stays idle, waiting for the orchestration
CMD bash --login -i
