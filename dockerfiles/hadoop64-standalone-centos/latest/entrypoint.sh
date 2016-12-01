#!/bin/bash

# Start SSH server
/usr/sbin/sshd -D &

# Format NameNode and start Hadoop services
hdfs namenode -format
start-dfs.sh
start-yarn.sh

bash --login -i
