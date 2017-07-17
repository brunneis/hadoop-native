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

FROM brunneis/jdk-centos:1.8
MAINTAINER "Rodrigo Martínez" <dev@brunneis.com>

################################################
# HBASE
################################################

# Install HBase
RUN \
	export HBASE_VERSION="$(curl https://dist.apache.org/repos/dist/release/hbase/stable | awk '{print $2}')" \
	&& export HBASE_ARCHIVE="hbase-$HBASE_VERSION-bin.tar.gz" \
	&& export HBASE_ARCHIVE_URL="https://dist.apache.org/repos/dist/release/hbase/$HBASE_VERSION/$HBASE_ARCHIVE" \
	&& export HBASE_ASC_URL="$HBASE_ARCHIVE_URL.asc" \
	&& export HBASE_KEYS="https://dist.apache.org/repos/dist/release/hbase/KEYS" \
	&& yum -y update \
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

# The container stays idle
CMD bash --login -i
