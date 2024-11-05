extends Area2D
@onready var food: int
@onready var show_at_day = Global.day_and_night
@onready var spawned_today = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect("game_paused_true", spawn_in_random_location)
	$AnimatedSprite2D.show() # CHANGE BACK TO HIDE, THIS IS FOR DEBUGGING.
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("Bomb")
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.game_over:
		$AnimatedSprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)
	else:
		show_and_hide()


func show_and_hide():
	show_at_day = Global.day_and_night
	if (show_at_day % 2) == 0:
		if spawned_today:
			return
		else:
			spawned_today = true
			$AnimatedSprite2D.show()
			$AnimatedSprite2D.play("Bomb") # make it a bomb, not an explosion if it has blown up before.
			$AnimatedSprite2D.stop() # stop the continuous refresh of the animation, to the same thing. (waste of processing)
			$CollisionShape2D.set_deferred("disabled", false)
	elif (show_at_day % 2) != 0 and spawned_today: # it only runs once every day:
		$AnimatedSprite2D.hide() 
		$CollisionShape2D.set_deferred("disabled", true)
		spawned_today = false


func spawn_in_random_location():
	$AnimatedSprite2D.hide()
	$CollisionShape2D.set_deferred("disabled", true) # this deactivates the collisions so mob wont collide with player during this code.
	# this spawns the mob in a reandom location, which is no more than 200 pixels away from the player,
	# to keep things fair. otherwise mobs will spawn on the player and instantly kill them, which sucks!
	var random_x = randf_range(0, 1152)  # generates a random x value within the co-ordinates of the map.
	var random_y = randf_range(0, 648)  # generates a random y value within the co-ordinates of the map.
	var distance_to_player : float
	var distance_to_player_2 : float
	global_position = Vector2(random_x, random_y) # This sets the random numbers to the global position.
	# this was not previously how the code worked, however problems aroused from using Vector2(randx, randy).distance_to(player_pos),
	# because of position, vs global position, etc. therefore by making the random position global, no problems!
	distance_to_player = global_position.distance_to(Global.player_position) # sets the distance to variable a value. 
	# as previously mentioned this accesses the position directly from Global now, as during the day (when this runs) 
	# player positions aren't updated to optimise the code, so won't be accurate. 
	# The above finds the distance from the random mob position to the player.
	if not Global.single_player: # runs in multiplayer: 
		distance_to_player_2 = global_position.distance_to(Global.player_2_position) # sets distance_to_player_2 a value.
		if distance_to_player > 200 and distance_to_player_2 > 200: # if the mobs is not in either player's 200 radius:
			$CollisionShape2D.set_deferred("disabled", false) # enable the collision shape, as the mob is allowed to stay here. 
		else: # if the mob is in the 200 radius of either player, then:
			spawn_in_random_location() # run the code again, this will loop until the mobs spawn somewhere they are allowed to.
			return # prevent this run of the function from continuing to run.
	else: # if single player:
		if distance_to_player > 200: # if the mobs aren't in the player's 200 radius:
			$CollisionShape2D.set_deferred("disabled", false) # mob can spawn here so re enable collisions. 
		else: # if the mob is in the 200 radius:
			spawn_in_random_location() # try again. 
			return # prevent running further, pretty pointless since theres nothing more but still!


func _on_body_entered(body):
	if body.is_in_group("Player"):
		$AnimatedSprite2D.scale = Vector2(0.1,0.1)
		$AnimatedSprite2D.play("Explosion")
		await get_tree().create_timer(0.7).timeout # wait for the animation to play once.
		$AnimatedSprite2D.hide()
		$AnimatedSprite2D.scale = Vector2(0.02,0.02)


func _on_body_exited(body):
	if body.is_in_group("Player"):
		$CollisionShape2D.set_deferred("disabled", true)


func _on_area_entered(area):
	if area.is_in_group("Player"):
		$AnimatedSprite2D.scale = Vector2(0.1,0.1)
		$AnimatedSprite2D.play("Explosion")
		await get_tree().create_timer(0.7).timeout # wait for the animation to play once.
		$AnimatedSprite2D.hide()
		$AnimatedSprite2D.scale = Vector2(0.02,0.02)


func _on_area_exited(area):
	if area.is_in_group("Player"):
		$CollisionShape2D.set_deferred("disabled", true)
