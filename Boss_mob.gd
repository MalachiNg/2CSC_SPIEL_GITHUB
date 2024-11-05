extends CharacterBody2D  # using a 2D environment.
@onready var speed: float = 10
@onready var target_position: Vector2 = Vector2.ZERO
@onready var player_pos: Vector2 = Vector2.ZERO
@onready var direction: Vector2 = Vector2.ZERO  # instead of DOWN as it is in player, as the player automatically starts moving down, this is set to ZERO, so the variable only measures the direction.
@onready var min_x = 0  # the minimum x co-ordinate the player can be in as long as they stay in the map.
@onready var max_x = 1152  # the maximum x co-ord
@onready var min_y = 0  # min y co-ord
@onready var max_y = 648  # max y co-ord
@onready var player_target_position = Vector2.ZERO
@onready var player_2_pos = Vector2.ZERO
@onready var player_2_target_position = Vector2.ZERO
@onready var despawned_tonight = false
@onready var spawned_today = false
@onready var angle : int
@onready var single_player = Global.single_player

func _ready():
	Signals.connect("game_paused_true", spawn_in_random_location)
	if not Global.Normal_mode:
		speed *= 1.2  # makes the speed 20% faster if the user selects hard mode.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	move_to_player()
	hide_during_day()
	player_pos = Global.player_position # updating this in process, so the whole script is always up to date. 
	if not single_player:
		player_2_pos = Global.player_2_position # updating this in process, so the whole script is always up to date. 
		if global_position.distance_to(player_pos) > global_position.distance_to(player_2_pos) and player_2_pos != Vector2(-1, -1): 
			# Closer to player 2, and player 2 isn't dead.
			animate_moving_to_player_2()
		elif global_position.distance_to(player_pos) < global_position.distance_to(player_2_pos) and player_pos != Vector2(-1, -1): 
			# Closer to player 1 or they have the same position:
			animate_moving_to_player_1()
	else:
		animate_moving_to_player_1()


func move_to_player():
	if Global.single_player:
		if (Global.day_and_night % 2) == 0:  # ensures the mob only moves during the night.
			# and this corresponds to the other piece of code in the player.gd script, this one accessing the position from the global script.
			player_target_position = (player_pos - global_position).normalized()

			if global_position.distance_to(player_pos) > 3:
				velocity = player_target_position * (speed * (1 + (Global.day_and_night) * 0.05))  # increases speed as game progresses.
				move_and_slide()
	else:
		if (Global.day_and_night % 2) == 0:
			# ensures the mob only moves during the night.
			# and this corresponds to the other piece of code in the player.gd script, this one accessing the position from the global script.
			# this is the same as for player 1 position, but accessing fromg Global player 2's position, as it is provided into global from player 2's process function.
			player_target_position = (player_pos - global_position).normalized()
			# this gets the target position for the mob to move towards player 1.
			player_2_target_position = (player_2_pos - global_position).normalized()
			# this does the same thing, for player 2.

			if (
				global_position.distance_to(player_pos) > global_position.distance_to(player_2_pos)
				and global_position.distance_to(player_pos) > 3
				and player_2_pos != Vector2(-1, -1)
			):  # this parameter set checks if player 1 or 2 is closer to the mob, and chases player 1 if it's closer. it also ensures that the player isn't less than 3 away to keep from being inside the player. Finally, the last part checks if the player position is -1, -1, which is set once the player is dead and only possible then, as the position is clamped, so will only follow the closer player if the closer player is alive.
				velocity = player_2_target_position * (speed * (1 + (Global.day_and_night) * 0.05))
				# increases speed as game progresses.
				move_and_slide()
			elif (
				global_position.distance_to(player_2_pos) > global_position.distance_to(player_pos)
				and global_position.distance_to(player_2_pos) > 3
				and player_pos != Vector2(-1, -1)
			):  # this parameter set pretty much does the same thing as the last, but makes the mob move towards the player 2 if it's closer.
				velocity = player_target_position * (speed * (1 + (Global.day_and_night) * 0.05))
				# increases speed as game progresses.
				move_and_slide()
			elif player_2_pos == Vector2(-1, -1):  # if player 2 is dead, (since they move to -1, -1 when dead,
				# and can't go there otherwise, then.
				velocity = player_target_position * (speed * (1 + (Global.day_and_night) * 0.05))  # move to player 1.
				move_and_slide()
			elif player_pos == Vector2(-1, -1):  # if player 1 is dead, then:
				velocity = player_2_target_position * (speed * (1 + (Global.day_and_night) * 0.05))  # move to player 2.
				move_and_slide()
			elif (
				global_position.distance_to(player_2_pos) == global_position.distance_to(player_pos)
			):
				# when player positions are the same (this addresses an issue where mobs would stop when both players were in teh same place), then:
				velocity = player_target_position * (speed * (1 + (Global.day_and_night) * 0.05))
				# move toward player 1. (or 2, makes absolutely no difference)
				move_and_slide()


func hide_during_day():
	if (Global.day_and_night % 2) != 0 and not despawned_tonight:  # if it is day and this hasn't run before:
		despawned_tonight = true  # prevents this section from running again.
		spawned_today = false  # allows the next section to run once during night.
		$AnimatedSprite2D.hide()  # hide
		$CollisionShape2D.set_deferred("disabled", true)  # disable Collision Shape.
		# this section is put here, as variables like spawned_today mean that it isn't running always.
		# Also, a reccurring error in the previous version of this code, where the code here was in the later section.
		# This error meant that if the user changed to day in the time between the end of the 0.15 seconds,
		# and the start of the next calling of first_value, then:
		# the mobs would freeze, yet still be visible and touchable.
		# this solves that error, without also making it less optimised.
	elif (Global.day_and_night % 2) == 0 and not spawned_today:
		spawned_today = true  # prevents this running again.
		despawned_tonight = false  # allows the last section to run again during day.
		$AnimatedSprite2D.show()
		$CollisionShape2D.set_deferred("disabled", false)


func spawn_in_random_location():  # this spawns the mob in a reandom location, which is no more than 150 away from the player,
	# to keep things fair.
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
			$CollisionShape2D.set_deferred("disabled", false) # re enable collisions. 
		else: # if the mob is in the 200 radius:
			spawn_in_random_location() # try again. 
			return # prevent running further, pretty pointless since theres nothing more but still!

func animate_moving_to_player_1(): 
		var player_position = player_pos-global_position
		var distance_to_player = global_position.distance_to(player_pos)
		# and now we have sufficient data to use the sine rules of trigenometry to find the angle to the mouse,
		# because in-built functions fail to do so effectively. 
		# asin() means inverse sin or sin^-1. 
		angle = rad_to_deg(asin((abs(player_position.x))/distance_to_player))
		if player_position.y > 0:
			# DOWN
			if player_position.x > 0:
				# RIGHT
				if angle > 15 and angle < 75:
					$AnimatedSprite2D.play("move_down_right")
				elif angle > 75:
					$AnimatedSprite2D.play("move_right")
				else:
					$AnimatedSprite2D.play("move_down")
			elif player_position.x < 0:
				# LEFT
				if angle > 15 and angle < 75:
					$AnimatedSprite2D.play("move_down_left")
				elif angle > 75:
					$AnimatedSprite2D.play("move_left")
				else:
					$AnimatedSprite2D.play("move_down")
		elif player_position.y < 0:
			# UP
			if player_position.x > 0:
				# RIGHT
				if angle > 15 and angle < 75:
					$AnimatedSprite2D.play("move_up_right")
				elif angle > 75:
					$AnimatedSprite2D.play("move_right")
				else:
					$AnimatedSprite2D.play("move_up")
			elif player_position.x < 0:
				# LEFT
				if angle > 15 and angle < 75:
					$AnimatedSprite2D.play("move_up_left")
				elif angle > 75:
					$AnimatedSprite2D.play("move_left")
				else:
					$AnimatedSprite2D.play("move_up")
		else:
			# JUST LEFT OR RIGHT
			if player_position.x > 0:
				# RIGHT
				$AnimatedSprite2D.play("move_right")
			else:
				# LEFT
				$AnimatedSprite2D.play("move_left")


func animate_moving_to_player_2(): 
		var player_2_position = player_2_pos-global_position
		var distance_to_player_2 = global_position.distance_to(player_2_pos)
		# and now we have sufficient data to use the sine rules of trigenometry to find the angle to the mouse,
		# because in-built functions fail to do so effectively. 
		# asin() means inverse sin or sin^-1. 
		angle = rad_to_deg(asin((abs(player_2_position.x))/distance_to_player_2))
		if player_2_position.y > 0:
			# DOWN
			if player_2_position.x > 0:
				# RIGHT
				if angle > 15 and angle < 75:
					$AnimatedSprite2D.play("move_down_right")
				elif angle > 75:
					$AnimatedSprite2D.play("move_right")
				else:
					$AnimatedSprite2D.play("move_down")
			elif player_2_position.x < 0:
				# LEFT
				if angle > 15 and angle < 75:
					$AnimatedSprite2D.play("move_down_left")
				elif angle > 75:
					$AnimatedSprite2D.play("move_left")
				else:
					$AnimatedSprite2D.play("move_down")
		elif player_2_position.y < 0:
			# UP
			if player_2_position.x > 0:
				# RIGHT
				if angle > 15 and angle < 75:
					$AnimatedSprite2D.play("move_up_right")
				elif angle > 75:
					$AnimatedSprite2D.play("move_right")
				else:
					$AnimatedSprite2D.play("move_up")
			elif player_2_position.x < 0:
				# LEFT
				if angle > 15 and angle < 75:
					$AnimatedSprite2D.play("move_up_left")
				elif angle > 75:
					$AnimatedSprite2D.play("move_left")
				else:
					$AnimatedSprite2D.play("move_up")
		else:
			# JUST LEFT OR RIGHT
			if player_2_position.x > 0:
				# RIGHT
				$AnimatedSprite2D.play("move_right")
			else:
				# LEFT
				$AnimatedSprite2D.play("move_left")
			
