<?php
/*
*!******************************************************************************
*! File: camogm.php
*! Description: command interface for the camogm recorder based on 
*! http://elphel.cvs.sourceforge.net/viewvc/elphel/elphel353-8.0/packages/web/353/camogmgui/camogm_interface.php?revision=1.23&content-type=text%2Fplain
*!
*! Copyright (C) 2016 Elphel, Inc
*! -----------------------------------------------------------------------------**
*!  This program is free software: you can redistribute it and/or modify
*!  it under the terms of the GNU General Public License as published by
*!  the Free Software Foundation, either version 3 of the License, or
*!  (at your option) any later version.
*!
*!  This program is distributed in the hope that it will be useful,
*!  but WITHOUT ANY WARRANTY; without even the implied warranty of
*!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*!  GNU General Public License for more details.
*!
*!  You should have received a copy of the GNU General Public License
*!  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*! -----------------------------------------------------------------------------**
*/

$chn = 0;
$cmd = "donothing";
$debug = false;
$debuglev = 6;

if (isset($_GET['chn']))      $chn      = $_GET['chn'];
if (isset($_GET['cmd']))      $cmd      = $_GET['cmd'];
if (isset($_GET['debug'])   ) $debug    = $_GET['debug'];
if (isset($_GET['debuglev'])) $debuglev = $_GET['debuglev'];

$r_pipe="/tmp/camogm$chn.status";
$c_pipe="/var/volatile/camogm_cmd$chn";

if ($cmd=="status"){
	$mode=0777;
	if(!is_file($r_pipe)){
		umask(0);
		posix_mkfifo($r_pipe,$mode);
	}
	$fcmd=fopen($c_pipe,"w");
	fprintf($fcmd, "xstatus=%s\n",$r_pipe);
	fclose($fcmd);
	
	$res=file_get_contents($r_pipe);
	xml_response($res);
}

if ($cmd=="list") {
	$res="";
	if (isset($_GET['path'])) $path = $_GET['path'];
	else {
	    $res = "<res>the path is not set</res>\n";
	}
	if (is_dir($path)) {
	    $files = scandir($path);
	    foreach ($files as $file){
			if (is_file("$path/$file")) $res .= "<f>$path/$file</f>\n";
			if (is_dir("$path/$file"))  $res .= "<d>$path/$file</d>\n";
	    }
	}else{
	    $res = "<res>directory not found</res>\n";
	}
	xml_response("<camogm>\n$res</camogm>\n",true);
}

if ($cmd=="create_symlink"){
	if (isset($_GET['path'])) {
		$path = $_GET['path'];
		if (is_dir($path)){
			//exec("ln -sf $path /www/pages/video;sync");
			exec("ln -sf $path /tmp/video");
		}
	}
}
//camogm pipe commands

$fcmd = fopen($c_pipe, "w");

if ($cmd=="start"){
	fprintf($fcmd,"start;\n");
}else if ($cmd=="stop"){
	fprintf($fcmd,"stop;\n");
	exec('sync');
}else if ($cmd=="exit"){
	fprintf($fcmd,"exit;\n");
	exec('sync');
}else if ($cmd=="default"){
	fprintf($fcmd,"format=mov;exif=0;prefix=/tmp/mnt/sda1/;\n");
}else{
	fprintf($fcmd,"$cmd\n");
	//exec('sync');
}

fclose($fcmd);

$res  = "<channel>$chn</channel>\n";
$res .= "<cmd>$cmd</cmd>\n";
xml_response("<camogm>\n$res</camogm>\n",true);
die("done");

function xml_response($msg,$addheader=false){
	if ($addheader) $msg = "<?xml version='1.0' standalone='yes' ?>\n$msg";
	header("Content-Type: text/xml");
	header("Content-Length: ".strlen($msg)."\n");
	header("Pragma: no-cache\n");
	echo $msg;
	flush();
	die();
}

?> 
