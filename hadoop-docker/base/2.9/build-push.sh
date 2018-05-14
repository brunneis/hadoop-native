#!/bin/bash
HADOOP_VERSION=$(cat HADOOP_VERSION)
docker build --build-arg HADOOP_VERSION=$HADOOP_VERSION -t brunneis/hadoop-x86-64-base:$HADOOP_VERSION .
docker push brunneis/hadoop-x86-64-base:$HADOOP_VERSION
