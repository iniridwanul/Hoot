#!/bin/bash

# Set the script to exit immediately if any command fails.
set -e

# Change the current directory to the parent directory.
cd ..

# Create the directories 'proxylist' and 'anonymous-proxylist' if they don't exist.
mkdir -p proxylist anonymous-proxylist

# Remove all existing .txt files in the 'proxylist' and 'anonymous-proxylist' directories.
rm -f proxylist/*.txt anonymous-proxylist/*.txt

# Fetch the JSON data containing proxy information from the specified GitHub URL.
# Use curl with -s (silent) to suppress progress bars and errors.
monosans_json=$(curl -s "https://raw.githubusercontent.com/monosans/proxy-list/main/proxies.json")

# Define a header string that will be added to each output file.
header=$(cat <<EOF
+------------------------+
|       ▄       ▄        |
|      ▄ ▀▄   ▄▀ ▄       |
|      █▄█▀███▀█▄█       |
|      ▀█████████▀       |
|       ▄▀     ▀▄        |
|   Hoot Proxy Scraper   |
|   Author: iniridwanul  |
+------------------------+
EOF
)

# Parse the JSON data using jq and extract the host, port, protocol, and anonymity of Bangladeshi proxies.
# Filter proxies based on the country code "BD".
# The output is formatted as "host:port protocol anonymity".
echo "$monosans_json" | jq -r '.[] | select(.geolocation.country.iso_code == "BD") | "\(.host):\(.port) \(.protocol) \(.anonymity)"' | while read -r line; do
    # Extract the host:port, protocol, and anonymity from the current line.
    host_port=$(echo "$line" | awk '{print $1}')
    protocol=$(echo "$line" | awk '{print $2}')
    anonymity=$(echo "$line" | awk '{print $3}')

    # Use a case statement to handle different proxy protocols.
    case "$protocol" in
        # If the protocol is HTTP, append the host:port to the 'http.txt' file in 'proxylist'.
        # If the anonymity is not "transparent", also append it to 'http.txt' in 'anonymous-proxylist'.
        http)
            echo "$host_port" >> proxylist/http.txt
            if [ "$anonymity" != "transparent" ]; then
                echo "$host_port" >> anonymous-proxylist/http.txt
            fi
            ;;

        # If the protocol is SOCKS4, append the host:port to the 'socks4.txt' file in 'proxylist'.
        # If the anonymity is not "transparent", also append it to 'socks4.txt' in 'anonymous-proxylist'.
        socks4)
            echo "$host_port" >> proxylist/socks4.txt
            if [ "$anonymity" != "transparent" ]; then
                echo "$host_port" >> anonymous-proxylist/socks4.txt
            fi
            ;;
        
        # If the protocol is SOCKS5, append the host:port to the 'socks5.txt' file in 'proxylist'.
        # If the anonymity is not "transparent", also append it to 'socks5.txt' in 'anonymous-proxylist'.
        socks5)
            echo "$host_port" >> proxylist/socks5.txt
            if [ "$anonymity" != "transparent" ]; then
                echo "$host_port" >> anonymous-proxylist/socks5.txt
            fi
            ;;
        
        # If the protocol is unknown, append the host:port to the 'unknown.txt' file in 'proxylist'.
        *)
            echo "$host_port" >> proxylist/unknown.txt
            ;;
    esac
done

# Iterate over all .txt files in 'proxylist' and 'anonymous-proxylist' directories.
# Sort each file and remove duplicate lines using 'sort -u'.
for file in proxylist/*.txt anonymous-proxylist/*.txt; do
    sort -u "$file" -o "$file"
done

# Iterate over all .txt files again and add the header to each file if it's not empty.
for file in proxylist/*.txt anonymous-proxylist/*.txt; do
    if [ -s "$file" ]; then
        (
            echo "$header"
            cat "$file"
        ) > "$file.tmp" && mv "$file.tmp" "$file"
    fi
done