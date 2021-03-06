#/bin/sh
#ifconfig eth0 down
#ifconfig eth0 hw ether 00:0e:64:10:00:02 192.168.0.7

# select sensor type: 5 Mpx (set 5) or 14 Mpx (set 14)
# 14MPix does not work with framepars & parsedit!!!
SENSOR_TYPE=5
# imgsrv port number 
IMGSRV_PORT=2323
# camogm port number
CAMOGM_PORT=3456
# camogm command pipe name
CAMOGM_PIPE=/var/volatile/camogm_cmd
# enable SATA, set this to 1 if camera is equipped with SSD drive
SATA_EN=1

#for andrey:
ifconfig eth0 192.168.0.9

PYDIR=/usr/local/bin
VERILOG_DIR=/usr/local/verilog
$PYDIR/test_mcntrl.py @${VERILOG_DIR}/hargs
echo imgsrv -p 2323
imgsrv -p 2323
#restart PHP - it can get errors while opening/mmaping at startup, then some functions fail
killall lighttpd; /usr/sbin/lighttpd -f /etc/lighttpd.conf
/www/pages/exif.php init=/etc/Exif_template.xml

echo "init sensor port"

wget -qO- "localhost/framepars.php?sensor_port=0&cmd=init" > /dev/null 2>&1

autoexposure -p 0 -c 0 -b 0 -d 1  >> /dev/null 2>&1 &

echo "start autoexposure daemon"

wget -qO- "localhost/parsedit.php?immediate&COMPRESSOR_RUN=2&DAEMON_EN=1&AUTOEXP_ON=1&AEXP_FRACPIX=0xff80&AEXP_LEVEL=0xf800&AE_PERIOD=4&AE_THRESH=500&HIST_DIM_01=0x0a000a00&HIST_DIM_23=0x0a000a00&EXP_AHEAD=3" > /dev/null 2>&1

echo "start white balance daemon"

wget -qO- "localhost/parsedit.php?immediate&COMPRESSOR_RUN=2&DAEMON_EN=1&WB_EN=0x1&WB_MASK=0xd&WB_PERIOD=16&WB_WHITELEV=0xfae1&WB_WHITEFRAC=0x028f&WB_SCALE_R=0x10000&WB_SCALE_GB=0x10000&WB_SCALE_B=0x10000&WB_THRESH=500&GAIN_MIN=0x18000&GAIN_MAX=0xfc000&ANA_GAIN_ENABLE=1&GAINR=0x10000&GAING=0x10000&GAINGB=0x10000&GAINB=0x10000" > /dev/null 2>&1

if [ $SATA_EN -eq 1 ]; then
    $PYDIR/x393sata.py
    modprobe ahci_elphel &
    sleep 2
    echo 1 > /sys/devices/soc0/amba@0/80000000.elphel-ahci/load_module
fi

echo "/etc/init_elphel393.sh done"
exit 0

#mkdir /tmp/local
#cp -r /usr/local/bin $PYDIR

cd /usr/local/verilog/

if [ $SENSOR_TYPE -eq 5 ]; then
    ln -sf x393_parallel.bit x393.bit
    $PYDIR/test_mcntrl.py @startup5 >> /dev/null 2>&1 &
else
    ln -sf x393_hispi.bit x393.bit
    $PYDIR/test_mcntrl.py @startup14 >> /dev/null 2>&1 &
fi
sleep 10

sync

$PYDIR/test_mcntrl.py @includes -c compressor_control all 1 None None None None None
$PYDIR/test_mcntrl.py @includes -c compressor_control all 0 None None None None None

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

# create exif files and send template to driver
if [ ! -e /dev/exif_exif0 ]; then
        mknod /dev/exif_exif0 c 125 16
fi
if [ ! -e /dev/exif_exif1 ]; then
        mknod /dev/exif_exif1 c 125 17
fi
if [ ! -e /dev/exif_exif2 ]; then
        mknod /dev/exif_exif2 c 125 18
fi
if [ ! -e /dev/exif_exif3 ]; then
        mknod /dev/exif_exif3 c 125 19
fi

if [ ! -e /dev/exif_meta0 ]; then
        mknod /dev/exif_meta0 c 125 32
fi
if [ ! -e /dev/exif_meta1 ]; then
        mknod /dev/exif_meta1 c 125 33
fi
if [ ! -e /dev/exif_meta2 ]; then
        mknod /dev/exif_meta2 c 125 34
fi
if [ ! -e /dev/exif_meta3 ]; then
        mknod /dev/exif_meta3 c 125 35
fi

if [ ! -e /dev/exif_template ]; then
        mknod /dev/exif_template c 125 2
fi
if [ ! -e /dev/exif_metadir ]; then
        mknod /dev/exif_metadir c 125 3
fi
/www/pages/exif.php init=/etc/Exif_template.xml

# debug code follows, should be removed later
# inable interrupts
echo 1 > /dev/circbuf0
# set quality, frame size and bayer shift
echo "3 80" > /dev/circbuf0
if [ $SENSOR_TYPE -eq 5 ]; then
	echo "6 2592:1936" > /dev/circbuf0
	echo "7 3" > /dev/circbuf0
else
	echo "6 4384:3280" > /dev/circbuf0
	echo "7 2" > /dev/circbuf0
fi
# turn off debug output
echo file circbuf.c -pfl > /sys/kernel/debug/dynamic_debug/control
echo file sensor_common.c -pfl > /sys/kernel/debug/dynamic_debug/control
echo file jpeghead.c -pfl > /sys/kernel/debug/dynamic_debug/control
# end of debug code

$PYDIR/test_mcntrl.py @includes -c compressor_control all 3 None None None None None

cd ~

if [ -f /usr/bin/imgsrv ]; then
	imgsrv -p $IMGSRV_PORT &
fi
if [ -f /usr/bin/camogm ]; then
	camogm -n $CAMOGM_PIPE -p $CAMOGM_PORT &
fi

sync
