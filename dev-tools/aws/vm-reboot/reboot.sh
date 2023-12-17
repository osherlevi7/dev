#! /bin/bash

rport_env=Test-vm
id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$rport_env" --query 'Reservations[*].Instances[*].InstanceId' --profile rport-stg) # need to remove the profile
instance_id=$(echo $id | tr -d '[]' | sed 's/"//g')
echo $instance_id

aws ec2 reboot-instances --instance-ids $instance_id