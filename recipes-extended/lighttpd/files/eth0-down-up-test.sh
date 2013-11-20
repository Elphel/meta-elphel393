#!/bin/sh
IP="192.168.0.15"
fails=0
semifails=0
tries=0
while true
do
    ifconfig eth0 down
    ifconfig eth0 up
    ping -c 1 -w 10 $IP >/dev/null
    rslt=$?
    semifails=$((semifails+$rslt))
    if [ $rslt != 0 ] ; then
	echo "Recovering..."
	sleep 5
	ping -c 1 -w 10 $IP >/dev/null
	rslt=$?
    fi
    fails=$(($fails+$rslt))
    tries=$(($tries+1))
    echo "tries: $tries fails: $fails long-up and fails: $semifails"
done