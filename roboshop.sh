#!/bin/bash

AWS="/usr/local/bin/aws"  # AWS cofigured in /usr/local/bin/aws location


set -e

SG_ID="sg-019f25a2463a096b9"
AMI_ID="ami-0220d79f3f480ecf5"
HOST_ID="Z09442902NGE25Y6RCGF6"
DOMAIN_NAME="daws-88sbatch.online"


for instance in "$@"
do
  echo "Creating instance: $instance"

  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type t3.micro \
    --security-group-ids "$SG_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

  echo "Instance ID: $INSTANCE_ID"

  # wait until instance is running (important)
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

  if [ "$instance" = "frontend" ]; then
    IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query 'Reservations[].Instances[].PublicIpAddress' \
      --output text)
     RECORD_NAME=daws-88sbatch.online

  else
    IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query 'Reservations[].Instances[].PrivateIpAddress' \
      --output text)
      RECORD_NAME=$instance.daws-88sbatch.online  # mongodb.daws-88sbatch.online
  fi

  echo "Instance ($instance) IP:: $IP"


aws route53 change-resource-record-sets \
  --hosted-zone-id $HOST_ID \
  --change-batch '{
    "Comment": "Update frontend record",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$RECORD_NAME'",
          "Type": "A",
          "TTL": 300,
          "ResourceRecords": [
            { "Value": "'$IP'" }
          ]
        }
      }
    ]
  }

  echo "Record updated for $instance"
  done

