<?php

$port = 8888;

if (isset($_GET['cmd']))
	$cmd = $_GET['cmd'];
else
	$cmd = "do_nothing";

$sensor_type = get_sensor_type();
	
if ($cmd=="get_sensor_type"){
	echo json_encode(array('sensortype'=>$sensor_type));
}

if ($cmd=="set_test_pattern"){
	$chn = $_GET['chn'];
	$val = $_GET['val'];
	
	if ($sensor_type==5){
		if ($val=="true"){
			$regval = "0x90a00041";
		}else{
			$regval = "0x90a00000";
		}
	}
	if ($sensor_type==14){
		if ($val=="true"){
			$regval = "0x30700002";
		}else{
			$regval = "0x30700000";
		}
	}
	
	$str = "write_sensor_i2c $chn 1 0 $regval"."\r\n";
	
	echo send_cmd($port,$str);
	//$str = "cd /usr/local/verilog/;/usr/local/bin/test_mcntrl.py @includes -c ";
}

if ($cmd=="set_sensor_phase"){
	$chn = $_GET['chn'];
	$val = intval($_GET['val']);
	
	if ($val<0) $val=0;
	if ($val>7) $val=7;
	
		
	if ($sensor_type==14){
		$val += 8;
		$regval = "0x31c0".dechex($val)."000";
	}
	
	$str = "write_sensor_i2c $chn 1 0 $regval"."\r\n";
	send_cmd($port,$str);
	
        $str = "compressor_control $chn 1"."\r\n";
	send_cmd($port,$str);
	usleep(100000);
        $str = "compressor_control $chn 0"."\r\n";
	send_cmd($port,$str);
	usleep(100000);
	
	$str = "control_sensor_memory $chn stop"."\r\n";
	send_cmd($port,$str);
	usleep(100000);
	$str = "control_sensor_memory $chn reset"."\r\n";
	send_cmd($port,$str);
	usleep(100000);
        $str = "control_sensor_memory $chn stop"."\r\n";
	send_cmd($port,$str);
	usleep(100000);
	$str = "control_sensor_memory $chn reset"."\r\n";
	send_cmd($port,$str);
	usleep(100000);
	$str = "control_sensor_memory $chn repetitive"."\r\n";
	send_cmd($port,$str);
	//$str = "sleep_ms 500"."\r\n";
	//send_cmd($port,$str);
	usleep(500000);
	$str = "compressor_control $chn 0"."\r\n";
	send_cmd($port,$str);
	//$str = "sleep_ms 500"."\r\n";
	//send_cmd($port,$str);
	usleep(500000);
	$str = "compressor_control $chn 3"."\r\n";
	
	echo send_cmd($port,$str);
	
	/*
	$str = "cd /usr/local/verilog/;/usr/local/bin/test_mcntrl.py @includes \
	-c write_sensor_i2c $chn 1 0 $regval\
	-c compressor_control $chn 1\
	-c control_sensor_memory $chn stop\
	-c control_sensor_memory $chn reset\
	-c control_sensor_memory $chn repetitive\
	-c sleep_ms 500\
	-c compressor_control $chn 0\
	-c sleep_ms 500\
	-c compressor_control $chn 3\
	";
	
	echo $str;
	exec($str);
	*/
}

if ($cmd=="find_sdram_phase"){
        $chn = $_GET['chn'];
	$str  = "compressor_control $chn 1"."\r\n";
	$str .= "compressor_control $chn 0"."\r\n";
	$str .= "control_sensor_memory $chn stop"."\r\n";
	$str .= "control_sensor_memory $chn reset"."\r\n";
	$str .= "measure_all \"*DI\""."\r\n";
	$str .= "measure_all"."\r\n";
	$str .= "control_sensor_memory $chn repetitive"."\r\n";
	$str .= "compressor_control $chn 3"."\r\n";
	
	echo send_cmd($port,$str);

	/*
	$str = "cd /usr/local/verilog/;/usr/local/bin/test_mcntrl.py @includes \
	-c compressor_control $chn 1\
	-c compressor_control $chn 0\
	-c control_sensor_memory $chn stop\
	-c control_sensor_memory $chn reset\
	-c measure_all \"*DI\"
	-c measure_all
	-c control_sensor_memory $chn repetitive\
	-c compressor_control $chn 3\
	";
	
	echo $str;
	exec($str);
	*/
}

function get_sensor_type(){
	$lastline = exec("cat /etc/init_elphel393.sh | grep \"SENSOR_TYPE=\"");
	$res = explode("=",$lastline);
	$res[1] = intval($res[1]);
	if (($res[1]!=5)&&($res[1]!=14)) $res[1]=0;
	return $res[1];
}

function send_cmd($port,$msg){
	$fp = fsockopen("localhost", $port, $errno, $errstr, 30);

	if (!$fp) {
		return "$errstr ($errno)<br />\n";
	}else{
		fwrite($fp,"$msg\r\n");
		fclose($fp);
		echo "sent: $msg";
		usleep(100);
	}
}

?>
