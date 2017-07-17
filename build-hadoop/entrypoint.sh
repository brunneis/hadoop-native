#!/bin/bash
mvn package -Pdist,native -DskipTests -Dtar -Drequire.snappy -Drequire.openssl -Drequire.isal
chmod -R 666 hadoop-dist/target/*
