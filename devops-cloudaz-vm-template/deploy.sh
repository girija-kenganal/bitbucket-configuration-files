#!/bin/bash

sed -i "s/DOMAIN_NAME/$DOMAIN_NAME/g" parameter-file.json
sed -i "s/SUB_DOMAIN/$SUB_DOMAIN/g" parameter-file.json

sed -i "s/KEY_NAME/$EC2_KEY_PAIR_NAME/g" parameter-file.json
sed -i "s/VPC_ID/$VPC_ID/g" parameter-file.json
sed -i "s/PUBLIC_SUBNET_1A/$PUB_SUBNET_A_ID/g" parameter-file.json
sed -i "s/PUBLIC_SUBNET_1B/$PUB_SUBNET_B_ID/g" parameter-file.json

sed -i "s/INSTANCE_TYPE/$INSTANCE_TYPE/g" parameter-file.json
sed -i "s/EC2_VOLUME_TYPE/$EC2_VOLUME_TYPE/g" parameter-file.json
sed -i "s/EC2_VOLUME_SIZE/$EC2_VOLUME_SIZE/g" parameter-file.json
sed -i "s/PUBLIC_HOSTED_ZONE_ID/$PUBLIC_HOSTED_ZONE_ID/g" parameter-file.json



sed -i "s/SUB_DOMAIN.DOMAIN_NAME/$SUB_DOMAIN.$DOMAIN_NAME/g" CC_Template.yml


STACK_NAME=$(echo "$SUB_DOMAIN.$DOMAIN_NAME" | sed "s/\./-/g" | tr a-z A-Z )

echo "*********************************"
echo "STACK NAME:  $STACK_NAME >>>>"
echo "*********************************"

echo "Template CoPied to S3 bucket = cf-templates-proserv in Proserv Account >>>>"

echo ">>>>>>>>>>>>>> >>>> >>>>>> "

aws s3 cp CC_Template.yml s3://cf-templates-proserv  --profile proserv --region $REGION
aws s3 cp user-data.sh s3://cf-templates-proserv  --profile proserv --region $REGION
aws s3 cp cc_properties.json s3://cf-templates-proserv  --profile proserv --region $REGION

# delete existing stack and deploy new one 

echo "Template validation PASS >>>>"
echo ">>>>>>>>>>>>>> >>>> >>>>>> "

aws cloudformation validate-template --template-body file://CC_Template.yml --profile proserv --region $REGION

aws cloudformation delete-stack --stack-name $STACK_NAME --profile proserv --region $REGION 
aws cloudformation create-stack --stack-name $STACK_NAME --template-url https://cf-templates-proserv.s3.amazonaws.com/CC_Template.yml --parameters file://parameter-file.json --capabilities CAPABILITY_NAMED_IAM --profile proserv --region $REGION

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
echo " STACK URL : https://$SUB_DOMAIN.$DOMAIN_NAME/console "
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