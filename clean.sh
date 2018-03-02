#!/bin/bash

docker kill node-1
docker kill node-2
docker kill client

docker rm node-1
docker rm node-2
docker rm client

docker network rm priss

