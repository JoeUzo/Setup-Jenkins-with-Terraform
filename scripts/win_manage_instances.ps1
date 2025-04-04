# Load the JSON data from the Terraform output
$jsonData = Get-Content -Raw -Path ".\output.json" | ConvertFrom-Json

# Extract instance IDs and region from the JSON
$instanceIds = $jsonData.instance_ids.value
$region = $jsonData.region.value
Write-Host "the region is $region"

# Action: "start" or "stop"
$action = $args[0]

if (-not $action) {
    Write-Host "Usage: ./manage_instances.ps1 {start|stop}"
    exit
}

# Function to start instances and get public IPs
function Start-Instances {
    Write-Host "Starting instances in region $region..."
    aws ec2 start-instances --instance-ids $instanceIds --region $region
    
    Write-Host "Waiting for instances to be in 'running' state..."
    aws ec2 wait instance-running --instance-ids $instanceIds --region $region

    Write-Host "Fetching instance public IPs and tags..."
    $instanceData = aws ec2 describe-instances `
      --instance-ids $instanceIds `
      --region $region `
      --query 'Reservations[].Instances[].{PublicIP:PublicIpAddress, PrivateIP:PrivateIpAddress, Name:Tags[?Key==`Name`].Value|[0]}' `
      --output json

    $instanceData | Set-Content -Path ".\instance_ips.json"
    Write-Host "Instance public IPs and tags saved to instance_ips.json"
}

# Function to stop instances
function Stop-Instances {
    Write-Host "Stopping instances in region $region..."
    aws ec2 stop-instances --instance-ids $instanceIds --region $region
    Write-Host "Instances stopped: $instanceIds"
}

# Execute based on action
switch ($action) {
    "start" { Start-Instances }
    "stop" { Stop-Instances }
    default { Write-Host "Invalid action! Use 'start' or 'stop'." }
}
