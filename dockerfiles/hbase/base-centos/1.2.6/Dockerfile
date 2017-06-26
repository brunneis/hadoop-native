# HBase (Vanilla) for Orchestration on CentOS 7.
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

FROM brunneis/centos-jdk
MAINTAINER "Rodrigo Martínez" <dev@brunneis.com>

################################################
# HBASE 1.2.6
################################################

ENV HBASE_VERSION 1.2.6
ENV HBASE_ARCHIVE hbase-$HBASE_VERSION-bin.tar.gz
ENV HBASE_ARCHIVE_URL https://archive.apache.org/dist/hbase/$HBASE_VERSION/$HBASE_ARCHIVE
ENV HBASE_ASC_URL $HBASE_ARCHIVE_URL.asc
ENV HBASE_KEYS https://archive.apache.org/dist/hbase/KEYS

# Install HBase
RUN \
	yum -y update \
	&& yum -y install \
		openssh-server \
		openssh-clients \
		snappy \
	&& yum clean all \
	&& wget $HBASE_ARCHIVE_URL \
	&& wget $HBASE_ASC_URL \
	&& wget $HBASE_KEYS \
	&& gpg --import KEYS \
	&& gpg --verify $HBASE_ARCHIVE.asc \
	&& mkdir /opt/hbase \
	&& tar xvf $HBASE_ARCHIVE -C /opt/hbase \
	&& rm -f $HBASE_ARCHIVE \
	&& rm -f $HBASE_ARCHIVE.asc \
	&& rm -f KEYS \
	&& ln -s /opt/hbase/*hbase* /opt/hbase/default

RUN \
    sed -i 's/^export HBASE_MASTER_OPTS/# export HBASE_MASTER_OPTS/g' \
        /opt/hbase/default/conf/hbase-env.sh \
    && sed -i 's/^export HBASE_REGIONSERVER_OPTS=/# export HBASE_REGIONSERVER_OPTS=/g' \
        /opt/hbase/default/conf/hbase-env.sh 
	
# Native x86_64 libraries
ADD lib-native-x86_64.tar.gz /opt/hadoop/lib
RUN ln -s /lib64/libcrypto.so.10 /opt/hadoop/lib/native/libcrypto.so

# Container environment variables
ENV LD_LIBRARY_PATH=/opt/hadoop/lib/native \
PATH=$PATH:/opt/hbase/default/bin

# Data volume
VOLUME ["/data"]

# The container stays idle
CMD bash --login -i
