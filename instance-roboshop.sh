#!/bin/bash

AMI_ID= "ami-0220d79f3f480ecf5"
Sg_ID= "sg-03ca0ca07c63fb908"

for instance in $@
do
    aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --security-group-ids $Sg_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
  --query 'Instances[0].PrivateIpAddress' \
  --output text
done
