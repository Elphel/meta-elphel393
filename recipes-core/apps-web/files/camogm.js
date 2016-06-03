var interval_get_files;
var interval_refresh_images;

function init(){
	var t = $("<table>").html("\
<tr>\
  <td id='controls' valign='top' rowspan='2'></td>\
  <td id='pic1'></td>\
  <td id='pic2'></td>\
</tr><tr>\
  <td id='pic3'></td>\
  <td id='pic4'></td>\
</tr>");
	$("body").append(t);
	
	var port = 2323;
	for(i=0;i<4;i++){
		
		var url = "http://"+window.location.hostname+":"+(port+i)+"/noexif/img";
		var ref = "http://"+window.location.hostname+":"+(port+i)+"/noexif/mimg";
		
		a = $("<a>",{href:ref});
		
		img = $("<img>",{id:"chn"+i}).css({
			width: "400px"
		});
		
		img.attr("src",url);
		img.attr("src_init",url);
		
		$("#pic"+(i+1)).append($("<div>").append(a.append(img)));
		
		/*
		img.load(function(){
			d = new Date();
			n = d.getTime();
			this.src = $(this).attr("src_init")+"&"+n;
		});
		*/
	}
	
	
	
	ct = $("<div style='padding-top:10px;'>");
	
	tmpstr = "<table>\
<tr>\
  <td>Sensors type:</td>\
  <td><button id='s5'><b>5 MPix</b></button></td>\
  <td><button id='s14'><b>14 MPix</b></button></td>\
</tr>\
</table>";

	ct.html(tmpstr);
	$("#controls").append(ct);
	$("#s5").addClass("btn nooutline");
	$("#s14").addClass("btn nooutline");
	
	
	ct2 = $("<div style='padding-top:20px;'>");
	
	tmpstr = "Absolute path: <input id='abspath' style='text' value='/mnt/sda1' class='ap' />";
	
	ct2.html(tmpstr);
	$("#controls").append(ct2);
	
	$(".ap").css({
		width:"150px",
		padding:"2px 5px",
		"text-align":"left"
	});
	
	$("#abspath").change(function(){
		//console.log($(this).val());
		$.ajax({url:"camogm.php?cmd=create_symlink&path="+$(this).val()});
	});
	
	ct3 = $("<div style='padding-top:20px;'>");
	
	tmpstr = "<table>\n";
	tmpstr += "<tr><td>Chn&nbsp;</td><td>Prefix&nbsp;</td><td colspan='2'>Recording</td></tr>";
	for(i=0;i<4;i++){
		tmpstr += "\
<tr>\
  <td valign='bottom'>"+(i+1)+"</td>\
  <td valign='bottom'><input type='text' id='prefix"+i+"' value='c"+(i+1)+"_' class='pfx'/></td>\
  <td valign='bottom'><button id='rec"+i+"' class='rec btn btn-success nooutline'>start</button></td>\
</tr>\
";
	}
	tmpstr += "</table>";
	
	ct3.html(tmpstr);
	$("#controls").append(ct3);
	
	$(".rec").css({
		"font-weight":"bold",
		padding:"3px 10px"
	});
	
	$(".rec").click(function(){
		$(this).toggleClass('btn-success');
		$(this).toggleClass('btn-danger');
		
		var tmp = $(this).attr("id");
		var index = tmp[3];
		
		var cmd = $(this).text();
		
		if (cmd=="start") {
			$(this).text("stop");
			console.log("starting: "+index);
		}else{
			$(this).text("start");
		}
		$.ajax({url:"camogm.php?chn="+index+"&cmd="+cmd});
	});
	
	$(".pfx").css({
		width:"50px",
		"padding-right":"3px",
		"text-align":"right"
	});
	
	
	ct4 = $("<div style='padding-top:20px;'>");
	
	tmpstr = "<table>\
<tr><td class='filelist'>Files:</td></tr>\
<tr><td class='filelist'><div id='filelist'></div></td></tr>\
</table>\
	";
	
	ct4.html(tmpstr);
	$("#controls").append(ct4);

	$(".filelist").css({
		"text-align":"left"
	});
	
	init_sensor_type();
	//init_defaults();
	init_path();
	init_files();
	init_images();
}

function init_files(){
	interval_get_files = setInterval(get_files,1000);
}

function init_images(){
	interval_refresh_images = setInterval(function(){
		for(var j=0;j<4;j++){
			d = new Date();
			n = d.getTime();
			$("#chn"+j).attr("src",$("#chn"+j).attr("src_init")+"&"+n);
		}
	},1000);
}

function get_files(){
	console.log("get files");
	$.ajax({
		url: "camogm.php?cmd=list&path="+$("#abspath").val(),
		complete: function(data){
			var xml = data.responseXML;
			var files = $(xml).find("f");
			$("#filelist").html("");
			rstr = "<ul>";
			for(var i=0;i<files.length;i++){
				var tmp = $(files[i]).text();
				tmp = tmp.substring(tmp.lastIndexOf("/")+1);
				rstr += "<li><a class='vd' href='video/"+tmp+"'>"+tmp+"</a></li>\n";
			}
			rstr += "</ul>\n";
			$("#filelist").html(rstr);
			
			$(".vd").css({
				cursor:"pointer"
			});
		}
	});
}

function init_path(){
	$.ajax({
		url:"camogm.php?cmd=list&path=/mnt",
		complete: function(data){
			var xml = data.responseXML;
			var dirs = $(xml).find("d");
			var res = false;
			for(var i=0;i<dirs.length;i++){
				var tmp = $(dirs[i]).text();
				if (tmp=="/mnt/sda1") {
					$("#abspath").val(tmp);
					init_defaults();
					res = true;
				}
			}
			if (!res){
				console.log("init path failed");
			}
		}
	});
}

function init_defaults(){
	var prefix = $("#abspath").val()+"/";
	for(var i=0;i<4;i++){
		$.ajax({url:"camogm.php?chn="+i+"&cmd=format=mov;exif=0;duration=600;length=1073741824;prefix="+prefix+$("#prefix"+i).val()});
	}
	$.ajax({url:"camogm.php?cmd=create_symlink&path="+prefix});
}

function init_sensor_type(){
	$.ajax({
		url: "setup.php?cmd=get_sensor_type",
		complete: function(data){
			r = JSON.parse(data.responseText);
			if (r.sensortype==5){
				sensortype=5;
				$("#s5").addClass("btn-success");
			}
			if (r.sensortype==14){
				sensortype=14;
				$("#s14").addClass("btn-success");
			}
		}
	});
}
