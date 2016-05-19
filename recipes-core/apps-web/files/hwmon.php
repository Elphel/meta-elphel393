<?php

if (isset($_GET['cmd']))
	$cmd = $_GET['cmd'];
else
	$cmd = "t";

if ($cmd=="t"){
	echo file_get_contents("/tmp/core_temp");
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
