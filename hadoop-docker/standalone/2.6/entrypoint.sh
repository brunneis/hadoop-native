#!/bin/bash

# Start SSH server
/usr/sbin/sshd -D &

# Format NameNode
rm /tmp/*.pid

# Start Hadoop services
start-dfs.sh
start-yarn.sh

bash --login -i
