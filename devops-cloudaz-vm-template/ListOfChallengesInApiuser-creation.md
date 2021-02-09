To create api users using script after cc 8.7 installation we have some issue
1. For api user creation we need to install pg client 
2. We can only install pg client using sudo yum install postgresql95 -y in amazon linux1 because Amazon linux2 only supports postgresql 9.6 and above
3. Amazon linux1 AMI doesn't support "hostnamectl set-hostname hostname" so we need to use sed -i "s/HOSTNAME=localhost.localdomain/HOSTNAME=newjpc.nextlabs.solutions/g" /etc/sysconfig/network to set hostname
4. After setting hostname using sed command in /etc/sysconfig/network need to restart network service using "service network restart" and reboot instance to make it work
5. reboot command in user-data script was breaking rest of the commands after reboot in user-data so s3 cp didn't work so cc and jpc deployment failed

 