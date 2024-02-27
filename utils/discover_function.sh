#!/bin/bash

get_host_index() {
    local interface="$1"
    local total_nodes="$2"

    # Check if the interface exists
    check_interface_status "$interface"

    # Discover the base IP of the given interface
    local base_ip=$(ip addr show dev "$interface" | awk '/inet / {print $2}')
    IFS='/' read -r -a base_ip_parts <<< "$base_ip"
    local base_ip_address="${base_ip_parts[0]}"

    # Perform an nmap scan to find live hosts in the network
    local nmap_output
    local current_nodes=0
    while [ "$current_nodes" -lt "$total_nodes" ]; do
        nmap_output=$(nmap -sP "$base_ip_address"/24 -oG - | awk '/Up$/ {print $2}')
        filtered_ips=$(printf '%s\n' "${nmap_output[@]}" | grep -Eo "([0-9]{1,3}\.){3}[1-9][0-9]{2}$")
        current_nodes=$(echo "$filtered_ips" | wc -l)
        echo -n "Discovered $current_nodes out of $total_nodes nodes... " >&2
        echo -en "\r" >&2
        sleep 5
    done
    echo "" >&2  # Print a new line to make sure the next line is not overwriting this one

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

check_interface_status() {
    local interface="$1"
    while true; do
        # Check if the interface exists
        if ip link show "$interface" >/dev/null 2>&1; then
            # Check if the interface is up and has an IP address
            if ip addr show dev "$interface" | grep -q 'state UP'; then
                if ip addr show dev "$interface" | grep -q 'inet '; then
                    break
                fi
            fi
        fi
        sleep 1
    done
}

# Example usage of the function
#interface_name="col0"
#total_nodes=10
#result=$(get_host_index "$interface_name" "$total_nodes")
#echo "Host machine index: $result"

