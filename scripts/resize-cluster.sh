#!/bin/bash

# ----------------------------
# CONFIGURATION
# ----------------------------

# Nombre total de nœuds : 1 master + 3 slaves
N=4  # 1 master + 3 slaves

# Nom de l'image Docker Hadoop
IMAGE_NAME="hadoop:latest"

# Réseau Docker pour le cluster
NETWORK_NAME="hadoop"

# ----------------------------
# 1️⃣ Création du réseau Docker
# ----------------------------
sudo docker network create --driver=bridge $NETWORK_NAME &> /dev/null

# ----------------------------
# 2️⃣ Génération du fichier slaves
# ----------------------------
rm -f config/slaves
i=1
while [ $i -lt $N ]
do
    echo "hadoop-slave$i" >> config/slaves
    ((i++))
done
echo "Fichier config/slaves généré :"
cat config/slaves
echo ""

# ----------------------------
# 3️⃣ Build de l'image Docker Hadoop
# ----------------------------
echo "Construction de l'image Docker Hadoop..."
sudo docker build -t $IMAGE_NAME .
echo ""

# ----------------------------
# 4️⃣ Démarrage du master
# ----------------------------
sudo docker rm -f hadoop-master &> /dev/null
echo "Démarrage du conteneur hadoop-master..."
sudo docker run -itd \
    --net=$NETWORK_NAME \
    -p 50070:50070 \   # HDFS UI
    -p 8088:8088 \     # YARN UI
    --name hadoop-master \
    --hostname hadoop-master \
    $IMAGE_NAME &> /dev/null
echo ""

# ----------------------------
# 5️⃣ Démarrage des slaves
# ----------------------------
i=1
while [ $i -lt $N ]
do
    sudo docker rm -f hadoop-slave$i &> /dev/null
    echo "Démarrage du conteneur hadoop-slave$i..."
    sudo docker run -itd \
        --net=$NETWORK_NAME \
        --name hadoop-slave$i \
        --hostname hadoop-slave$i \
        $IMAGE_NAME &> /dev/null
    ((i++))
done
echo ""

# ----------------------------
# 6️⃣ Accès au master
# ----------------------------
echo "Accès au master Hadoop..."
sudo docker exec -it hadoop-master bash
