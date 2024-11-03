FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk wget curl ssh net-tools vim netcat && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin

# Set Hadoop users
ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

# Create .bashrc with environment settings
RUN echo "# Java" >> ~/.bashrc && \
    echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bashrc && \
    echo "" >> ~/.bashrc && \
    echo "# Hadoop" >> ~/.bashrc && \
    echo "export HADOOP_HOME=/usr/local/hadoop" >> ~/.bashrc && \
    echo "export PATH=\$PATH:\$HADOOP_HOME/bin" >> ~/.bashrc && \
    echo "export PATH=\$PATH:\$HADOOP_HOME/sbin" >> ~/.bashrc && \
    echo "export HADOOP_MAPRED_HOME=\${HADOOP_HOME}" >> ~/.bashrc && \
    echo "export HADOOP_COMMON_HOME=\${HADOOP_HOME}" >> ~/.bashrc && \
    echo "export HADOOP_HDFS_HOME=\${HADOOP_HOME}" >> ~/.bashrc && \
    echo "export YARN_HOME=\${HADOOP_HOME}" >> ~/.bashrc && \
    echo "" >> ~/.bashrc && \
    echo "# Spark" >> ~/.bashrc && \
    echo "export SPARK_HOME=/usr/local/spark" >> ~/.bashrc && \
    echo "export PATH=\$PATH:\$SPARK_HOME/bin" >> ~/.bashrc

# Set up SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# Install Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz && \
    tar -xzf hadoop-3.3.3.tar.gz && \
    mv hadoop-3.3.3 /usr/local/hadoop && \
    rm hadoop-3.3.3.tar.gz

# Install Spark
RUN wget https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz && \
    tar -xzvf spark-3.5.0-bin-hadoop3.tgz && \
    mv spark-3.5.0-bin-hadoop3 /usr/local/spark && \
    rm spark-3.5.0-bin-hadoop3.tgz

# Create necessary directories
RUN mkdir -p /hadoop_data/namenode && \
    mkdir -p /hadoop_data/datanode && \
    mkdir -p /usr/local/hadoop/logs && \
    chmod -R 777 /hadoop_data && \
    chmod -R 777 /usr/local/hadoop/logs

# Copy configurations
COPY hadoop-config/* /usr/local/hadoop/etc/hadoop/
COPY spark-config/* /usr/local/spark/conf/

# Copy initialization script
COPY init-services.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-services.sh

# Expose ports
EXPOSE 9870 8088 4040 9000

WORKDIR /usr/local

# Set the default command
CMD ["/usr/local/bin/init-services.sh"]