#!/bin/bash
yum update -y
yum install -y aws-cli nc unzip amazon-efs-utils


echo ECS_CLUSTER=ECS_CLUSTER_NAME >> /etc/ecs/ecs.config

FILE_SYSTEM_ID=fs-755078f5
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AVAILABILITY_ZONE:0:-1}
MOUNT_POINT=/mnt/efs
mkdir -p ${MOUNT_POINT}
chown ec2-user:ec2-user ${MOUNT_POINT}
echo ${FILE_SYSTEM_ID}.efs.${REGION}.amazonaws.com:/ ${MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0 >> /etc/fstab
mount -a -t nfs4


DIR="/mnt/efs/ECS_CLUSTER_NAME/"

if [ -d "$DIR" ]; then
	echo "Config files already exists in ${DIR}..."
else
	# Take action if $DIR NOT exists. #
	echo "Installing config files in ${DIR}..."
  
	mkdir -p /mnt/efs/ECS_CLUSTER_NAME/

	# Pull Config files from S3 and Palce in /mnt/efs/ folder
	
	aws s3 cp s3://nextlabs-release/ECS_CLUSTER_NAME-config.zip /tmp
	unzip /tmp/ECS_CLUSTER_NAME-config.zip -d /tmp
	cp -a /tmp/config/* /mnt/efs/ECS_CLUSTER_NAME/
	rm -rf /tmp/ECS_CLUSTER_NAME-config.zip /tmp/config

	# Create empty folders
	mkdir -p /mnt/efs/ECS_CLUSTER_NAME/bkpkeys 
	mkdir -p /mnt/efs/ECS_CLUSTER_NAME/logs
	mkdir -p /mnt/efs/ECS_CLUSTER_NAME/cachestore/server

	chmod 777 -R /mnt/efs/ECS_CLUSTER_NAME/

	# HARDCODED FOR NOW
	CACHE_PRIVATE_DNS=cache.private-skydrm.com
	MESSAGE_PRIVATE_DNS=message.private-skydrm.com

	sed -i "s/WEB_CACHING_SERVER_HOSTNAME/$CACHE_PRIVATE_DNS/g" /mnt/efs/ECS_CLUSTER_NAME/conf/*.properties
	sed -i "s/WEB_RABBITMQ_API_HOST/$MESSAGE_PRIVATE_DNS/g" /mnt/efs/ECS_CLUSTER_NAME/conf/*.properties
	sed -i "s/WEB_RABBITMQ_MQ_HOST/$MESSAGE_PRIVATE_DNS/g" /mnt/efs/ECS_CLUSTER_NAME/conf/*.properties

fi


# check cache server port connectivity on 8000  echo $?  0 means success failure means 1
timeout 1 bash -c "cat < /dev/null > /dev/tcp/cache.private-skydrm.com/8000"
CACHE_REACHABILITY=$(echo $?)

if [[ $CACHE_REACHABILITY -eq 0 ]]
then
        echo "CACHE SERVER EXISTS >>>>>>>>>>"

else
        echo "CACHE SERVER NOT EXISTS >>>>>>>>>>>"

        aws ecs update-service --cluster ECS_CLUSTER_NAME --service cache-ECS_CLUSTER_NAME --desired-count 1 --region=us-east-1
        sleep 5
        aws ecs update-service --cluster ECS_CLUSTER_NAME --service cache-ECS_CLUSTER_NAME --desired-count 0 --region=us-east-1
        sleep 10

        # Start Cache Server
        CACHE_IMAGE_ID=$(docker images -q --filter 'reference=512169772597.dkr.ecr.us-east-1.amazonaws.com/jboss/infinispan-server*')

        docker run --name infinispan-server -d --restart always -p 8000:8000 -p 9990:9990 -v "/mnt/efs/ECS_CLUSTER_NAME/cache/:/opt/jboss/infinispan-server/standalone/configuration/skydrm/" -v "/mnt/efs/ECS_CLUSTER_NAME/cachestore/:/var/tmp/" $CACHE_IMAGE_ID standalone -c skydrm/infinispan_server.xml


fi
