#!/bin/bash

# Puropse: Generate server report
# Date   : Sat Oct  8 12:16:23 UTC 2016
# Author : Rahul Patil<http://www.linuxian.com>

line="=================================="
echo "System Report for $(hostname)"
echo $line

total_cpu_core=$( grep -c processor /proc/cpuinfo  )
total_memory=$( free -m |awk '/Mem/{ print $2,"MB" }' )

echo "CPU Cores : $total_cpu_core"
echo $line

echo "Memory    : $total_memory"
echo $line

echo "Disk Space"
df -hTP --total
echo $line
