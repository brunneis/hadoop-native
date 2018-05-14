#!/bin/bash
docker build --build-arg HADOOP_VERSION=$(cat HADOOP_VERSION) -t brunneis/hadoop-builder .
rm -rf build
mkdir build
docker run -ti -v $(pwd)/build:/opt/hadoop/default/hadoop-dist/target:Z brunneis/hadoop-builder
