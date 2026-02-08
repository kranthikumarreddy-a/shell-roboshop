#!/bin/bash

AWS="/usr/local/bin/aws"


set -e

SG_ID="sg-019f25a2463a096b9"
AMI_ID="ami-0220d79f3f480ecf5"

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
  else
    IP=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query 'Reservations[].Instances[].PrivateIpAddress' \
      --output text)
  fi

  echo "Instance ($instance) IP: $IP"
done
