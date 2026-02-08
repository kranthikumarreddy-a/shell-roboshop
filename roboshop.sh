#!/bin/bash

SG_ID="sg-019f25a2463a096b9"
AMI_ID="ami-0220d79f3f480ecf5"
HOST_ID="Z09442902NGE25Y6RCGF6"

for instance in $@
do
INSTANCE_ID=$(aws ec2 run-instances \  
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]"
    --query 'Instances[0].InstanceId' \  # For each instance, we will get seperate uniqe ID
    --output text)
done

         
if [ $instance == frontend]; then

        IP=$(
             aws ec2 describe-instances \
             --instance-ids $INSTANCE_ID \
             --query 'Reservations[].Instances[].PublicIpAddress' \
             --output text
            )

  else

        IP=$(
             aws ec2 describe-instances \
             --instance-ids $INSTANCE_ID \
             --query 'Reservations[].Instances[].PrivareIpAddress' \
             --output text
            )
      fi      

      echo "Instance IP: $IP"
done