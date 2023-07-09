extends Node

const best_time_file_path := "user://best-time.dat"
var best_time_file: FileAccess

var best_times := {}

func sync():
	best_time_file.seek(0)
	best_time_file.store_var(best_times)
	best_time_file.flush()

func _ready():
	if FileAccess.file_exists(best_time_file_path):
		var file := FileAccess.open(best_time_file_path, FileAccess.READ)
		
		var data = file.get_var()
		best_times = data if data is Dictionary else {}
		
		file.close()
	best_time_file = FileAccess.open(best_time_file_path, FileAccess.WRITE)
	if best_times != {}:
		sync()

func format_number(n: int, size: int) -> String:
	var result := str(n)
	
	while (result.length() < size):
		result = "0" + result
	
	return result

func format_time(time_sec: float) -> String:
	# MM:SS:MS
	var minutes := (time_sec / 60) as int
	var seconds := (time_sec as int) % 60
	var millis := ((time_sec - floor(time_sec)) * 1000) as int
	
	return "{m}:{s}.{ms}".format({
		"m": format_number(minutes, 2), 
		"s": format_number(seconds, 2), 
		"ms": format_number(millis, 3)
	})
