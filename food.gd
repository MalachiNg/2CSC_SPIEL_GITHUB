extends Area2D
@onready var food: int
@onready var show_at_day = Global.day_and_night
@onready var skins = {  # HERE IS MY DICTIONARY!!! (:-D)
	0: "apple",
	1: "burger",
	2: "chicken_drumstick",
	3: "doughnut",
	4: "pear",
}
@onready var skin_num: int
@onready var spawned_today = false


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_in_random_location()
	$CollisionShape2D.set_deferred("disabled", true)
	show_skin()
	Signals.connect("game_paused_true", spawn_in_random_location)
	# the above line of code makes food move to a new location when the night starts.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.game_over:
		$AnimatedSprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)
	else:
		show_and_hide()


func show_and_hide():
	show_at_day = Global.day_and_night
	if (show_at_day % 2) != 0:
		if spawned_today:
			return
		else:
			spawned_today = true
			$AnimatedSprite2D.show()
			$CollisionShape2D.set_deferred("disabled", false)
	else:
		$AnimatedSprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)
		spawned_today = false


func show_skin():
	skin_num = randi_range(0, 4)
	var skin = skins[skin_num]
	$AnimatedSprite2D.play(skin)


func spawn_in_random_location():
	$AnimatedSprite2D.hide()  # prevents a bug where food can be visible in the cutscenes beyond the first night.
	# Therefore I have moved the animatedsprite2d.hide() line from ready to here, so it prevents this error every time, not just the first night.
	var random_x = randf_range(0, 2304)
	var random_y = randf_range(0, 1296)
	global_position = Vector2(random_x, random_y)


func _on_body_entered(body):
	if body.is_in_group("Player"):
		$AnimatedSprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)


func _on_area_entered(area):
	if area.is_in_group("Player"):
		$AnimatedSprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)
