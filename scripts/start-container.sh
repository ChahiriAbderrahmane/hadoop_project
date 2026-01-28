#!/bin/bash

# Créer un réseau Docker privé pour Hadoop
sudo docker network create --driver=bridge hadoop &> /dev/null

# Nombre total de nœuds (master + 3 slaves)
N=4  # 1 master + 3 slaves

# --- START MASTER ---
sudo docker rm -f hadoop-master &> /dev/null
echo "Start hadoop-master container..."
sudo docker run -itd \
    --net=hadoop \
    -p 50070:50070 \    # HDFS Web UI
    -p 8088:8088 \      # YARN Web UI
    --name hadoop-master \
    --hostname hadoop-master \
    hadoop:latest &> /dev/null

# --- START SLAVES ---
i=1
while [ $i -lt $N ]
do
    sudo docker rm -f hadoop-slave$i &> /dev/null
    echo "Start hadoop-slave$i container..."
    sudo docker run -itd \
        --net=hadoop \
        --name hadoop-slave$i \
        --hostname hadoop-slave$i \
        hadoop:latest &> /dev/null
    i=$((i+1))
done

# --- Accès au master ---
sudo docker exec -it hadoop-master bash
