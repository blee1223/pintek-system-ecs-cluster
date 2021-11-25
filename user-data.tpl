#!/bin/bash -ex

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo Begin: user-data

echo Begin: update and install packages
yum update -y
echo End: update and install packages

echo Begin: start ECS
cluster="${cluster_name}"
echo ECS_CLUSTER=$cluster >> /etc/ecs/ecs.config
echo End: start ECS

echo End: user-data
