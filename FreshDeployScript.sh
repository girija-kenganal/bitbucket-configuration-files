#!/bin/bash

echo "############################ ****************** ############################"
echo "############################ BRINGING DOWN EVERYTHING ########################"
echo "############################ ****************** ############################"

echo "NOTE: This Script will only deploy CURRENT BUILD associated with task definititon of ECS TESDRM-COM Cluster"

sleep 5

echo "INCLUDE STEP TO REMOVE FILES"


echo "STOPPING ROUTER, RMS, VIEWER"
aws ecs update-service --cluster WWW-SKYDRM-COM --service router-WWW-SKYDRM-COM --desired-count 0 --region=us-east-1
sleep 10
aws ecs update-service --cluster WWW-SKYDRM-COM --service rms-WWW-SKYDRM-COM --desired-count 0  --region=us-east-1
sleep 10
aws ecs update-service --cluster WWW-SKYDRM-COM --service viewer-WWW-SKYDRM-COM --desired-count 0 --region=us-east-1
sleep 10


ViewerContainerId=$(docker ps | grep 'ecs-viewer-WWW-SKYDRM-COM' | awk '{ print $1 }')
docker stop $ViewerContainerId  && docker rm $ViewerContainerId
RouterContainerId=$(docker ps | grep 'ecs-router-WWW-SKYDRM-COM' | awk '{ print $1 }')
docker stop $RouterContainerId && docker rm $RouterContainerId
RMSContainerId=$(docker ps | grep 'ecs-rms-WWW-SKYDRM-COM' | awk '{ print $1 }')
docker stop $RMSContainerId && docker rm $RMSContainerId


echo "Delete the CC agent file, must keep the temp_agent-keystore.jks file"
sudo rm -rf /mnt/efs/WWW-SKYDRM-COM/conf/cert/agent-*
sudo rm -rf /mnt/efs/WWW-SKYDRM-COM/conf/tenants
sudo rm -rf /mnt/efs/WWW-SKYDRM-COM/logs/*
sudo rm -rf /mnt/efs/WWW-SKYDRM-COM/agent.dat


echo "CLEANED DIRECTORIES"

sleep 10


echo "COMMENTING OUT TENANT NAME FROM router.properties file"
sed -i "s/web.publicTenant=www.skydrm.com/#web.publicTenant=www.skydrm.com/g" /mnt/efs/WWW-SKYDRM-COM/conf/router.properties


sleep 10

echo "STOPPING CACHE SERVER"

aws ecs update-service --cluster WWW-SKYDRM-COM --service cache-WWW-SKYDRM-COM --desired-count 0 --region=us-east-1

sleep 20

echo "CLEARING CONTENT OF CACHE SERVER"
sudo rm -rfv /mnt/efs/WWW-SKYDRM-COM/cachestore/*

sleep 10

echo "STOPPING MESSAGE QUEU -->>>>>>>>>>>>>>>>>>>>>>>"
aws ecs update-service --cluster WWW-SKYDRM-COM --service message-WWW-SKYDRM-COM --desired-count 0 --region=us-east-1

sleep 10

messageContainerId=$(docker ps | grep 'ecs-message-WWW-SKYDRM-COM' | awk '{ print $1 }')
docker stop $messageContainerId && docker rm $messageContainerId

sudo chmod 777 -R /mnt/efs/WWW-SKYDRM-COM/

echo "############################ ****************** ############################"
echo "############################ BRINGING UP EVERYTHING ########################"
echo "############################ ****************** ############################"

echo "############################ Remove all stopped containers #################"
docker container prune -f
docker volume rm $(docker volume list -q)


sleep 120

echo "CACHE SERVER COMING UP -->>>>>>>>>>"
aws ecs update-service --cluster WWW-SKYDRM-COM --service cache-WWW-SKYDRM-COM --desired-count 1 --region=us-east-1


echo "SLEEPING FOR 10 Secs, Waiting till cache server scale down"

sleep 3
echo "MESSAGE QUEUE SERVER COMING UP -->>>>>>>>>>"
aws ecs update-service --cluster WWW-SKYDRM-COM --service message-WWW-SKYDRM-COM --desired-count 1 --region=us-east-1


echo "BRINGING UP ROUTER, RMS, VIEWER"
aws ecs update-service --cluster WWW-SKYDRM-COM --service router-WWW-SKYDRM-COM --desired-count 1 --region=us-east-1
sleep 10
aws ecs update-service --cluster WWW-SKYDRM-COM --service rms-WWW-SKYDRM-COM --desired-count 1 --region=us-east-1
sleep 10
aws ecs update-service --cluster WWW-SKYDRM-COM --service viewer-WWW-SKYDRM-COM --desired-count 1 --region=us-east-1

sleep 5

echo "END ******* CHECK ECS-CLUSTER NAMED WWW-SKYDRM-COM TO CHECK STATUS OF SERVICES ******** "

sudo chmod 777 -R /mnt/efs/WWW-SKYDRM-COM/

echo sleep 10
