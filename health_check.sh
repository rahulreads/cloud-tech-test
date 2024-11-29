#!/bin/bash

# Fetch the external IP of the LoadBalancer service
EXTERNAL_IP=$(kubectl get svc backend-service -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Ensure the EXTERNAL_IP is not empty
if [ -z "$EXTERNAL_IP" ]; then
    echo "$(date): Unable to fetch external IP for backend-service. Exiting." 
    exit 1
fi

# Construct the API URL
API_URL="http://$EXTERNAL_IP/health_check"

# Log file to store the health check results
LOG_FILE="./health_check.log"

# Perform the health check
http_response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL")

# Log the results
if [ "$http_response" == "200" ]; then
    echo "$(date): API at $API_URL is reachable - Health check passed" >> "$LOG_FILE"
else
    echo "$(date): API at $API_URL is unreachable - Health check failed (HTTP $http_response)" >> "$LOG_FILE"
fi
