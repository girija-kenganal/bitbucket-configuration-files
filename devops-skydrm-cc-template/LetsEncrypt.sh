#Prerequisite - start Apache and set it to start each time the system boots and 
sudo systemctl start httpd && sudo systemctl enable httpd
#First need to setup cartbot-auto client for let’s encrypt certificate generation. for setup
wget https://dl.eff.org/certbot-auto
#set permission in cartbot-auto
chmod a+x certbot-auto
#making a request for certificate and verify the requests- /var/www/html webroot of you your project and add-ssl.us-est-2.elasticbeanstalk.com which domains need to generates the certificate should be https enabled
sudo ./certbot-auto --debug -v --server https://acme-v01.api.letsencrypt.org/directory certonly --webroot -w /var/www/html -d cc-name.nextlabs.solutions
#certificates are saved at the below location(cert.pem,chain.pem,fullchain.pem,privkey.pem) and need to be root user to check these files - sudo su
/etc/letsencrypt/live/cc-name.nextlabs.solutions/
#need to update /etc/httpd/conf.d/ssl.conf file which is not there in this location so install SSL mod on your apacheserver
yum install mod24_ssl
#you will find /etc/httpd/cond.d/ssl.conf file for adding location
#Update Certificate location for let’s encrypt
SSLCertificateFile /etc/letsencrypt/live/domain.com/cert.pem
SSLCertificateKeyFile /etc/letsencrypt/live/domain.com/privkey.pem
SSLCertificateChainFile /etc/letsencrypt/live/domain.com/fullchain.pem
#after adding this need to restart the apache service
sudo service httpd restart
#Add HTTPS listener for AWS instance, Security Groups inbound rules


