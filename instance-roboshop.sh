#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
Sg_ID="sg-03ca0ca07c63fb908"
zone_ID="Z04331122AEWGW4IMJX9W"
DOMAIN_NAME="ramyaboutique.shop"

for instance in $@
do
    INSTANCE_ID=$( aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --security-group-ids $Sg_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
  --query 'Instances[0].InstanceId' \
  --output text
    )

    if [ $instance = "frontend" ]; then

         IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        RECORD_NAME="$DOMAIN_NAME"

    else
          IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi
        echo "Ip Address $IP"

    aws route53 change-resource-record-sets --hosted-zone-id $zone_ID --change-batch '{
  "Comment": "Updating the A record for the main website",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$RECORD_NAME",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$IP"
          }
        ]
      }
    }
  ]
}
'

done
