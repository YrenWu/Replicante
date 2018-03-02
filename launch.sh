#!/bin/bash

docker network create --subnet=172.66.0.0/16 priss

docker build Node1 -t node1
docker build Node2 -t node2

# cluster servers
docker run --privileged -d --device /dev/fuse --name node-1 --net priss --ip 172.66.0.10 node1
docker run --privileged -d --device /dev/fuse --name node-2 --net priss --ip 172.66.0.20 node2

# client glusterFS
docker run --privileged -d --device /dev/fuse --name client --net priss --ip 172.66.0.15 picoded/glusterfs-client 
