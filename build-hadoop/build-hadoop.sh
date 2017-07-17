#!/bin/bash
mkdir build
docker run -ti -v $(pwd)/build:/opt/hadoop/default/hadoop-dist/target:Z brunneis/hadoop-builder
