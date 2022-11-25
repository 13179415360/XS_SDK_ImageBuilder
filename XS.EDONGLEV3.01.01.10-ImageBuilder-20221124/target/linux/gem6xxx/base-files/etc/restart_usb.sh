#!/bin/sh

sleep 2
echo 11201000.usb > /config/usb_gadget/g1/UDC
echo "usb.init done"

while :
do
    if [ ! -f /dev/usb-ffs/adb/ep1 ]
    then
        /etc/init.d/usb.init start
        sleep 2
        echo 11201000.usb > /config/usb_gadget/g1/UDC
        echo "usb.init done"
    fi
    sleep 1
done
