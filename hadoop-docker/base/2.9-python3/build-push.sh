#!/bin/bash
HADOOP_VERSION=$(cat HADOOP_VERSION)
docker build --build-arg HADOOP_VERSION=$HADOOP_VERSION -t brunneis/hadoop-64-passive:$HADOOP_VERSION .
docker push brunneis/hadoop-64-passive:$HADOOP_VERSION
