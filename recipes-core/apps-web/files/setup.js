var sensortype=14;

function init(){
	var t = $("<table>").html("\
<tr>\
  <td id='controls' valign='top'></td>\
  <td id='pic1'></td>\
  <td id='pic2'></td>\
</tr><tr>\
  <td></td>\
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
			width: "500px"
		});
		
		img.attr("src",url);
		img.attr("src_init",url);
		
		$("#pic"+(i+1)).append($("<div>").append(a.append(img)));
		
		img.load(function(){
			d = new Date();
			n = d.getTime();
			this.src = $(this).attr("src_init")+"&"+n;
		});
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
	
	tmpstr = "<tr><td>Chn&nbsp;</td><td>Test Pattern&nbsp;</td><td>Sensor Phase (0-7)&nbsp;</td></tr>";
	for(i=0;i<4;i++){
		tmpstr += "\
<tr>\
  <td valign='bottom'>"+(i+1)+"</td>\
  <td valign='bottom'><input type='checkbox' id='tp"+i+"' class='tp'/></td>\
  <td valign='bottom'><input type='text' id='sp"+i+"' value='0' class='sp'/></td>\
</tr>\
";
	
	}
	
	ct2.html(tmpstr);
	$("#controls").append(ct2);
	
	$(".tp").css({
		width:"20px",
		height:"20px"
	});
	
	$(".sp").css({
		width: "50px",
		"text-align":"right"
	});
	
	$(".tp").change(function(){
		var tmp = $(this).attr("id");
		var index = tmp[2];
		console.log("index= "+index+" state="+$(this).prop("checked"));
		send_cmd("set_test_pattern",index,$(this).prop("checked"));
	});
	
	$(".sp").change(function(){
		var tmp = $(this).attr("id");
		var index = tmp[2];
		console.log("index= "+index+" state="+$(this).val());
		send_cmd("set_sensor_phase",index,$(this).val());
	});
	
	ct3 = $("<div style='padding-top:20px;'>");
	
	var sdram_phase_button = $("<button>",{id:"sdram_phase",class:"btn btn-danger nooutline"}).html("<b>SDRAM phase scan</b> (~10-minute process)");
	
	//ct3.prepend(sdram_phase_button);
	
	$("#controls").append(ct3);

	
	init_sensor_type();
}

function send_cmd(command,index,value){
	$.ajax({
		url: "setup.php?cmd="+command+"&chn="+index+"&val="+value,
		complete: function(){
			console.log("complete");
		}
	});
}

function init_sensor_type(){
	$.ajax({
		url: "setup.php?cmd=get_sensor_type",
		complete: function(data){
			r = JSON.parse(data.responseText);
			if (r.sensortype==5){
				sensortype=5;
				$("#s5").addClass("btn-success");
				$(".sp").css({
					display:"none"
				});
			}
			if (r.sensortype==14){
				sensortype=14;
				$("#s14").addClass("btn-success");
			}
		}
	});
}