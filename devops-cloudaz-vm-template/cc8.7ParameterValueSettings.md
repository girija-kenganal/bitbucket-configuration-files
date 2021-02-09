CC and JPC 8.7.2.0 script is available under user data section of the cf template

Below parameter values need to change based on the account and region you want to deploy this stack
1.AMI ID - based on the region need to change AMI ID
1.VpcId

ALB should be launched in public subnet
2.PublicSubnetId1A
3.PublicSubnetId1B

CC and JPC Instances are launched in private subnet
4.PrivateSubnetId1A
5.PrivateSubnetId1B

6.DomainName
If domain name is changed, change the ACM Cert or use wild card cert which matches your domain name and PublicHostedzoneId accordingly
and also change domain name in cc and jpc user data script to assign to HOST_NAME varibale to add to /etc/hosts file 
this change requires only for cc8.7.2.0. For cc9.2 version no need to add hostname to /etc/hosts file 
only need to set hostname using set-hostname command.

7.Template resource ApplicationLBListenerRule1 - host-header redirects to jpc domain name as value in the template
Ex: 'jpcdynamic.pep.cloudaz.com'

Note: Before deploying stack make sure required files are avilable in s3 bucket which we are using in our user-data script to pull files from s3 to deploy cc and jpc and ports are correct especially for cc and jpc properties files.
