# Create ALB Security Group
aws ec2 create-security-group --group-name WWW-SKYDRM-COM-EFS-SG --description "WWW-SKYDRM-COM-EFS-SG" --vpc-id vpc-06cf54904b995b223 --profile skydrm --region us-east-1

# Create ingress rules for ALB Security group (Allow EC2 SEC GROUP)
aws ec2 authorize-security-group-ingress --group-id sg-0c09b1edd86c73ad4 --protocol tcp --port 2049  --source-group sg-003630749cccda81d  --profile skydrm --region us-east-1

