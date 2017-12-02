#!/bin/bash

docker kill node-1
docker kill node-2
docker rm node-1
docker rm node-2
docker network rm priss