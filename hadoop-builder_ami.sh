# hadoop-builder_ami.sh | Build Apache Hadoop with native libraries

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
# curl -fsSL https://[...]/hadoop-builder_ami.sh | sudo bash  #
###############################################################

# ORACLE JDK SCRIPT VARIABLES
# JDK_VERSION=1.7.0_79
# JDK_BIN_ARCHIVE=jdk-7u79-linux-x64.tar.gz
# JDK_DOWNLOAD_LINK=http://download.oracle.com/otn-pub/java/jdk/7u79-b15/$JDK_BIN_ARCHIVE
JDK_VERSION=1.8.0_74
JDK_BIN_ARCHIVE=jdk-8u74-linux-x64.tar.gz
JDK_DOWNLOAD_LINK=http://download.oracle.com/otn-pub/java/jdk/8u74-b02/$JDK_BIN_ARCHIVE
JDK_INSTALL_DIR=/opt/oracle/java

# APACHE MAVEN SCRIPT VARIABLES
MAVEN_VERSION=3.3.9
MAVEN_BIN_ARCHIVE=apache-maven-$MAVEN_VERSION-bin.tar.gz
MAVEN_DOWNLOAD_LINK=http://apache.rediris.es/maven/maven-3/$MAVEN_VERSION/binaries/$MAVEN_BIN_ARCHIVE
MAVEN_INSTALL_DIR=/opt/apache/maven

# YASM
YASM_VERSION=1.3.0
YASM_SRC_ARCHIVE=yasm-$YASM_VERSION.tar.gz
YASM_DOWNLOAD_LINK=http://www.tortall.net/projects/yasm/releases/$YASM_SRC_ARCHIVE

# INTEL ISA-L
ISAL_VERSION=2.15.0
ISAL_SRC_ARCHIVE=v$ISAL_VERSION.tar.gz
ISAL_DOWNLOAD_LINK=https://github.com/01org/isa-l/archive/$ISAL_SRC_ARCHIVE

# FINDBUGS SCRIPT VARIABLES
# FINDBUGS_VERSION=1.3.9
# FINDBUGS_INSTALLATION_DIR=/opt/findbugs
# FINDBUGS_BIN_ARCHIVE=findbugs-$FINDBUGS_VERSION.tar.gz
# FINDBUGS_DOWNLOAD_LINK=http://prdownloads.sourceforge.net/findbugs/$FINDBUGS_BIN_ARCHIVE

# APACHE HADOOP SCRIPT VARIABLES
HADOOP_VERSION=2.7.2
HADOOP_SRC_ARCHIVE=hadoop-$HADOOP_VERSION-src.tar.gz
HADOOP_DOWNLOAD_LINK=http://apache.rediris.es/hadoop/common/hadoop-$HADOOP_VERSION/$HADOOP_SRC_ARCHIVE
HADOOP_INSTALL_DIR=/opt/apache/hadoop

# APACHE HBASE SCRIPT VARIABLES
HBASE_VERSION=1.1.3
HBASE_BIN_ARCHIVE=hbase-$HBASE_VERSION-bin.tar.gz
HBASE_DOWNLOAD_LINK=http://apache.rediris.es/hbase/$HBASE_VERSION/$HBASE_BIN_ARCHIVE
HBASE_INSTALL_DIR=/opt/apache/hbase

# SYSTEM UPDATE AND BASIC DEPENDENCIES
yum -y update && yum -y install wget \
make gcc gcc-c++ gawk kernel-devel autoconf automake libtool cmake zlib-devel pkgconfig openssl-devel \
snappy-devel bzip2 bzip2-devel jansson-devel fuse-devel 

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

# APACHE MAVEN
echo -e 'Installing Maven...\n'
mkdir -p $MAVEN_INSTALL_DIR
cd $MAVEN_INSTALL_DIR
wget $MAVEN_DOWNLOAD_LINK
tar xzf $MAVEN_BIN_ARCHIVE
rm -f $MAVEN_BIN_ARCHIVE
ln -sf apache-maven-$MAVEN_VERSION current
echo 'export M2_HOME='$MAVEN_INSTALL_DIR'/current' > /etc/profile.d/apache-maven.sh
echo 'if ! echo $PATH | grep -q '$MAVEN_INSTALL_DIR'/current/bin ; then 
export PATH=$M2_HOME/bin:$PATH; fi' >> /etc/profile.d/apache-maven.sh
. /etc/profile.d/apache-maven.sh

# GOOGLE PROTOCOL BUFFERS 2.5.0
echo -e 'Installing ProtocolBuffer...\n'
cd
wget https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz
tar xzf protobuf-2.5.0.tar.gz
rm -f protobuf-2.5.0.tar.gz
cd protobuf-2.5.0
./configure --prefix=/usr --libdir=/usr/lib64 && make
make install
rm -rf ../protobuf-2.5.0

# YASM
echo -e 'Installing YASM...\n'
cd
wget $YASM_DOWNLOAD_LINK
tar xzf $YASM_SRC_ARCHIVE
rm -f $YASM_SRC_ARCHIVE
cd yasm-$YASM_VERSION
sed -i 's#) ytasm.*#)#' Makefile.in && \
./configure --prefix=/usr --libdir=/usr/lib64 && make
make install
rm -rf ../yasm-$YASM_VERSION

# INTEL ISA-L
echo -e 'Installing ISA-L...\n'
cd
wget $ISAL_DOWNLOAD_LINK
tar xzf $ISAL_SRC_ARCHIVE
rm -f $ISAL_SRC_ARCHIVE
cd isa-l-$ISAL_VERSION
./autogen.sh
./configure --prefix=/usr --libdir=/usr/lib64 && make 
make install
rm -rf ../isa-l-$ISAL_VERSION

# FINDBUGS
# echo -e 'Installing Findbugs...\n'
# mkdir $FINDBUGS_INSTALLATION_DIR
# cd $FINDBUGS_INSTALLATION_DIR
# wget $FINDBUGS_DOWNLOAD_LINK
# tar xzf $FINDBUGS_BIN_ARCHIVE
# rm -f $FINDBUGS_BIN_ARCHIVE
# ln -sf findbugs-$FINDBUGS_VERSION current
# echo 'export FINDBUGS_HOME='$FINDBUGS_INSTALLATION_DIR'/current' > /etc/profile.d/findbugs.sh
# . /etc/profile.d/findbugs.sh

# APACHE HADOOP
echo -e 'Compiling and installing Hadoop...\n'
mkdir -p $HADOOP_INSTALL_DIR
cd $HADOOP_INSTALL_DIR
wget $HADOOP_DOWNLOAD_LINK
tar xzf $HADOOP_SRC_ARCHIVE
rm -f $HADOOP_SRC_ARCHIVE
cd hadoop-${HADOOP_VERSION}-src
mvn package -Pdist,native -DskipTests -Dtar -Drequire.snappy -Drequire.openssl -Drequire.isal

echo "Done!"
exit
