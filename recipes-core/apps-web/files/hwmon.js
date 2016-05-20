$(function(){
	//init();
});

var interval_read_temperature;

var d0 = Array.apply(null, Array(600)).map(Number.prototype.valueOf,0);
var d1 = Array.apply(null, Array(600)).map(Number.prototype.valueOf,0);
var d2 = Array.apply(null, Array(600)).map(Number.prototype.valueOf,0);
var d3 = Array.apply(null, Array(600)).map(Number.prototype.valueOf,0);
var t = Array();

var level_shutdown;
var level_fan_on;
var level_fan_hyst;

var options = {
	lines: { show: true },
	points: { show: false },
	xaxis: { 
		tickDecimals: 0,
		tickSize: 1
	},
	yaxis: {
		min: 0,
		max: 100
	},
	colors: ['rgba(255,100,100,0.5)','rgba(255,150,20,0.5)','rgba(100,255,100,0.5)','black'],
	legend:{
	    position: "nw"
	},
};

function init(){
	console.log("hwmon init()");
	
	var tc = $("#t_chart");
	
	tc.css({
		width: "800px",
		height: "600px",
		background:"rgba(100,100,100,0.0)"
	});
	
	read_params(init_fields);
}

function init_fields(){
	$("#t_shutdown").val(level_shutdown);
	$("#t_fan_on").val(level_fan_on);
	$("#t_fan_hyst").val(level_fan_hyst);
	$("#scan_period").val(scan_period);
	
	$(".pars").change(function(){
		update_params();
	});
	
	interval_read_temperature = setInterval(read_core_temp,scan_period*1000);
}

function update_params(){
	level_shutdown = parseFloat($("#t_shutdown").val());
	level_fan_on = parseFloat($("#t_fan_on").val());
	level_fan_hyst = parseFloat($("#t_fan_hyst").val());
	scan_period = parseFloat($("#scan_period").val());
	
	$.ajax({
		url: "hwmon.php?cmd=write&temp_sampling_time="+scan_period+"&temp_major="+level_shutdown+"&temp_minor="+level_fan_on+"&temp_hyst="+level_fan_hyst,
		complete: function(){
			console.log("parameters updated");
			clearInterval(interval_read_temperature);
			interval_read_temperature = setInterval(read_core_temp,scan_period*1000);
		}
	});
}

function read_params(callback){
	$.ajax({
		url: "hwmon.php?cmd=read",
		complete: function(data){
			var tmp_str = data.responseText;
			tmp_str = tmp_str.trim();
			var tmp_arr = tmp_str.split(/\n|: /);
			for (var i=0;i<tmp_arr.length;i++){
				switch(tmp_arr[i]){
					case "temp_sampling_time":
						scan_period = parseFloat(tmp_arr[i+1]);
						break;
					case "temp_major":
						level_shutdown = parseFloat(tmp_arr[i+1]);
						break;
					case "temp_minor":
						level_fan_on = parseFloat(tmp_arr[i+1]);
						break;
					case "temp_hyst":
						level_fan_hyst = parseFloat(tmp_arr[i+1]);
						break;
					default:
						break;
				}
			}
			callback();
		}
	});
}

function read_core_temp(){
	$.ajax({
		url: "hwmon.php?cmd=t",
		complete: function(data){
			console.log(data.responseText);
			//t.push(d1.length);
			d0.splice(0,1);
			d0.push(level_shutdown);
			d1.splice(0,1);
			d1.push(level_fan_on);
			d2.splice(0,1);
			d2.push(level_fan_on-level_fan_hyst);
			d3.splice(0,1);
			d3.push(data.responseText);
			options.xaxis.tickSize = Math.max(1,Math.round(d1.length)/10);
			$.plot($("#t_chart"), [
				{label: "Shutdown level", data: get_data(t,d0)},
				{label: "Fan-On level",  data: get_data(t,d1)},
				{label: "Fan-Off level", data: get_data(t,d2)},
				{label: "CPU", data: get_data(t,d3)},
			], options);
		}
	});
}

function get_data(x,y){
	var d = Array();
	for (var i=0;i<y.length; i++){
        d.push([i, y[i]]);
	}
	return d;
}