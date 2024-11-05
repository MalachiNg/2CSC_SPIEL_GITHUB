extends Area2D
@onready var min_x = 50  # the minimum x co-ordinate the player can be in as long as they stay in the map.
@onready var max_x = 1052  # the maximum x co-ord
@onready var min_y = 50  # min y co-ord
@onready var max_y = 608  # max y co-ord
@onready var hit = false


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_in_random_location()
	$Sprite2D.show()
	$CollisionShape2D.disabled = false
	Signals.connect("game_paused_true", game_paused_true)
	Signals.connect("game_paused_false", game_paused_false)


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
	var random_x = randf_range(min_x, max_x)
	var random_y = randf_range(min_y, max_y)
	position = Vector2(random_x, random_y)


func game_paused_true():
	$PointLight2D.position = Vector2(0, 0)
	$Sprite2D.scale = Vector2(0.04, 0.04)
	$PointLight2D.show()


func game_paused_false():
	$PointLight2D.hide()
	$Sprite2D.scale = Vector2(0.01, 0.01)


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
