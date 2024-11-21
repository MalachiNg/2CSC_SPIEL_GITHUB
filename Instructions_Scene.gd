extends Node
@onready var page = 1
const page_1 = preload("res://INSTRUCTIONS_page_1.png") # const as it is the only one not loaded later.
var page_2 
var page_3 
var page_4
var page_5 
var page_6 
var page_7 
var page_8 
var page_9 


func _ready():
	$TextureRect.texture = preload("res://INSTRUCTIONS_page_1.png")
	Global.update_instructions_opened()
	$Next_Button.global_position = Vector2(1920, 1120)
	$TextureRect.show() # moved to ready as nothing is hiding it so this is simple optimisation.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# this function is used to determine, based on what page is showing, what file teh texture rect is, 
	# and where buttons should be, etc
	$TextureRect.size = Vector2(2304, 1296)
	if page == 1:
		$TextureRect.texture = page_1
	elif page == 2:
		$Back_Button.scale = Vector2(0.7, 0.7)
		$TextureRect.texture = page_2
		$Next_Button.global_position = Vector2(1920, 1060)
	elif page == 3:
		$TextureRect.texture = page_3
		$Next_Button.global_position = Vector2(1940, 240)
	elif page == 4:
		$TextureRect.texture = page_4
		$Next_Button.global_position = Vector2(1900, 1110)
	elif page == 5:
		$TextureRect.texture = page_5
	elif page == 6:
		$TextureRect.texture = page_6
		$Next_Button.global_position = Vector2(1940, 1000)
	elif page == 7:
		$TextureRect.texture = page_7
		$Back_Button.scale = Vector2(0.7, 0.7)
		$Back_Button.global_position = Vector2(70, -22)
		$Next_Button.global_position = Vector2(1920, 1130) 
	elif page == 8:
		$TextureRect.texture = page_8
		$Back_Button.global_position = Vector2(0, -22)
		$Next_Button.global_position = Vector2(1900, 40)
	elif page == 9:
		$Back_Button.global_position = Vector2(1900, -22)
		$TextureRect.texture = page_9
		$Next_Button.hide()


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Start_scene.tscn")


#CHANGE INSTRUCTIONS TO HAVE MORE, MAYBE MAKE A NEXT BUTTON UNTIL IT SHOWS LITERALLY EVERYTHING THAT IS NECESSARY.


func _on_next_button_pressed():
	page += 1
	# the below is implimented to spread the processing load of preloading these files, across this scene. 
	# by breaking the preload into chunks, it makes everything a lot faster, and more efficient.
	# without this, not only is everything loaded at the start of the scene, making it slower, but it also wastes processing
	# power on loading files that may never even be used! 
	if page == 2:
		page_2 = preload("res://INSTRUCTIONS_page_2.png")
	if page == 3:
		page_3 = preload("res://INSTRUCTIONS_page_3.png")
	if page == 4:
		page_4 = preload("res://INSTRUCTIONS_page_4.png")
	if page == 5:
		page_5 = preload("res://INSTRUCTIONS_page_5.png")
	if page == 6:
		page_6 = preload("res://INSTRUCTIONS_page_6.png")
	if page == 7:
		page_7 = preload("res://INSTRUCTIONS_page_7.png")
	if page == 8:
		page_8 = preload("res://INSTRUCTIONS_page_8.png")
	if page == 9:
		page_9 = preload("res://INSTRUCTIONS_page_9.png")
