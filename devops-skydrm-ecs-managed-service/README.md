# README #

# Launch CF from Local CLI

 aws s3 cp cf-templates/ s3://cf-templates-nextlabs/skydrm --recursive --profile devops ; aws cloudformation delete-stack --stack-name skydrm-uat --profile devops --region us-west-2 ;  aws cloudformation create-stack --stack-name skydrm-uat --template-url https://cf-templates-nextlabs.s3.amazonaws.com/skydrm/master.yml --parameters file://cf-templates/parameter-file.json --capabilities CAPABILITY_NAMED_IAM --profile devops --region us-west-2

 # TODO

1. USE !Sub to grab S3 Access key and Secret Key and Pass to LaunchCOnfig usr data in export form LINE NO 398 (master.yml)
2. CHECK EFs security group rules
3. Implement get private EC2 Ip and update route53 A Records by name (put inside user-data)
4. Combine CloudAz template using Import method