#!/bin/bash
#Put all scripts in nxtlbrelease - aws cp s3://nxtlbrelease/InstallationScript
echo "############################ ****************** ############################"
echo "############################ ****************** ############################"

echo "SET HOSTNAME TO THE CORRECT URL NAME TO ACCESS FROM NETWORK"
sudo hostnamectl set-hostname ccname.ps.nextlabs.solutions.
#sudo vi /etc/hosts

echo "#####INSTALL DOCKER#######"
sudo yum install docker
echo "#####START DOCKER#########"
sudo service docker start 
echo "#####CONFIGURE DOCKER AUTOSTRAT WHEN SYSTEM BOOTUP######"
sudo systemctl enable docker.service

echo "#####CONFIGURE AWS-CLI IF NOT CONFIGURED#############"
sudo yum update -y
sudo yum install aws-cli -y

echo "DOWNLOADING CORRECT VERSION OF CC-INSTALLER FROM AWS-S3 AND UNZIP INSTALLER TO /usr/local###########" 
aws s3 cp s3://nxtlbsrelease/Platform_SAAS/cc/ControlCenter-Linux-chef-9.2.0.0-18PS-Main.zip /usr/local
sudo unzip ControlCenter-Linux-chef-9.2.0.0-18PS-Main.zip -d /usr/local

echo "#########BACKING UP cc_properties.json FILE AND REMOVE FROM THIS PATH"
sudo mv cc_properties.json cc_properties.json.bak
sudo rm -rf cc_properties.json 

echo "###########DOWNLOAD NEW cc_properties.json FILE FROM S3 TO /usr/local PATH############"
aws s3 cp s3://nxtlbsrelease/cc_properties_file/cc_properties.json  /usr/local

echo "########DOWNLOAD LICENSE FILE FROM S3 PLACE TO /usr/local PATH#######"
aws s3 cp s3://nxtlbsreleaseLicense_file/license.dat  /usr/local

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
echo "########## CHECK CC LOGS FOR ANY ISSUE##############"
curl telnet://ccname.ps.nextlabs.solutions:5443 –v
curl https://ccname.ps.nextlabs.solutions/console -v