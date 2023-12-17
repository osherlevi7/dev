#! /bin/bash

######################################## 
#####    SnapShot Params            ####
######################################## 
# Locate the current instance ID
rport_env=Test-mv
id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$rport_env" --query 'Reservations[*].Instances[*].InstanceId' --profile rport-stg) # need to remove the profile
instance_id=$(echo $id | tr -d '[]' | sed 's/"//g')
echo $instance_id
# Set timestemp for the snapshot timing and naming
timestamp=$(date +"%Y-%m-%d")
echo $timestamp
# Get all volume IDs attached to the instance
volume_ids=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$rport_env" --query "Reservations[0].Instances[0].BlockDeviceMappings[*].Ebs.VolumeId" --output text --profile rport-stg) ## need to remove the profile
echo $volume_ids


######################################## 
#####    Create volume SnapShot     ####
######################################## 
# Create snapshots for all volumes in parallel
echo "Create snapshots for all volumes in parallel"
for volume_id in $volume_ids; do
    description="Snapshot for $instance_id - $timestamp"
    echo $description
    aws ec2 create-snapshot --volume-id $volume_id --description "$description" \
    --tag-specifications "ResourceType=snapshot,Tags=[{Key=Name,Value=$rport_env-$timestamp}]" --profile rport-stg & 
done


wait

######################################## 
#####    Save 10 Last Snapshots     ####
######################################## 
# Remove excess snapshots beyond the specified maximum
for volume_id in $volume_ids; do
    snapshot_ids=$(aws ec2 describe-snapshots --filters Name=volume-id,Values=$volume_id --query "Snapshots[].[SnapshotId,StartTime]" --output text | sort -k2 | awk '{print $1}')
    excess_snapshots=$(echo "$snapshot_ids" | head -n -10)
    
    for old_snapshot_id in $excess_snapshots; do
    aws ec2 delete-snapshot --snapshot-id $old_snapshot_id
    done
done