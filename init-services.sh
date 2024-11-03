#!/bin/bash

# Source environment
source ~/.bashrc

# Function to wait for service
wait_for_service() {
    local port=$1
    local service=$2
    echo "Waiting for $service to start..."
    while ! nc -z localhost $port; do
        sleep 1
    done
    echo "$service is ready!"
}

# Ensure JAVA_HOME is set in hadoop-env.sh
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Start SSH service
service ssh start
ssh-keyscan localhost >> ~/.ssh/known_hosts
ssh-keyscan 0.0.0.0 >> ~/.ssh/known_hosts
ssh-keyscan namenode >> ~/.ssh/known_hosts

echo "Starting Hadoop services..."

# Format namenode if not already formatted
if [ ! -f "/hadoop_data/formatted" ]; then
    echo "Formatting namenode..."
    $HADOOP_HOME/bin/hdfs namenode -format
    touch /hadoop_data/formatted
fi

# Start HDFS
$HADOOP_HOME/sbin/start-dfs.sh
wait_for_service 9870 "HDFS"

# Create necessary HDFS directories
echo "Creating HDFS directories..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -chmod g+w /tmp

# Start YARN
echo "Starting YARN..."
$HADOOP_HOME/sbin/start-yarn.sh
wait_for_service 8088 "YARN"

# Print startup message
echo "
==============================================
Big Data Environment Started
==============================================
Services:
- Hadoop NameNode: http://localhost:9870
- YARN Resource Manager: http://localhost:8088
==============================================
"

# Keep container running and show logs
tail -f /usr/local/hadoop/logs/*log