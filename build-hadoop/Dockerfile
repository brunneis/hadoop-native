# Build Apache Hadoop with native libraries
# Copyright (C) 2017-2018 Rodrigo Martínez <dev@brunneis.com>
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

FROM brunneis/maven:3.5-jdk8
MAINTAINER "Rodrigo Martínez" <dev@brunneis.com>

################################################
# BUILD HADOOP
################################################

# YASM
ENV YASM_VERSION=1.3.0
ENV YASM_SRC_ARCHIVE=yasm-$YASM_VERSION.tar.gz
ENV YASM_DOWNLOAD_LINK=http://www.tortall.net/projects/yasm/releases/$YASM_SRC_ARCHIVE

# INTEL ISA-L
ENV ISAL_VERSION=2.15.0
ENV ISAL_SRC_ARCHIVE=v$ISAL_VERSION.tar.gz
ENV ISAL_DOWNLOAD_LINK=https://github.com/01org/isa-l/archive/$ISAL_SRC_ARCHIVE

# APACHE HADOOP SCRIPT VARIABLES
ARG HADOOP_VERSION
ENV HADOOP_ARCHIVE=hadoop-$HADOOP_VERSION-src.tar.gz
ENV HADOOP_ARCHIVE_URL https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/$HADOOP_ARCHIVE
ENV HADOOP_ASC_URL $HADOOP_ARCHIVE_URL.asc
ENV HADOOP_KEYS https://archive.apache.org/dist/hadoop/core/KEYS

# Install dependencies
RUN \
    yum -y update \
    && yum -y install \
        wget \
        make \
        gcc \
        gcc-c++ \
        gawk \
        kernel-devel \
        autoconf \
        automake \
        libtool \
        cmake \
        zlib-devel \
        pkgconfig \
        openssl-devel \
        snappy-devel \
        bzip2 \
        bzip2-devel \
        jansson-devel \
        fuse-devel \
	&& yum clean all

# Hadoop sources
RUN \
	wget $HADOOP_ARCHIVE_URL \
	&& wget $HADOOP_ASC_URL \
	&& wget $HADOOP_KEYS \
	&& gpg --import KEYS \
	&& gpg --verify $HADOOP_ARCHIVE.asc \
	&& mkdir /opt/hadoop \
	&& tar xvf $HADOOP_ARCHIVE -C /opt/hadoop \
	&& rm -f $HADOOP_ARCHIVE \
	&& rm -f $HADOOP_ARCHIVE.asc \
	&& rm -f KEYS \
	&& ln -s /opt/hadoop/*hadoop* /opt/hadoop/default
	
# Google Protocol Buffers
WORKDIR /tmp
RUN \
    wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz \
    && tar xzf protobuf-2.5.0.tar.gz \
    && rm -f protobuf-2.5.0.tar.gz \
    && cd protobuf-2.5.0 \
    && ./configure --prefix=/usr --libdir=/usr/lib64 && make \
    && make install \
    && rm -rf ../protobuf-2.5.0

# YASM
WORKDIR /tmp
RUN \
    wget $YASM_DOWNLOAD_LINK \
    && tar xzf $YASM_SRC_ARCHIVE \
    && rm -f $YASM_SRC_ARCHIVE \
    && cd yasm-$YASM_VERSION \
    && sed -i 's#) ytasm.*#)#' Makefile.in \
    && ./configure --prefix=/usr --libdir=/usr/lib64 \
    && make \
    && make install \
    && rm -rf ../yasm-$YASM_VERSION
    
# INTEL ISA-L
WORKDIR /tmp
RUN \
    wget $ISAL_DOWNLOAD_LINK \
    && tar xzf $ISAL_SRC_ARCHIVE \
    && rm -f $ISAL_SRC_ARCHIVE \
    && cd isa-l-$ISAL_VERSION \
    && ./autogen.sh \
    && ./configure --prefix=/usr --libdir=/usr/lib64 \
    && make \
    && make install \
    && rm -rf ../isa-l-$ISAL_VERSION

VOLUME ["/opt/hadoop/default/hadoop-dist/target"]

# The container starts the build when it's run
COPY entrypoint.sh /
WORKDIR /opt/hadoop/default
CMD ["bash", "/entrypoint.sh"]
