#/bin/sh
#ifconfig eth0 down
#ifconfig eth0 hw ether 00:0e:64:10:00:02 192.168.0.7

# select sensor type: 5 Mpx (set 5) or 14 Mpx (set 14)
SENSORT_TYPE=14

ifconfig eth0 192.168.0.9
if [ ! -d /usr/local/ ]; then
	ln -sf /mnt/mmc/local/ /usr/local/
fi
cd /usr/local/verilog/
if [ $SENSOR_TYPE -eq 5 ]; then
    /usr/local/bin/test_mcntrl.py @startup5 >> /dev/null 2>&1 &
else
    /usr/local/bin/test_mcntrl.py @startup14 >> /dev/null 2>&1 &
fi
sleep 10

/usr/local/bin/test_mcntrl.py @includes -c compressor_control all 1 None None None None None
/usr/local/bin/test_mcntrl.py @includes -c compressor_control all 0 None None None None None
/usr/local/bin/test_mcntrl.py @includes -c compressor_control all 3 None None None None None
#sleep 5
cd /usr/local/circbuf/; ./circbuf_start.sh

#/usr/local/bin/test_mcntrl.py -C compressor_control all 3

#/mnt/mmc/local/bin/x393sata.py
#insmod /mnt/mmc/ahci_elphel.ko # &
##sleep 2
##without sleep /sys/kernel/debug/ahci_exp/loading is not yet created
##echo 1 > /sys/kernel/debug/ahci_exp/loading
