#!/bin/bash

docker network create --subnet=172.18.0.0/16 priss

docker build Node1 -t node1
docker build Node2 -t node2

docker run --privileged -d --name node-1 --net priss --ip 172.18.0.10 node1
docker run --privileged -d --name node-2 --net priss --ip 172.18.0.20 node2



# Error response from daemon: cannot create network 59311db0203b7decee2e6ec31ac72de91aa29b69401b19de780246f76aaa3473 (br-59311db0203b): conflicts with network b7f26df0e17ee9b075d0e010ea3ed099356227bb54ddbad9af01cb390abb3e52 (br-b7f26df0e17e): networks have overlapping IPv4
# Sending build context to Docker daemon  2.048kB

# docker: Error response from daemon: Conflict. The container name "/node-1" is already in use by container "b1129daaa57a4c2138d543442bdc407f114f13459dde37287dfe4538868c3139". You have to remove (or rename) that container to be able to reuse that name.
# See 'docker run --help'.

# docker: Error response from daemon: network priss not found.



# docker kill node-1
# docker kill node-2
# docker rm node-1
# docker rm node-2
# docker network rm priss