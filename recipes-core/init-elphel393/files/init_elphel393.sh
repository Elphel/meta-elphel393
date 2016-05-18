#/bin/sh
#ifconfig eth0 down
#ifconfig eth0 hw ether 00:0e:64:10:00:02 192.168.0.7

# select sensor type: 5 Mpx (set 5) or 14 Mpx (set 14)
SENSOR_TYPE=14
# imgsrv port number 
IMGSRV_PORT=2323
# camogm command pipe name
CAMOGM_PIPE=/var/volatile/camogm_cmd

ifconfig eth0 192.168.0.9
#if [ ! -d /usr/local/ ]; then
#	ln -sf /mnt/mmc/local/ /usr/local/
#fi
cd /usr/local/verilog/
if [ $SENSOR_TYPE -eq 5 ]; then
    /usr/local/bin/test_mcntrl.py @startup5 >> /dev/null 2>&1 &
else
    /usr/local/bin/test_mcntrl.py @startup14 >> /dev/null 2>&1 &
fi
sleep 10

/usr/local/bin/test_mcntrl.py @includes -c compressor_control all 1 None None None None None
/usr/local/bin/test_mcntrl.py @includes -c compressor_control all 0 None None None None None

# create circular buffer files
if [ ! -e /dev/circbuf0 ]; then
	mknod /dev/circbuf0 c 135 32
fi
if [ ! -e /dev/circbuf1 ]; then
	mknod /dev/circbuf1 c 135 33
fi
if [ ! -e /dev/circbuf2 ]; then
	mknod /dev/circbuf2 c 135 34
fi
if [ ! -e /dev/circbuf3 ]; then
	mknod /dev/circbuf3 c 135 35
fi

if [ ! -e /dev/jpeghead0 ]; then
	mknod /dev/jpeghead0 c 135 48
fi
if [ ! -e /dev/jpeghead1 ]; then
	mknod /dev/jpeghead1 c 135 49
fi
if [ ! -e /dev/jpeghead2 ]; then
	mknod /dev/jpeghead2 c 135 50
fi
if [ ! -e /dev/jpeghead3 ]; then
	mknod /dev/jpeghead3 c 135 51
fi

# debug code follows, should be removed later
# inable interrupts
echo 1 > /dev/circbuf0
# set frame size
if [ $SENSOR_TYPE -eq 5 ]; then
	echo "6 2592:1936" > /dev/circbuf0
else
	echo "6 4384:3280" > /dev/circbuf0
fi
# end of debug code

/usr/local/bin/test_mcntrl.py @includes -c compressor_control all 3 None None None None None

if [ -f /usr/bin/imgsrv ]; then
	imgsrv -p $IMGSRV_PORT &
fi
if [ -f /usr/bin/camogm ]; then
	camogm $CAMOGM_PIPE &
fi

#/mnt/mmc/local/bin/x393sata.py
#insmod /mnt/mmc/ahci_elphel.ko # &
##sleep 2
##without sleep /sys/kernel/debug/ahci_exp/loading is not yet created
##echo 1 > /sys/kernel/debug/ahci_exp/loading
