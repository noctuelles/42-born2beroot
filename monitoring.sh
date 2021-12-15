#!/bin/bash

ARCHITECTURE=$(uname --all)
PHYSICAL_CPUS=$(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)
VCPU=$(cat /proc/cpuinfo | grep "^processor" | wc -l)

MEM_TOTAL=$(vmstat -s | grep "total memory" | mawk '{printf "%d\n", $1/1000}')
MEM_USED=$(vmstat -s | grep "used memory" | mawk '{printf "%d\n", $1/1000}')
MEM_PERCENT=$(bc -l <<< "${MEM_USED} / ${MEM_TOTAL} * 100")
MEM_RATIO="${MEM_USED}/${MEM_TOTAL}MB ($(printf "%.2f%%" ${MEM_PERCENT}))"
DISK_USAGE=$(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)", $3,$2,$5}')
CPU_USAGE=$(top -b -n 1 | grep Cpu | awk '{print $4 "%"}')
LAST_BOOT=$(who -b | awk '{print $3 " " $4}')

if [ $(cat /etc/fstab | grep "mapper" | wc -l) -eq 0 ]
then
	USE_LVM="No"
else
	USE_LVM="Yes"
fi

TCP_CONNECTIONS="$(netstat -natu | grep -E "^tcp.*ESTABLISHED" | wc -l) ESTABLISHED"
USERS_LOG=$(who | cut -d " " -f 1 | uniq | wc -l)
NETWORK="$(hostname -I)($(ip link show | grep "link/ether" | awk '{print $2}'))"
SUDO_CMDS=$(cat /var/log/sudo/sudo.log | wc -l)
SUDO_CMD=$((SUDO_CMDS / 2))" cmd(s) executed"

wall "
	# Architecture:		$ARCHITECTURE
	# CPU physical:		$PHYSICAL_CPUS
	# vCPU:			$VCPU
	# Memory Usage:		$MEM_RATIO
	# Disk Usage:		$DISK_USAGE
	# CPU load:		$CPU_USAGE
	# Last boot:		$LAST_BOOT
	# LVM use:		$USE_LVM
	# TCP Connections:	$TCP_CONNECTIONS
	# User(s) log:		$USERS_LOG
	# Network:		$NETWORK
	# Sudo:			$SUDO_CMD
"
