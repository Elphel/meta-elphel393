#!/usr/bin/env python
# encoding: utf-8
'''
# Temperature monitor for Elphel393 camera.
# This python script should be started as a daemon at startup. It will continuously monitor
# camera temperature and turn external fan on and off. It will also turn camera off in case
# of extreme temperature limit is exceeded.
#
# Copyright (C) 2016, Elphel.inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import os
import sys
import time
import subprocess
import atexit
from posix import EX_OSFILE, F_OK

DEBUG = 0

""" Set temperature when the fan should be turned on. """
TEMP_FAN_ON = 35.0
""" Set temperature when the system should be turned off. """
TEMP_SHUTDOWN = 60.0
""" Temperature hysteresis in degrees. """
TEMP_HYSTERESIS = 2.0
""" Temperature sampling time in seconds. This constant may be a floating point value. """ 
SAMPLING_TIME = 1
""" Temperature scaling factor. """
SCALE_CFT = 0.001
""" The name of the file in /var/run which will contain PID """
PID_NAME = "init_tempmon"

ctrl_path_pref = "/sys/devices/soc0/elphel393-pwr@0/"
ctrl_fn = {"poweroff_fn": "power_off",
           "vp5_en_fn":   "channels_en",
           "vp5_dis_fn":  "channels_dis",
           "gpio_fn":     "gpio_10389"}
hwmon_path_pref = "/sys/devices/soc0/amba@0/f8007100.ps7-xadc/iio:device0/"
hwmon_fn = {"offset":     "in_temp0_offset",
            "raw":        "in_temp0_raw",
            "scale":      "in_temp0_scale"}
out_path_pref = "/var/volatile/tmp/"
out_fn = {"core_temp_fn": "core_temp",
          "temp_params_fn": "core_temp_params"}

class temp_monitor():
    def __init__(self, ctrl_path_pref, ctrl_file_names, hwmon_path_pref, hwmon_fn,
                 out_path_prefix, out_fnames):
        self.is_fan_on = False
        self.is_vp5_enabled = False
        self.is_10389_present = True
        self.ctrl_path_prefix = ctrl_path_pref
        self.ctrl_fnames = ctrl_file_names
        self.hwmon_path_prefix = hwmon_path_pref
        self.hwmon_fnames = hwmon_fn
        self.samples_window = []
        self.pid_fname = "/var/run/" + PID_NAME + ".pid"
        """ Number of samples for temperature averaging """
        self.samples_num = 5
        self.fan_cmd = {"fan_cmd_on":  "0x101",
                        "fan_cmd_off": "0x100"}
        self.params = {"temp_minor":   TEMP_FAN_ON,
                       "temp_major":   TEMP_SHUTDOWN,
                       "temp_hyst":    TEMP_HYSTERESIS,
                       "temp_sampling_time": SAMPLING_TIME}
        
        """ Create output files """
        try:
            self.core_temp_out_f = open(out_path_prefix + out_fnames["core_temp_fn"], "w")
        except IOError:
            print "Failed to create file: '%s%s'" % (out_path_prefix, out_fnames["core_temp_fn"])
        try:
            self.core_temp_params_f = open(out_path_prefix + out_fnames["temp_params_fn"], "w")
        except IOError:
            self.core_temp_out_f.close()
            print "Failed to create file: '%s%s'" % (out_path_prefix, out_fnames["temp_params_fn"])
        
        """ Create pid file """
        with open(self.pid_fname, "w") as pid_file:
            pid_file.write(str(os.getpid()))
        atexit.register(self.delpid)
    
    def delpid(self):
        if os.access(self.pid_fname, F_OK):
            os.remove(self.pid_fname) 

    def check_files(self):
        """
        Check if all files exist in the system.
        """
        for key, val in self.hwmon_fnames.items():
            if not os.access(self.hwmon_path_prefix + val, F_OK):
                print "Failed to open sysfs file: '%s%s'" % (self.hwmon_path_prefix, val)
                return False
        for key, val in self.ctrl_fnames.items():
            if not os.access(self.ctrl_path_prefix + val, F_OK):
                if key == "gpio_fn":
                    self.is_10389_present = False
                else:
                    print "Failed to open sysfs file: '%s%s'" % (self.ctrl_path_prefix, val)
                    return False
        return True
                
    def shutdown(self):
        """
        Turn system off. This function will be called continuously until the system is turned off.
        """
        subprocess.call(["/sbin/shutdown", "-hP", "now"])        
    
    def fan_ctrl(self, ctrl):
        """
        Control fan by writing to sysfs files.
        @param ctrl: can be "on" or "off" to turn fan on or off
        """
        if ctrl is "on":
            """ check if +5V is active and turn it on if it is not (it should not happen) """
            with open(self.ctrl_path_prefix + self.ctrl_fnames["vp5_en_fn"], "r+") as f:
                channels = f.read()
                if channels.find("vp5") == -1:
                    f.write("vp5")
                    f.flush()
            if self.is_10389_present:
                with open(self.ctrl_path_prefix + self.ctrl_fnames["gpio_fn"], 'w') as f:
                    f.write(self.fan_cmd["fan_cmd_on"])
                    f.flush()
            self.is_fan_on = True
        elif ctrl is "off":
            if self.is_10389_present:
                with open(self.ctrl_path_prefix + self.ctrl_fnames["gpio_fn"], 'w') as f:
                    f.write(self.fan_cmd["fan_cmd_off"])
                    f.flush()
            else:
                with open(self.ctrl_path_prefix + self.ctrl_fnames["vp5_dis_fn"], 'w') as f:
                    f.write("vp5")
                    f.flush()
            self.is_fan_on = False
        else:
            print "'%s': unrecognized command: '%s'" % (__name__, ctrl)
    
    def monitor(self):
        """
        Continuously read temperature and control fan.
        """
        try:
            while True:
                with open(self.hwmon_path_prefix + self.hwmon_fnames["offset"]) as f:
                    offset = float(f.read().strip())
                with open(self.hwmon_path_prefix + self.hwmon_fnames["raw"]) as f:
                    raw = float(f.read().strip())
                with open(self.hwmon_path_prefix + self.hwmon_fnames["scale"]) as f:
                    scale = float(f.read().strip())
                
                if raw > 4000:
                    raw -= 4096
                core_temp = (raw + offset) * scale * SCALE_CFT
                self.samples_window.append(core_temp)
                if len(self.samples_window) > self.samples_num:
                    self.samples_window.pop(0)
                samples = list(self.samples_window)
                samples.sort()

                avg = samples[len(samples) / 2]
                if core_temp < (self.params["temp_minor"] - self.params["temp_hyst"]) and self.is_fan_on:
                    self.fan_ctrl("off")
                elif core_temp >= self.params["temp_minor"] and core_temp < self.params["temp_major"] and not self.is_fan_on:
                    self.fan_ctrl("on")
                elif avg >= self.params["temp_major"]:
                    self.shutdown()
                
                self.core_temp_out_f.seek(0)
                self.core_temp_out_f.write(str(core_temp))
                self.core_temp_out_f.flush()
                
#                 print "Core temperature: '%f', median: '%f'" % (core_temp, avg)
                time.sleep(self.params["temp_sampling_time"])
        except (KeyboardInterrupt, SystemExit):
            self.core_temp_out_f.close()
            self.core_temp_params_f.close()
            os.remove(self.pid_fname)
            print "'%s': got keyboard interrupt. Exiting." % os.path.basename(__file__)
            sys.exit(0)
    
    def read_temp_params(self):
        """
        Read parameters from file and update local values.
        """
        for key, val in self.params.items():
            self.core_temp_params_f.seek(0)
            file_lines = self.core_temp_params_f.readlines()
            for line in file_lines:
                if line.find(key) == 0:
                    self.core_temp_params_f[key] = float(line.split(":")[1].strip())

if __name__ == "__main__":
    if DEBUG:
        ctrl_path_pref = ""
        hwmon_path_pref = ""
        out_path_pref = ""
    tm = temp_monitor(ctrl_path_pref, ctrl_fn, hwmon_path_pref, hwmon_fn, out_path_pref, out_fn)
    if tm.check_files():
        tm.monitor()
    else:
        sys.exit(1)
                