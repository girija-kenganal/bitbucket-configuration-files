#!/bin/bash
#Put all scripts in nxtlbrelease - aws cp s3://nxtlbrelease/InstallationScript
echo "############################ ****************** ############################"
echo "############################ ****************** ############################"

echo "SET HOSTNAME TO THE CORRECT URL NAME TO ACCESS FROM NETWORK"
sudo hostnamectl set-hostname 92cc.nextlabs.solutions
#sudo vi /etc/hosts

echo "#####INSTALL DOCKER#######"
sudo yum install docker
echo "#####START DOCKER#########"
sudo service docker start 
echo "#####CONFIGURE DOCKER AUTOSTRAT WHEN SYSTEM BOOTUP######"
systemctl enable docker.service

echo "#####CONFIGURE AWS-CLI IF NOT CONFIGURED#############"
yum update -y
yum install aws-cli -y

echo "DOWNLOADING CORRECT VERSION OF CC-INSTALLER FROM AWS-S3 AND UNZIP INSTALLER TO /usr/local###########" 
aws s3 cp s3://nxtlbsrelease/Platform_SAAS/cc/ControlCenter-Linux-chef-9.2.0.0-18PS-Main.zip -d /usr/local

echo "#########BACKING UP cc_properties.json FILE AND REMOVE FROM THIS PATH"
sudo mv cc_properties.json cc_properties.json.bak
sudo rm -rf cc_properties.json 

echo "###########DOWNLOAD NEW cc_properties.json FILE FROM S3 TO /usr/local PATH############"
aws s3 cp s3://nxtlbsrelease/cc_properties_file/cc_properties.json -d /usr/local

echo "########DOWNLOAD LICENSE FILE FROM S3 PLACE TO /usr/local PATH#######"
aws s3 cp s3://nxtlbsreleaseLicense_file/license.dat -d /usr/local

echo "##########RUN DB CONTAINER#############"     
sudo docker run -d -p 5432:5432 --name=ccdb -v /home/ec2-user/ccdata:/var/lib/postgresql/data -e POSTGRES_HOST_AUTH_METHOD=trust -e POSTGRES_USER=ccdbuser -e POSTGRES_DB=ccdb -e POSTGRES_PASSWORD=Next1234 --restart=always postgres:9.5

echo "########CHECK DB CONTAINER IS RUNNING############"
sudo docker ps

echo "############################ ****************** ############################"
echo "############################ LAUNCHING CC ############################"

echo "###########STARTING CC-INSTALLATION###########"
cd /usr/local/PolicyServer

echo "##########ADD PERMISSION TO RUN install.sh##########"
sudo chmod 775 install.sh
echo "##########RUN INSTALL.SH SCRIPT########"
sudo ./install.sh -s

echo "######STARTING SERVICE##########"
sudo systemctl start CompliantEnterpriseServer

echo "##########WAIT FEW MINUTES TO CHECK LOGS - opt/nextlabs/PolicyServer/server/logs###########"
echo "##########NOW YOU SHOULD ABLE TO ACCESS CC CONSOLE AND ALSO FROM INTERNET#########"
curl telnet://92-cc.testdrm.com:5443 –vvv 


echo "############################ ****************** ############################"
echo "############################ ****************** ############################"
echo "############################ LAUNCHING JPC #################################"

echo "######CREATE A FOLDER jpc-docker IN /home/ec2-user PATH THEN DOWNLOAD Dokcerfile, jpc_properties.json, docker-entrypoint.sh FILES FROM S3 TO THIS NEW FOLDER PATH####"
cd /home/ec2-user
sudo mkdir jpc-docker
cd jpc-docker
aws s3 cp s3://nxtlbsrelease/JPC_Installation_files/Dockerfile -d /home/ec2-user/jpc-docker
aws s3 cp s3://nxtlbsrelease/JPC_Installation_files/docker-entrypoint.sh -d /home/ec2-user/jpc-docker
aws s3 cp s3://nxtlbsrelease/JPC_Installation_files/jpc_properties.json -d /home/ec2-user/jpc-docker

echo "#############BUILD JPC DOCKER CONTAINER FROM JPC IMAGE##########"
sudo docker build –t jpc:9.2 .
#sudo docker build . -t jpc:9.2 - In case above docker build doesn't work use this one instead


echo "#############RUN JPC DOCKER CONTAINER##########"
echo "########Remember to change CC and JPC Name to match domain name and 10.2.16.126 is privateIP of EC2 Machine#######"
sudo docker run --privileged  -d --hostname=92jpc.nextlabs.solutions  --add-host=92cc.nextlabs.solutions:10.2.16.126 --net=host --name jpc -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/jpc:/tmp/jpc  --restart=always jpc:9.2


echo "########CHECK JPC CONTAINER IS RUNNING############"
sudo docker ps







