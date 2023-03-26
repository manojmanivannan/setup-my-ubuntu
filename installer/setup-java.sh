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
  if [[ "$(grep -q 'export JAVA_HOME' $TARGET_PROFILE)" -eq 1 ]]
  then 
    echo 'export JAVA_HOME=/usr/lib/jvm/default-java' >> "$TARGET_PROFILE"
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$TARGET_PROFILE"
  fi

}

function setup_spark
{
  local SPARK_VERSION="3.3.2"
  local HADOOP_VERSION="3"
  print_green "Setting up Spark $SPARK_VERSION with hadoop $HADOOP_VERSION"
  setup_java
  apt_get_install scala
  if [[ ! -f "spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz" ]]
  then
    wget "https://dlcdn.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz"
  fi
  tar xf spark-*
  echo $SUDO_PASSWORD | sudo -S mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION /opt/spark
  rm -rf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz
  
  TARGET_PROFILE="$HOME/.zshrc"

  if ! [[ -f $TARGET_PROFILE ]]
  then
    TARGET_PROFILE="$HOME/.bashrc"
  fi

  if [[ "$(grep -q 'export SPARK_HOME' $TARGET_PROFILE)" -eq 1 ]]
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