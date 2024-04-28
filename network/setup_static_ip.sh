#!/bin/bash

# Function to set up static IP
setup_static_ip() {
    read -p "Enter static IP address: " ip_address
    read -p "Enter netmask: " netmask
    read -p "Enter default gateway: " gateway
    read -p "Enter DNS server(s) separated by comma: " dns_servers

    # Save configuration to /etc/netplan/
    cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml >/dev/null
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - [$ip_address/$netmask]
      routes: 
        - to: default
          via: $gateway
      nameservers:
        addresses: [$dns_servers]
EOF

    # Apply the new configuration
    sudo netplan apply
}

# Function to set up dynamic IP (DHCP)
setup_dynamic_ip() {
    # Save configuration to /etc/netplan/
    cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml >/dev/null
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
EOF

    # Apply the new configuration
    sudo netplan apply
}

# Prompt user to choose static or dynamic IP
read -p "Do you want to set up a static (s) or dynamic (d) IP address? [s/d]: " ip_choice

case $ip_choice in
    [sS]* ) setup_static_ip;;
    [dD]* ) setup_dynamic_ip;;
    * ) echo "Invalid choice. Exiting."; exit;;
esac

# Test connectivity
ping -c 4 google.com >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Connectivity test: Success! You are connected to the internet."
else
    echo "Connectivity test: Failed! You are not connected to the internet."
fi

