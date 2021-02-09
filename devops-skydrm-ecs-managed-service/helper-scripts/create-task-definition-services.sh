#!/bin/bash


# Create cloudwatch log group
aws logs create-log-group --log-group-name /ecs/cache-WWW-SKYDRM-COM --region us-east-1 --profile skydrm
aws logs create-log-group --log-group-name /ecs/message-$ECS_CLUSTER_NAME --region us-east-1
aws logs create-log-group --log-group-name /ecs/db-$ECS_CLUSTER_NAME --region us-east-1
aws logs create-log-group --log-group-name /ecs/rms-$ECS_CLUSTER_NAME --region us-east-1
aws logs create-log-group --log-group-name /ecs/router-$ECS_CLUSTER_NAME --region us-east-1
aws logs create-log-group --log-group-name /ecs/viewer-$ECS_CLUSTER_NAME --region us-east-1

# Create task definition

aws ecs register-task-definition --cli-input-json file://td-viewer.json  --region $REGION --profile skydrm
aws ecs register-task-definition --cli-input-json file://td-router.json  --region $REGION
aws ecs register-task-definition --cli-input-json file://td-rms.json  --region $REGION
aws ecs register-task-definition --cli-input-json file://td-cache.json  --region $REGION
aws ecs register-task-definition --cli-input-json file://td-message.json  --region $REGION
aws ecs register-task-definition --cli-input-json file://td-db.json  --region $REGION

# create Route 53 entry

# Create Target Group 

# Create application load balancer

## Apply wait condition


# Connect load balancer's A Record to to Route 53


# Create services
aws ecs create-service --cluster $ECS_CLUSTER_NAME --service-name message-$ECS_CLUSTER_NAME --cli-input-json file://service-message.json  --region us-east-1
aws ecs create-service --cluster $ECS_CLUSTER_NAME --service-name cache-$ECS_CLUSTER_NAME --cli-input-json file://service-cache.json  --region us-east-1
aws ecs create-service --cluster $ECS_CLUSTER_NAME --service-name db-$ECS_CLUSTER_NAME --cli-input-json file://service-db.json  --region us-east-1