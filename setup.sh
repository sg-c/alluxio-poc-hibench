#!/bin/bash

# get the source code
git clone https://github.com/Intel-bigdata/HiBench.git # clone HiBench repo
cd HiBench
git checkout v7.1

# build HiBench
mvn -Psparkbench \
    -Dmodules -Pmicro \
    -Dspark.version=2.4.8 -Dscala=2.11 \
    clean package # build spark 2.4.8, scala 2.11, micro workload into a module

# configure hadoop

export HADOOP_HOME=/tmp/hadoop                 # UPDATE ME
export HADOOP_EXEC=$HADOOP_HOME/bin/hadoop     # UPDATE ME
export HADOOP_CONF=$HADOOP_HOME/etc/hadoop     # UPDATE ME
export HDFS_MASTER=hdfs://$(hostname -i):9000 # UPDATE ME

cp conf/hadoop.conf.template conf/hadoop.conf

sed -i "s|hibench.hadoop.home.*|hibench.hadoop.home $HADOOP_HOME|g" conf/hadoop.conf
sed -i "s|hibench.hadoop.executable.*|hibench.hadoop.executable $HADOOP_EXEC|g" conf/hadoop.conf
sed -i "s|hibench.hadoop.configure.dir.*|hibench.hadoop.configure.dir $HADOOP_CONF|g" conf/hadoop.conf
sed -i "s|hibench.hdfs.master.*|hibench.hdfs.master $HDFS_MASTER|g" conf/hadoop.conf

# configure spark
cp conf/spark.conf.template conf/spark.conf

export SPARK_HOME=/tmp/spark
export SPARK_MASTER=spark://$(hostname -i):7077

sed -i "s|hibench.spark.home.*|hibench.spark.home $SPARK_HOME|g" conf/spark.conf
sed -i "s|hibench.spark.master.*|hibench.spark.master $SPARK_MASTER|g" conf/spark.conf

# configure hibench
export SCALE_FACTOR=small # values could be tiny(KB),small(100sMB),large(GB),huge(10sGB),gigantic(100sGB),bigdata(TB)
sed -i "s|hibench.scale.profile.*|hibench.scale.profile small|g" conf/hibench.conf

# tunning
echo "to tune..."

# run
bin/workloads/micro/wordcount/prepare/prepare.sh
bin/workloads/micro/wordcount/spark/run.sh

# report
cat 