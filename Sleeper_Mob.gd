extends CharacterBody2D  # using a 2D environment.
@onready var speed = 60  # slowed down as 150 was too difficult for players to evade, especially since speed increases.
# then even further slowed down in response to feedback to make the game slower, to cater to the target demographic.
@onready var player_target_position: Vector2 = Vector2.ZERO
@onready var player_2_target_position: Vector2 = Vector2.ZERO
@onready var player_pos: Vector2 = Vector2.ZERO
@onready var player_2_pos: Vector2 = Vector2.ZERO
@onready var spawned_today = false
@onready var spawn_and_despawn_called = false
@onready var player_in_proximity = false
@onready var despawned_tonight = false


func _ready():
	Signals.connect("game_paused_true", game_paused_true)
	Signals.connect("game_paused_false", game_paused_false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.game_over:
		$AnimatedSprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)
		$Proximity_Area2D/Proximity_CollisionShape2D.set_deferred("disabled", true)  # disable the proximity collisionshape.
	else:
		spawn_and_despawn()
		if player_in_proximity:
			move_to_player()


func move_to_player():
	if Global.single_player:
		if (Global.day_and_night % 2) == 0:  # ensures the mob only moves during the night.
			player_pos = Global.player_position  # and this corresponds to the other piece of code in the player.gd script,
			# this one accessing the position from the global script.
			player_target_position = (player_pos - global_position).normalized()

			if global_position.distance_to(player_pos) > 3:
				velocity = player_target_position * (speed * (1 + (Global.day_and_night) * 0.05))
				# increases speed as game progresses.
				move_and_slide()
				if (player_pos.x - global_position.x) < 0:  # if the player's x co -ord is less than sleeper mob's:
					$AnimatedSprite2D.play("move_left")  # this means player is to the left,
					# so play the corresponding animation.
				else:
					$AnimatedSprite2D.play("move_right")  # if not, move right.
	else:
		if (Global.day_and_night % 2) == 0:  # ensures the mob only moves during the night.
			player_pos = Global.player_position  # and this corresponds to the other piece of code in the player.gd script,
			# this one accessing the position from the global script.
			player_2_pos = Global.player_2_position  # this is the same as for player 1 position,
			# but accessing fromg Global player 2's position, as it is provided into global from player 2's process function.
			player_target_position = (player_pos - global_position).normalized()
			# this gets the target position for the mob to move towards player 1.
			player_2_target_position = (player_2_pos - global_position).normalized()
			# this does the same thing, for player 2.

			if (
				global_position.distance_to(player_pos) > global_position.distance_to(player_2_pos)
				and global_position.distance_to(player_pos) > 3
				and player_2_pos != Vector2(-1, -1)
			):
				# this parameter set checks if player 1 or 2 is closer to the mob, and chases player 2 if it's closer.
				# it also ensures that the player isn't less than 3 away to keep from being inside the player.
				# Finally, the last part checks if the player position is -1, -1,
				# which is set once the player is dead and only possible then, as the position is clamped,
				# so will only follow the closer player if the closer player is alive.
				velocity = player_2_target_position * (speed * (1 + (Global.day_and_night) * 0.05))
				# increases speed as game progresses.
				move_and_slide()
				if (player_2_pos.x - global_position.x) < 0:  # if the player 2's x co -ord is less than sleeper mob's:
					$AnimatedSprite2D.play("move_left")  # this means player 2 is to the left,
					# so play the corresponding animation.
				else:
					$AnimatedSprite2D.play("move_right")  # if not, move right.
			elif (
				global_position.distance_to(player_2_pos) > global_position.distance_to(player_pos)
				and global_position.distance_to(player_2_pos) > 3
				and player_pos != Vector2(-1, -1)
			):
				# this parameter set pretty much does the same thing as the last,
				# but makes the mob move towards the player 2 if it's closer.
				velocity = player_target_position * (speed * (1 + (Global.day_and_night) * 0.05))
				# increases speed as game progresses.
				move_and_slide()
				if (player_pos.x - global_position.x) < 0:  # if the player 2's x co -ord is less than sleeper mob's:
					$AnimatedSprite2D.play("move_left")  # this means player 2 is to the left,
					# so play the corresponding animation.
				else:
					$AnimatedSprite2D.play("move_right")  # if not, move right.
			elif (
				global_position.distance_to(player_2_pos) == global_position.distance_to(player_pos)
			):
				# when player positions are the same
				# (this addresses an issue where mobs would stop when both players were in teh same place), then:
				velocity = player_2_target_position * (speed * (1 + (Global.day_and_night) * 0.05))
				# move toward player 1. (or 2, makes absolutely no difference)
				move_and_slide()
				if (player_pos.x - global_position.x) < 0:  # if the player 2's x co -ord is less than sleeper mob's:
					$AnimatedSprite2D.play("move_left")  # this means player 2 is to the left, so play the corresponding animation.
				else:
					$AnimatedSprite2D.play("move_right")  # if not, move right.
			elif player_2_pos == Vector2(-1, -1):  # if player 2 is dead, (since they move to -1, -1 when dead, and can't go there otherwise, then.
				velocity = player_target_position * (speed * (1 + (Global.day_and_night) * 0.05))  # move to player 1.
				move_and_slide()
				if (player_pos.x - global_position.x) < 0:  # if the player 2's x co -ord is less than sleeper mob's:
					$AnimatedSprite2D.play("move_left")  # this means player 2 is to the left,
					# so play the corresponding animation.
				else:
					$AnimatedSprite2D.play("move_right")  # if not, move right.
			elif player_pos == Vector2(-1, -1):  # if player 1 is dead, then:
				velocity = player_2_target_position * (speed * (1 + (Global.day_and_night) * 0.05))  # move to player 2.
				move_and_slide()
				if (player_2_pos.x - global_position.x) < 0:  # if the player 2's x co -ord is less than sleeper mob's:
					$AnimatedSprite2D.play("move_left")  # this means player 2 is to the left,
					# so play the corresponding animation.
				else:
					$AnimatedSprite2D.play("move_right")  # if not, move right.


func spawn_and_despawn():
	if (Global.day_and_night % 2) != 0 and not despawned_tonight:  # if it is day and this hasn't run before:
		despawned_tonight = true  # prevents this section from running again.
		spawned_today = false  # allows the next section to run once during night.
		$AnimatedSprite2D.hide()  # hide
		$CollisionShape2D.set_deferred("disabled", true)  # disable Collision Shape.
		$Proximity_Area2D/Proximity_CollisionShape2D.set_deferred("disabled", true)  # disables the proximity collision shape.
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
		$Proximity_Area2D/Proximity_CollisionShape2D.set_deferred("disabled", false)
		# enables the proximity collision shape.


func spawn_in_random_location():
	# this spawns the mob in a reandom location,
	# which is no more than 300 pixels away from the player, to keep things fair. 
	# (not 200 as sleeper mobs have the proximity collisionshapes, which would activate quickly - meaning they'd be chased - if it was 200)
	# otherwise mobs will spawn on the player and instantly kill them, which sucks!
	$AnimatedSprite2D.hide()
	$CollisionShape2D.set_deferred("disabled", true) # this deactivates the collisions so mob wont collide with player during this code.
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
		if distance_to_player > 300 and distance_to_player_2 > 300: # if the mobs is not in either player's 300 radius:
			$CollisionShape2D.set_deferred("disabled", false) # enable the collision shape, as the mob is allowed to stay here. 
		else: # if the mob is in the 300 radius of either player, then:
			spawn_in_random_location() # run the code again, this will loop until the mobs spawn somewhere they are allowed to.
			return # prevent this run of the function from continuing to run.
	else: # if single player:
		if distance_to_player > 300: # if the mobs aren't in the player's 300 radius:
			$CollisionShape2D.set_deferred("disabled", false) # re enable collisions. 
		else: # if the mob is in the 300 radius:
			spawn_in_random_location() # try again. 
			return # prevent running further, pretty pointless since theres nothing more but still!


func _on_proximity_area_2d_area_entered(area):
	if area.is_in_group("Player"):
		player_in_proximity = true


func _on_proximity_area_2d_area_exited(area):
	if area.is_in_group("Player"):
		player_in_proximity = false
		$AnimatedSprite2D.stop() # stop playing the animation, to increase the code's efficiency. 


func _on_proximity_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_proximity = true


func _on_proximity_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_proximity = false
		$AnimatedSprite2D.stop()

# THIS IS NOT THE EXPERIMENTS ONE!
# (btw for anyone reading, this is just telling me this is the real project, because I made a copy to test new features,
# in case they break the whole game)

func game_paused_true():
	spawn_in_random_location()
	$PointLight2D.show()
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.scale = Vector2(0.15, 0.15)

func game_paused_false():
	$PointLight2D.hide()
	$AnimatedSprite2D.scale = Vector2(0.07, 0.07)
