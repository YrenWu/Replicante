#!/bin/bash

docker network create --subnet=172.18.0.0/16 priss

docker build Node1 -t node1
docker build Node2 -t node2

docker run --privileged -d --name node-1 --net priss --ip 172.18.0.10 node1
docker run --privileged -d --name node-2 --net priss --ip 172.18.0.20 node2
