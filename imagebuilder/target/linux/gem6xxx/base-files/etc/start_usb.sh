#!/bin/sh

tout=100

while :
do
    usb_status=`cat /sys/module/mtu3/parameters/aplog_usb_port`
    if [ "$usb_status" = "1 0" ]
    then
        break
    fi

    if [ $tout -lt 0 ]
    then
        echo "start_usb timeout"
        exit 0
    fi
    tout=$(($tout-1))
    sleep 1
done

echo "MD USB enumeration done"
sleep 10
echo 11201000.usb > /config/usb_gadget/g1/UDC
echo "usb.init done"
