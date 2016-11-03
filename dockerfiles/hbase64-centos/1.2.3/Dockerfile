# HBase (Vanilla) on CentOS 7.
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
# HBASE
################################################

ENV HBASE_VERSION 1.2.3
ENV ARCHIVE hbase-$HBASE_VERSION-bin.tar.gz
ENV ARCHIVE_URL https://dist.apache.org/repos/dist/release/hbase/$HBASE_VERSION/$ARCHIVE
ENV SHA_URL $ARCHIVE_URL.asc
ENV HBASE_KEYS https://dist.apache.org/repos/dist/release/hbase/KEYS

# UTF-8 locale
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# Install HBase
RUN \
	yum -y update \
	&& yum -y install \
		wget \
		ca-certificates \
		java-1.8.0-openjdk-devel \
		openssh-server \
		openssh-clients \
		snappy \
	&& yum clean all \
	&& wget $ARCHIVE_URL \
	&& wget $SHA_URL \
	&& wget $HBASE_KEYS \
	&& gpg --import KEYS \
	&& gpg --verify $ARCHIVE.asc \
	&& mkdir /opt/hbase \
	&& tar xvf $ARCHIVE -C /opt/hbase \
	&& rm -f $ARCHIVE \
	&& rm -f $ARCHIVE.asc \
	&& ln -s /opt/hbase/*hbase* /opt/hbase/default
	
# Native x86_64 libraries
ADD lib-native-x86_64.tar.gz /opt/hadoop/default/lib
ENV LD_LIBRARY_PATH /opt/hadoop/default/lib/native
RUN ln -s /lib64/libcrypto.so.10 /opt/hadoop/default/lib/native/libcrypto.so

# Configuration volume
VOLUME ["/opt/hbase/default/conf"]

# Data volume
VOLUME ["/data"]

# SSH volume
VOLUME ["/ssh"]

# Directories of binaries are added to PATH
ENV PATH=$PATH:/opt/hbase/default/bin

# Other environment variables
ENV JAVA_HOME /usr

# HBase ports
EXPOSE 60000 60010 60020 60030

# SSH port
EXPOSE 10122

# The container stays idle waiting for the orchestration
CMD bash --login -i
