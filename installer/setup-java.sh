#!/bin/bash

function setup_java
{
  print_green "Setting up JAVA"
  apt_get_update
  apt_get_install default-jre default-jdk

  TARGET_PROFILE="$HOME/.zshrc"

  if ! [[ -f $TARGET_PROFILE ]]
  then
    TARGET_PROFILE="$HOME/.bashrc"
  fi

  # JAVA HOME
  if ! grep -q 'export JAVA_HOME' "$TARGET_PROFILE"
  then 
    echo 'export JAVA_HOME=/usr/lib/jvm/default-java' >> "$TARGET_PROFILE"
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$TARGET_PROFILE"
  fi

}

function setup_spark
{
  local SPARK_VERSION="3.5.0"
  local HADOOP_VERSION="3"
  print_green "Setting up Spark $SPARK_VERSION with hadoop $HADOOP_VERSION"
  setup_java
  apt_get_install scala
  if [[ ! -f "spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz" ]]
  then
    wget "https://dlcdn.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz"
    tar xf spark-*
  fi
  
  echo $SUDO_PASSWORD | sudo -S mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION /opt/spark
  rm -rf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz
  
  TARGET_PROFILE="$HOME/.zshrc"

  if ! [[ -f $TARGET_PROFILE ]]
  then
    TARGET_PROFILE="$HOME/.bashrc"
  fi

  if ! grep -q 'export SPARK_HOME' "$TARGET_PROFILE"
  then 
    echo 'export SPARK_HOME=/opt/spark' >> "$TARGET_PROFILE"
    echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> "$TARGET_PROFILE"
    echo 'export PYSPARK_PYTHON=/usr/bin/python3' >> "$TARGET_PROFILE"
  fi

}

function setup_maven
{
  apt_get_install maven
}

function setup_kafka
{
  # https://www.linuxtechi.com/how-to-install-apache-kafka-on-ubuntu/
  local KAFKA_VERSION="3.5.0"
  print_green "Setting up KAFKA $KAFKA_VERSION"
  setup_java

  if [[ ! -f "kafka_2.13-$KAFKA_VERSION.tgz" ]]
  then
    wget "https://dlcdn.apache.org/kafka/$KAFKA_VERSION/kafka_2.13-$KAFKA_VERSION.tgz"
    tar xf kafka*
  fi
  
  echo $SUDO_PASSWORD | sudo -S mv kafka_2.13-$KAFKA_VERSION /usr/local/kafka
  rm -rf kafka_2.13-$KAFKA_VERSION.tgz

  echo $SUDO_PASSWORD | sudo -S cp etc/kafka/zookeeper.service > /etc/systemd/system/zookeeper.service  
  echo $SUDO_PASSWORD | sudo -S cp etc/kafka/kafka.service > /etc/systemd/system/kafka.service

  echo $SUDO_PASSWORD | sudo -S sudo systemctl daemon-reload
  echo $SUDO_PASSWORD | sudo -S systemctl start zookeeper
  echo $SUDO_PASSWORD | sudo -S systemctl start kafka

  
  # TARGET_PROFILE="$HOME/.zshrc"

  # if ! [[ -f $TARGET_PROFILE ]]
  # then
  #   TARGET_PROFILE="$HOME/.bashrc"
  # fi

  # if ! grep -q 'export SPARK_HOME' "$TARGET_PROFILE"
  # then 
  #   echo 'export SPARK_HOME=/opt/spark' >> "$TARGET_PROFILE"
  #   echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> "$TARGET_PROFILE"
  #   echo 'export PYSPARK_PYTHON=/usr/bin/python3' >> "$TARGET_PROFILE"
  # fi

}