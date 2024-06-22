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
var last_record_system_time:int = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())

signal tick_minute
signal recalculate(period)

func _ready():
	global_time_unix_float = float(Time.get_unix_time_from_datetime_dict(global_time))
	_recalculate_time()
	

func _process(delta):
	if !paused:
		global_time_unix_float += delta * speed * CYCLE_MINUTE
		global_time = Time.get_datetime_dict_from_unix_time(int(global_time_unix_float))

func _recalculate_time():
	var current_time = Time.get_datetime_dict_from_system()
	var current_time_unix = Time.get_unix_time_from_datetime_dict(current_time)
	var period = current_time_unix - last_record_system_time
	global_time_unix_float += period * 60

func time_to_string() -> String:
	return str(global_time["month"])+"月"+\
			str(global_time["day"])+"日 "+\
			Time.get_time_string_from_unix_time(float(global_time_unix_float)).substr(0,5)
