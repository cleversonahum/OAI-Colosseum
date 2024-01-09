#!/bin/bash

get_host_index() {
    local interface="$1"

    # Discover the base IP of the given interface
    local base_ip=$(ip addr show dev "$interface" | awk '/inet / {print $2}')
    IFS='/' read -r -a base_ip_parts <<< "$base_ip"
    local base_ip_address="${base_ip_parts[0]}"

    # Perform an nmap scan to find live hosts in the network
    local nmap_output=$(nmap -sP "$base_ip_address"/24 -oG - | awk '/Up$/ {print $2}')

    # Filter and store IPs where the fourth octet is greater than or equal to 100
    local filtered_ips=$(printf '%s\n' "${nmap_output[@]}" | grep -Eo "([0-9]{1,3}\.){3}[1-9][0-9]{2}$")

    # Sort filtered IPs in ascending order
    local sorted_ips=$(printf '%s\n' "${filtered_ips[@]}" | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4)

    # Get the index of the host machine's IP
    local host_index=1
    for ip in $sorted_ips; do
        if [ "$ip" = "$base_ip_address" ]; then
            break
        fi
        ((host_index++))
    done

    # Return the host machine's index
    echo "$host_index"
}

# Example usage of the function
interface_name="col0"
result=$(get_host_index "$interface_name")
echo "Host machine index: $result"

