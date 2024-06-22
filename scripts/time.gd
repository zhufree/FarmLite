extends Node
const CYCLE_MINUTE := 60.0
const CYCLE_HOUR := 60.0
const CYCLE_DAY := 24.0

var global_time :Dictionary = {
	"hour": 0,
	"minute": 0,
	"second": 0,
}

var global_time_unix_float:float = 0.0
var paused:bool = false
var speed = 1
#TODO:下面两项和加载存档有关
var last_record_system_time_unix:int = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
var last_record_global_time_unix:int = 0

signal recalculate(period:int)

func _ready():
	var period = recalculate_time_period()
	global_time_unix_float = last_record_global_time_unix + period
	recalculate.emit(period)

func _process(delta):
	if !paused:
		#（游戏时间为现实的60倍基础上，再乘speed的倍数）
		global_time_unix_float += delta * speed * CYCLE_MINUTE 
		global_time = Time.get_datetime_dict_from_unix_time(int(global_time_unix_float))

func recalculate_time_period() -> int:
	var current_time = Time.get_datetime_dict_from_system()
	var current_time_unix = Time.get_unix_time_from_datetime_dict(current_time)
	var period = current_time_unix - last_record_system_time_unix
	return period * CYCLE_MINUTE

func time_to_string() -> String:
	return str(global_time["month"])+"-"+\
			str(global_time["day"])+"  "+\
			Time.get_time_string_from_unix_time(int(global_time_unix_float)).substr(0,5)
