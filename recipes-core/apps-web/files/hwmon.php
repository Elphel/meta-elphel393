<?php

if (isset($_GET['cmd']))
	$cmd = $_GET['cmd'];
else
	$cmd = "t";

if ($cmd=="t"){
	$t_cpu = file_get_contents("/tmp/core_temp");
	$t_10389 = "";
	$t_sda = "";
	$t_sdb = "";
	
	$temp1_input = "/sys/devices/soc0/amba@0/e0004000.ps7-i2c/i2c-0/0-001a/hwmon/hwmon0/temp1_input";
	
	if (is_file($temp1_input)){
		$t_10389 = trim(file_get_contents($temp1_input));
		$t_10389 = intval($t_10389)/1000;
	}
	
	$t_sda = exec("smartctl -A /dev/sda | egrep ^194 | awk '{print $10}'");
	if ($t_sda=="") $t_sda = "-";
	else            $t_sda = intval($t_sda);
	
	$t_sdb = exec("smartctl -A /dev/sdb | egrep ^194 | awk '{print $10}'");
	if ($t_sdb=="") $t_sdb = "-";
	else            $t_sdb = intval($t_sdb);
	
	echo "$t_cpu $t_10389 $t_sda $t_sdb";
}

if ($cmd=="read"){
	echo file_get_contents("/tmp/core_temp_params");
}

if ($cmd=="write"){
	$cstr = "";
	foreach($_GET as $key => $val){
		if(strpos($key,"temp")===0){
			$cstr .= "$key:$val\n";
		}
	}
	file_put_contents("/tmp/core_temp_params",$cstr);
	echo "$cstr";
}

?> 
