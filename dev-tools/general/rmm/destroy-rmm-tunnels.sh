#!/bin/bash
username=username
base_url="https://domain.com/api/v1" # prod
# base_url="https://domain-staging.com/api/v1"  # stg 
password="api-token"
# Get all open tunnels
tunnels=$(curl -u "$username:$password" -s -w "%{http_code}" "$base_url/tunnels")
http_status="${tunnels:(-3)}"
tunnels_data="${tunnels::-3}"

function delete_tunnels {
tunnels=$1
base_url=$2
username=$3
password=$4

if [[ $http_status != 200 ]]; then
    echo "API call unauthorized. Please check your credentials."
    exit 1
fi

# Check if there are tunnels
if [[ $(echo "$tunnels" | jq -c '.data | length') == 0 ]]; then
    echo "################## No open tunnels found     ###########"
    echo "cleanup_output=$(echo "$tunnels" | jq -c '.data | length')" >> $GITHUB_OUTPUT
    exit 0
else
    # Parse tunnel data and delete each tunnel
    if [[ $(echo "$tunnels" | jq -c '.data | length') > 0 ]]; then
    for tunnel in $(echo "$tunnels" | jq -c '.data[]'); do
        
        client_id=$(echo "$tunnel" | jq -r '.client_id')
        tunnel_id=$(echo "$tunnel" | jq -r '.id')
        
        echo "number of tunnels: $(echo "$tunnels" | jq -c '.data | length')"
        echo 'client_id: ' $client_id
        echo 'tunnel_id: ' $tunnel_id

        curl -X DELETE "$base_url/clients/$client_id/tunnels/$tunnel_id" \
        -u "$username:$password"
        
        echo "Deleted tunnel with ID $tunnel_id for client $client_id."
        echo "Cleanup completed. Tunnels deleted successfully"
        echo "-----------------------------------------"
        echo "cleanup_output=$(echo "$tunnels" | jq -c '.data | length')" >> $GITHUB_OUTPUT
    done
    fi
fi
}
delete_tunnels "$tunnels" "$base_url" "$username" "$password"
