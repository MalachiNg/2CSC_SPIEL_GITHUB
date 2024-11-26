extends Area2D
@onready var day_night = Global.day_and_night


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.show()
	Signals.connect("game_paused_true", animate)


func animate():
	if (Global.day_and_night % 2) == 0:  # if the "day_and_night" variable from the Globla.gd script is divisible by 2, it is night, so:
		$AnimatedSprite2D.play("Reactor_off")  # show the reactor as off
	else:  # if the variable isn't divisible by 2, then it is day so:
		$AnimatedSprite2D.play("Reactor_on")  # show the reactor as on.


func detect_player_1(body):
	if (Global.day_and_night % 2) != 0:
		return
	else:
		var fuel_requirement = (Global.day_and_night + 2) / 2
		# this line of code adds 2 to the day and night variable, and divides the resulting number by 2.
		# this results in the number of nights that the character has played, including the one they are currently playing,
		# as this code only runs during the night.
		if body.is_in_group("Player"):
			if Global.global_fuel < fuel_requirement:
				return
			elif Global.global_fuel == fuel_requirement:
				Global.update_fuel(0)
				var new_day_night = Global.day_and_night + 1
				Global.update_day_and_night(new_day_night)
				animate()


func detect_player_2(area):
	if (Global.day_and_night % 2) != 0:
		return
	else:
		var fuel_requirement = (Global.day_and_night + 2) / 2
		# this line of code adds 2 to the day and night variable, and divides the resulting number by 2.
		# this results in the number of nights that the character has played, including the one they are currently playing,
		# as this code only runs during the night.
		if area.is_in_group("Player"):
			if Global.global_fuel < fuel_requirement:
				return
			elif Global.global_fuel == fuel_requirement:
				Global.update_fuel(0)
				var new_day_night = Global.day_and_night + 1
				Global.update_day_and_night(new_day_night)
				animate()
