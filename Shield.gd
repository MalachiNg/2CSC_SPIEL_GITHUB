extends Area2D
@onready var hit = false


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_in_random_location()
	$Sprite2D.show()
	$CollisionShape2D.disabled = false
	Signals.connect("game_paused_true", spawn_in_random_location)
	if not Global.single_player:
		$Sprite2D.scale = Vector2(0.08, 0.08)
		$CollisionShape2D.scale = Vector2(1.3, 1.3) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	show_and_hide()


func show_and_hide():
	if (Global.day_and_night % 2) == 0:
		if not hit:
			$Sprite2D.show()
			$CollisionShape2D.disabled = false
	else:
		hit = false
		$Sprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)


func spawn_in_random_location():
	$Sprite2D.hide()
	var random_x = randf_range(0, 1152)
	var random_y = randf_range(0, 648)
	global_position = Vector2(random_x, random_y)


func _on_body_entered(body):
	if body.is_in_group("Player"):
		$Sprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)
		spawn_in_random_location()
		hit = true


func _on_area_entered(area):
	if area.is_in_group("Player"):
		$Sprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)
		spawn_in_random_location()
		hit = true
