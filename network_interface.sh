#!/bin/bash

clear

echo -e "+-----------+-----------------+\n| Interface | IP Address      |\n+-----------+-----------------+"
for iface in $(ip -o -4 addr list | awk '{print $2}' | tr '\n' ' ')
do
    ipaddr=$(ip -o -4 addr list $iface | awk '{print $4}' | cut -d/ -f1)
    printf "|%10s | %-16s|\n" $iface $ipaddr
done
echo "+-----------+-----------------+"
interfaces=`ls /sys/class/net`

function modify()
{
read -p "Which interface you want to modify? " interface

path_to_interface=/etc/sysconfig/network-scripts/ifcfg-$interface
if [[ `ls /sys/class/net | grep -w $interface` ]]
then
	bootproto=`grep "BOOTPROTO" "$path_to_interface" | cut -d "=" -f2`
	if [[ "$bootproto" ]]
	then
		read -p "BOOTPROTO=$bootproto do you want to change it? [Y/N] " bootproto_action
		if [[ "$bootproto_action" =~ ^([yY])$ ]]
		then
			read -p "To which value you want to change it to? " new_bootproto
			sed -i s/"$bootproto"/"$new_bootproto"/g "$path_to_interface"
		fi
	else
		read -p "BOOTPROTO doesn't exist create? [Y/N] " bootproto_action
		if [[ "$bootproto_action" =~ ^([yY])$ ]]
		then
			read -p "Provide value for BOOTPROTO: " new_bootproto
			echo "BOOTPROTO=$new_bootproto" >> "$path_to_interface"
		fi
	fi


	ipaddr=`grep "IPADDR" "$path_to_interface" | cut -d "=" -f2`
	if [[ "$ipaddr" ]]
	then
		read -p "IPADDR=$ipaddr do you want to change it? [Y/N] " ipaddr_action
		if [[ "$ipaddr_action" =~ ^([yY])$ ]]
		then
			read -p "Provide new ip address for IPADDR: " new_ipaddr
			sed -i s/"$ipaddr"/"$new_ipaddr"/g "$path_to_interface"
		fi
	else
		read -p "IPADDR doesn't exist create? [Y/N] " ipaddr_action
		if [[ "$ipaddr_action" =~ ^([yY])$ ]]
		then
			read -p "Provide ip address for IPADDR: " new_ipaddr
			echo "IPADDR=$new_ipaddr" >> "$path_to_interface"
		fi
	fi

	netmask=`grep "NETMASK" "$path_to_interface" | cut -d "=" -f2`
	if [[ "$netmask" ]]
	then
		read -p "NETMASK=$netmask do you want to change it [Y/N] " netmask_action
		if [[ "$netmask_action" =~ ^([yY])$ ]]
		then
			read -p "Provide new ip for NETMASK: " new_netmask
			sed -i s/"$netmask"/"$new_netmask"/g "$path_to_interface"
		fi
	else
		read -p "NETMASK doesn't exist create? [Y/N] " netmask_action
		if [[ "$netmask_action" =~ ^([yY])$ ]]
		then
			read -p "Provide ip address for NETMASK: " new_netmask
			echo "NETMASK=$new_netmask" >> "$path_to_interface"
		fi
	fi

	gateway=`grep "GATEWAY" "$path_to_interface" | cut -d "=" -f2`
	if [[ "$gateway" ]]
	then
		read -p "GATEWAY=$gateway do you want to change it? [Y/N] " gateway_action
		if [[ "$gateway_action" =~ ^([yY])$ ]]
		then
			read -p "provide new ip for GATEWAY: " new_gateway
			sed -i s/"$gateway"/"$new_gateway"/g "$path_to_interface"
		fi
	else
		read -p "GATEWAY doesn't exist create? [Y/N] " gateway_action
		if [[ "$gateway_action" =~ ^([yY])$ ]]
		then
			read -p "Provide ip address for GATEWAY: " new_gateway
			echo "GATEWAY=$new_gateway" >> "$path_to_interface"
		fi
	fi



	dns=`grep "DNS" "$path_to_interface" | cut -d "=" -f2`
	if [[ "$dns" ]]
	then
		echo -e "You already use this dns\n$dns"
	fi

	
	read -e -i "y" -p "Restart network? [Y/N] " restart_prompt
	if [[ "$restart_prompt" =~ ^([yY])$ ]]
	then
		`systemctl restart NetworkManager`
	fi
	echo -e "\n$interface configuration:"
	cat $path_to_interface
else
	echo -e "$interface not found!"
	setup_network

fi
}




function TUI()
{
echo "Do you want to use TUI on NetworkManager?"
read -p "Enter - 1, Cancel  - 2: " changes
if [[ $changes == 1 ]]; then
     nmtui
elif  [[ $changes == 2 ]]; then
echo "NetworkManager exit"
fi
}
read -p $'Question?\n1)Modify existing interface file\n2)Use TUI interface to modify\n' action

case $action in
1) modify;;
2) TUI;;
esac



