#!/bin/bash
set -x

AWS_PROFILE="--profile devops"

# FORM CLUSTER NAME (MAKE UPPER CASE) AND REPLACE . with -
CAPITAL_SUB_DOMAIN_NAME=$(echo "$SUB_DOMAIN_NAME" | sed "s/\./-/g" | tr a-z A-Z )
CAPITAL_DOMAIN=$(echo "$DOMAIN_NAME" | sed "s/\./-/g" | tr a-z A-Z )

ECS_CLUSTER_NAME=$CAPITAL_SUB_DOMAIN_NAME-$CAPITAL_DOMAIN
lowerCaseClusterName=$(echo "$ECS_CLUSTER_NAME" | tr A-Z a-z )

WEB_PUBLICTETANT=$(echo "$ECS_CLUSTER_NAME" | sed "s/\-/./g" | tr A-Z a-z )

# to change USER DATA SECTION OF TEMPLATE
sed -i "s/ECS_CLUSTER_NAME/$ECS_CLUSTER_NAME/g" cf-templates/master.yml

sed -i "s/ECS_CLUSTER_NAME/$ECS_CLUSTER_NAME/g" helper-scripts/ec2-user-data.sh

# PREPARE TASK DEFINITION FILES
sed -i "s/ECS_CLUSTER_NAME/$ECS_CLUSTER_NAME/g" task-definition/*.json
sed -i "s/REGION/$REGION/g" task-definition/*.json

# PREPARE SERVICE FILES
sed -i "s/ECS_CLUSTER_NAME/$ECS_CLUSTER_NAME/g" service/*.json

# REPLACE PARAMETER FILE VALUES

sed -i "s/DOMAIN_NAME/$DOMAIN_NAME/g" cf-templates/parameter-file.json
sed -i "s/SUB_DOMAIN_NAME/$SUB_DOMAIN_NAME/g"  cf-templates/parameter-file.json
sed -i "s/EC2_KEY_PAIR_NAME/$EC2_KEY_PAIR_NAME/g"  cf-templates/parameter-file.json
sed -i "s/VPC_ID/$VPC_ID/g"  cf-templates/parameter-file.json
sed -i "s/PUBLIC_SUBNET_ID_ONE/$PUBLIC_SUBNET_ID_ONE/g"  cf-templates/parameter-file.json
sed -i "s/PUBLIC_SUBNET_ID_TWO/$PUBLIC_SUBNET_ID_TWO/g"  cf-templates/parameter-file.json
sed -i "s/PRIVATE_SUBNET_ID_TWO/$PRIVATE_SUBNET_ID_TWO/g"  cf-templates/parameter-file.json
sed -i "s/PRIVATE_SUBNET_ID_ONE/$PRIVATE_SUBNET_ID_ONE/g"  cf-templates/parameter-file.json
sed -i "s/ALB_SSL_CERT_ARN/$ALB_SSL_CERT_ARN/g"  cf-templates/parameter-file.json
sed -i "s/INSTANCE_TYPE/$INSTANCE_TYPE/g"  cf-templates/parameter-file.json
sed -i "s/EC2_VOLUME_TYPE/$EC2_VOLUME_TYPE/g"  cf-templates/parameter-file.json
sed -i "s/EC2_VOLUME_SIZE/$EC2_VOLUME_SIZE/g"  cf-templates/parameter-file.json
sed -i "s/PUBLIC_HOSTED_ZONE_ID/$PUBLIC_HOSTED_ZONE_ID/g"  cf-templates/parameter-file.json
sed -i "s/FILE_SYSTEM_ID/$FILE_SYSTEM_ID/g"  cf-templates/parameter-file.json
sed -i "s/BASTION_SEC_GROUP_ID/$BASTION_SEC_GROUP_ID/g"  cf-templates/parameter-file.json
sed -i "s/SKYDRM_BUILD_NO/$SKYDRM_BUILD_NO/g"  cf-templates/parameter-file.json
sed -i "s/WEB_ICENET_URL/$WEB_ICENET_URL/g"  cf-templates/parameter-file.json
sed -i "s/WEB_CC_CONSOLE_URL/$WEB_CC_CONSOLE_URL/g"  cf-templates/parameter-file.json
sed -i "s/CC_VERSION/$CC_VERSION/g"  cf-templates/parameter-file.json
sed -i "s/VPC_ENDPOINT_ID/$VPC_ENDPOINT_ID/g"  cf-templates/parameter-file.json


# PACKAGE AND PUBLIC CONFIG FILES TO S3 
echo ">>>>>>> ################ <<<<<<<<<<<<"
echo "------------ PUBLISH CONFIG FILES TO S3 ${ECS_CLUSTER_NAME}-config.zip --------------"






sed -i "s/AWS_ACCOUNT_NO/$AWS_ACCOUNT_NO/g" config/conf/*.properties

sed -i "s/WEB_PUBLICTETANT/$WEB_PUBLICTETANT/g" config/conf/*.properties

sed -i "s/FACEBOOK_APP_ID/$FACEBOOK_APP_ID/g" config/conf/*.properties
sed -i "s/FACEBOOK_SECRET/$FACEBOOK_SECRET/g" config/conf/*.properties

sed -i "s/GOOGLE_APP_ID/$GOOGLE_APP_ID/g" config/conf/*.properties
sed -i "s/GOOGLE_SECRET/$GOOGLE_SECRET/g" config/conf/*.properties


sed -i "s/MYSPACE_S3_BUCKET/$lowerCaseClusterName-myspace/g" config/conf/*.properties
sed -i "s/PROJECT_S3_BUCKET/$lowerCaseClusterName-projects/g" config/conf/*.properties

sed -i "s/WEB_CACHING_SERVER_HOST/cache.$WEB_PUBLICTETANT/g" config/conf/*.properties
sed -i "s/WEB_RABBITMQ_API_HOST/message.$WEB_PUBLICTETANT/g" config/conf/*.properties

sed -i "s/DB_HOST/db.$WEB_PUBLICTETANT/g" config/conf/*.properties

sed -i "s/WEB_ICENET_URL/$WEB_ICENET_URL/g" config/conf/*.properties
sed -i "s/WEB_CC_CONSOLE_URL/$WEB_CC_CONSOLE_URL/g" config/conf/*.properties

sed -i "s/WEB_COOKIE_DOMAIN/$WEB_PUBLICTETANT/g" config/conf/*.properties
sed -i "s/CC_VERSION/$CC_VERSION/g" config/conf/*.properties



#ECS_CLUSTER_NAME=$1
#AWS_PROFILE=$2
#REGION=$3

# PUSH THE ABOVE ZIP TO DEVOPS ACCOUNT
zip -r ${ECS_CLUSTER_NAME}-config.zip config/*
aws s3 cp ${ECS_CLUSTER_NAME}-config.zip s3://nxtlbsrelease/${ECS_CLUSTER_NAME}-config.zip --profile $AWS_PROFILE --region $REGION



STACK_NAME=$(echo "$SUB_DOMAIN_NAME.$DOMAIN_NAME" | sed "s/\./-/g" | tr a-z A-Z )

echo "*********************************"
echo "STACK NAME:  $STACK_NAME >>>>"
echo "*********************************"

echo "Template CoPied to S3 bucket = cf-templates-proserv in Proserv Account >>>>"

echo ">>>>>>>>>>>>>> >>>> >>>>>> "

aws s3 cp cf-templates/master.yml s3://cf-templates-nextlabs/skydrm-ecs  --profile $AWS_PROFILE --region $REGION
aws s3 cp user-data.sh s3://cf-templates-nextlabs/skydrm-ecs  --profile $AWS_PROFILE --region $REGION


# delete existing stack and deploy new one 

echo "Template validation PASS >>>>"
echo ">>>>>>>>>>>>>> >>>> >>>>>> "

aws cloudformation validate-template --template-body file://cf-templates-nextlabs/skydrm-ecs/master.yml --profile $AWS_PROFILE --region $REGION

aws cloudformation delete-stack --stack-name $STACK_NAME --profile $AWS_PROFILE --region $REGION 
aws cloudformation create-stack --stack-name $STACK_NAME --template-url https://cf-templates-nextlabs.s3.amazonaws.com/skydrm-ecs/master.yml --parameters file://parameter-file.json --capabilities CAPABILITY_NAMED_IAM --profile $AWS_PROFILE --region $REGION

# for testing comment later
aws s3 cp cf-templates/master.yml s3://cf-templates-nextlabs/skydrm-ecs --profile devops --region us-east-1
aws s3 cp user-data.sh s3://cf-templates-nextlabs/skydrm-ecs  --profile devops --region us-east-1
aws cloudformation validate-template --template-body file://cf-templates-nextlabs/skydrm-ecs/master.yml --profile devops --region us-east-1
aws cloudformation delete-stack --stack-name devops-testdrm-com --profile devops --region us-east-1
aws cloudformation create-stack --stack-name devops-testdrm-com --template-url https://cf-templates-nextlabs.s3.amazonaws.com/skydrm-ecs/master.yml --parameters file://parameter-file.json --capabilities CAPABILITY_NAMED_IAM --profile devops --region us-east-1


echo " Template DEPLOYMENT SUCCESS >>>>"
echo " *********************************"
echo " ^^^ STACK IS BEING PROVISIONED >>> PLEASE WAIT >> "
sleep 30
echo " ^^^ STACK IS BEING PROVISIONED >>> PLEASE WAIT >>>>>>"
sleep 60
echo " ^^^ STACK IS BEING PROVISIONED >>> PLEASE WAIT >>>>>>>>> 60%"
sleep 60
echo " ^^^ STACK IS BEING PROVISIONED >>> PLEASE WAIT >>>>>>>>>>>>>>>>>>>> 90%"
sleep 60
echo " ^^^ STACK IS BEING PROVISIONED >>> PLEASE WAIT >>>>>>>>>>>>>>>>>>>>>>>  99%"

echo " -********** STACK DETAILS ********************************_"
echo " STACK URL : https://$SUB_DOMAIN_NAME.$DOMAIN_NAME/console "
echo " CC ADMIN USER NAME : Administrator "
echo " CC ADMIN PASSWORD : 123NextYear2020** "
echo "------------------------------------------------------------"
echo "-"
echo " ++++++++++++++ START TROUBLE SHOOTING -TIPS ++++++++++++++"
echo "1. SSH to EC2 and check the user data log (/var/log/cloud-init-output.log)"
echo "2. ps -aux | grep java and makes ure 2 processes are running"
echo "3. make sure hostname matches domain name , issue hostname command and compare output"
echo "4. CHECK LOAD BALANCER (TARGET GROUP) HEALTH CHECK [ UNDER INSTANCES ] >>> "
echo "5. Try to remove form Target group and Add again >>> "
echo " ++++++++++++++ END TROUBLE SHOOTING -TIPS ++++++++++++++"
echo "-"
echo "-"
echo "-------------------------------------------------------------"
echo " ||||||||||||| TO CONTRIBUTE: / ADD NEW ENHANCEMENTS |||||||||"
echo "-------------------------------------------------------------"

echo "CLONE REPOSITORY $ git clone https://nxl_kmanimarpan@bitbucket.org/nxtlbs-devops/devops-skydrm-cc-template.git "
echo "CHECKOUT THIS BRANCH $ git checkout -b proserv"
echo "ADD FILES $ git add ."
echo "COMMIT CHANGES $ git commit -am 'Commit Message' "
echo "CREATE PULL REQUEST"
echo "-------------------------------------------------------------"
echo "-"
echo "-"
echo " REMEMBER TO RESTRICT SSH ACCESS OF EC2 security group >>>>"