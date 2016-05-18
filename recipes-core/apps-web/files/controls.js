$(function(){
	//init();
});

function init(){
	
	var t = $("<table>").html("<tr><td id='pics'></td><td id='controls' valign='top'></td></tr>");
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
		
		$("#pics").append($("<div>").append(a.append(img)));
		
		img.load(function(){
			d = new Date();
			n = d.getTime();
			this.src = $(this).attr("src_init")+"&"+n;
		});
		
	}
	
	ct = $("<table>");
	
	tmpstr = "<tr><td>Chn</td><td>Exposure,ms</td><td>WB</td><td>Quality,%</td></tr>";
	for(i=0;i<4;i++){
		tmpstr += "<tr>\
<td>"+(i+1)+"</td>\
<td><input type='text' id='exp"+i+"' class='exp' value='1' /></td>\
<td>\
  <input type='text' id='r"+i+"' class='gain r' value='13' />\
  <input type='text' id='gr"+i+"' class='gain g' value='10' />\
  <input type='text' id='b"+i+"' class='gain b' value='12' />\
  <input type='text' id='gb"+i+"' class='gain g' value='10' />\
</td>\
<td><input type='text' id='q"+i+"' class='exp' value='80'/></td>\
</tr>";
	}
	
	ct.html(tmpstr);
	$("#controls").append(ct);

	for(i=0;i<4;i++){
		$("#exp"+i).attr("index",i);
		$("#exp"+i).change(function(){
			var exp = Math.round(parseInt($(this).val())*1000/33.5);
			$.ajax({
				url: "imgsrv.py?expos="+exp+"&flip_x=0&flip_y=0&channel="+$(this).attr("index"),
				complete: function(){console.log("exposure set");}
			});
		});
		$("#q"+i).attr("index",i);
		$("#q"+i).change(function(){
			$.ajax({
				url: "imgsrv.py?y_quality="+$(this).val()+"&flip_x=0&flip_y=0&channel="+$(this).attr("index"),
				complete: function(){console.log("quality set");}
			});
		});
		$("#r"+i).attr("index",i);
		$("#r"+i).change(function(){
			$.ajax({
				url: "imgsrv.py?gain_r="+$(this).val()+"&flip_x=0&flip_y=0&channel="+$(this).attr("index"),
				complete: function(){console.log("gain_r set");}
			});
		});
		$("#gr"+i).attr("index",i);
		$("#gr"+i).change(function(){
			$.ajax({
				url: "imgsrv.py?gain_gr="+$(this).val()+"&flip_x=0&flip_y=0&channel="+$(this).attr("index"),
				complete: function(){console.log("gain_gr set");}
			});
		});
		$("#b"+i).attr("index",i);
		$("#b"+i).change(function(){
			$.ajax({
				url: "imgsrv.py?gain_b="+$(this).val()+"&flip_x=0&flip_y=0&channel="+$(this).attr("index"),
				complete: function(){console.log("gain_b set");}
			});
		});
        $("#gb"+i).attr("index",i);
        $("#gb"+i).change(function(){
            $.ajax({
                url: "imgsrv.py?gain_gb="+$(this).val()+"&flip_x=0&flip_y=0&channel="+$(this).attr("index"),
                complete: function(){console.log("gain_gb set");}
            });
        });
	}

}