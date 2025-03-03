#!/bin/bash

# Load instance IDs and region from the Terraform output JSON file
INSTANCE_IDS=$(jq -r '.instance_ids.value[]' output.json)
REGION=$(jq -r '.region.value' output.json)

echo "Instance IDs: $INSTANCE_IDS"
# Action: "start" or "stop"
ACTION=$1

if [ -z "$ACTION" ]; then
    echo "Usage: $0 {start|stop}"
    exit 1
fi

# Function to start instances and get public IPs
start_instances() {
    echo "Starting instances in region $REGION..."
    aws ec2 start-instances --instance-ids $INSTANCE_IDS --region $REGION
    
    echo "Waiting for instances to be in 'running' state..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_IDS --region $REGION
    
    echo "Fetching instance public IPs and tags..."
    aws ec2 describe-instances \
      --instance-ids $INSTANCE_IDS \
      --region $REGION \
      --query 'Reservations[].Instances[].{PublicIP:PublicIpAddress, PrivateIP:PrivateIpAddress, Name:Tags[?Key==`Name`].Value|[0]}' \
      --output json > instance_ips.json

    echo "Instance public IPs and tags saved to instance_ips.json"
}

# Function to stop instances
stop_instances() {
    echo "Stopping instances in region $REGION..."
    aws ec2 stop-instances --instance-ids $INSTANCE_IDS --region $REGION
    echo "Instances stopped: $INSTANCE_IDS"
}

# Execute based on action
case $ACTION in
    start)
        start_instances
        ;;
    stop)
        stop_instances
        ;;
    *)
        echo "Invalid action! Use 'start' or 'stop'."
        exit 1
        ;;
esac
