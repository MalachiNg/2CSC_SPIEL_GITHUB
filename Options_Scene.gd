extends Node
const Selected_1_Player = preload("res://Selected_1_Player.png")
const Unselected_1_Player = preload("res://Unselected_1_Player.png")
const Selected_2_Players = preload("res://Selected_2_Players.png")
const Unselected_2_Players = preload("res://Unselected_2_Players.png")
@onready var page = 1

# TextureRext textures, the different pages:
const Single_or_Multiplayer = preload("res://Single_or_Multiplayer.png")
const Normal_or_Hard_Mode = preload("res://Normal_or_Hard_Mode.png")
const Mute_or_Unmute = preload("res://Mute_or_Unmute.png")
const WASD_and_arrows_or_cursor = preload("res://WASD_and_arrows_or_cursor.png")

# The following are declared here, but not set to a value.
# instead, they are set values before they appear, to spread the load out and make performance better.
# these are variables, not constants, as they change, as they are assigned values later.
var selected_Normal
var unselected_Normal
var selected_Hard
var unselected_Hard
var Selected_Unmute
var Unselected_Unmute
var Selected_Mute
var Unselected_Mute
var Selected_WASD_and_arrows
var Unselected_WASD_and_arrows
var Selected_cursor
var Unselected_cursor


# Called when the node enters the scene tree for the first time.
func _ready():
	$Normal_Mode_Button.hide()
	$Hard_Mode_Button.hide()
	$Mute_Button.hide()
	$Unmute_Button.hide()
	$WASD_and_arrows_Button.hide()
	$Cursor_Button.hide()
	if Global.single_player:
		Selected_Single_Player()
	else:
		Selected_Multiplayer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if page == 1:
		$TextureRect.texture = Single_or_Multiplayer
		$Single_Player_Button.show()
		$Multiplayer_Button.show()

	elif page == 2:
		$TextureRect.texture = Normal_or_Hard_Mode
		$Single_Player_Button.hide()
		$Multiplayer_Button.hide()
		$Hard_Mode_Button.show()
		$Normal_Mode_Button.show()
		normal_or_hard()

	elif page == 3:
		$TextureRect.texture = Mute_or_Unmute
		if not Global.single_player:
			$Next_Button.hide()
		$Hard_Mode_Button.hide()
		$Normal_Mode_Button.hide()
		mute_or_unmute()
	elif page == 4:
		$TextureRect.texture = WASD_and_arrows_or_cursor
		$Next_Button.hide()
		$Mute_Button.hide()
		$Unmute_Button.hide()
		wasd_and_arrows_or_cursor()


func _on_single_player_button_pressed():
	Global.update_single_player(true)
	Selected_Single_Player()


# 2 selected is slightly smaller


func _on_multiplayer_button_pressed():
	Global.update_single_player(false)
	Selected_Multiplayer()


func Selected_Multiplayer():
	$Single_Player_Button.icon = Unselected_1_Player
	$Single_Player_Button.scale = Vector2(0.59, 0.59)
	$Single_Player_Button.position = Vector2(231, 393)
	$Multiplayer_Button.icon = Selected_2_Players
	$Multiplayer_Button.scale = Vector2(0.85, 0.85)
	$Multiplayer_Button.position = Vector2(46, 518)


func Selected_Single_Player():
	$Single_Player_Button.icon = Selected_1_Player
	$Single_Player_Button.position = Vector2(50, 378)
	$Single_Player_Button.scale = Vector2(0.75, 0.75)
	$Multiplayer_Button.icon = Unselected_2_Players
	$Multiplayer_Button.position = Vector2(167, 526)
	$Multiplayer_Button.scale = Vector2(0.75, 0.75)


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Start_scene.tscn")


func _on_next_button_pressed():
	page += 1
	if page == 2:
		# these previously declared variables are now given values, so that the stress on the CPU
		# is spread out throughout the scene, as opposed to all happening at the start, causing lag.
		# this here runs if the page is Normal or hard mode, and only runs when the next button is pressed.
		selected_Normal = preload("res://Normal_Mode_Selected.png")
		unselected_Normal = preload("res://Normal_Mode_Button.png")
		selected_Hard = preload("res://Hard_Mode_Selected.png")
		unselected_Hard = preload("res://Hard_Mode_Button.png")
	elif page == 3:
		# this runs on Mute or Unmute. the first page runs at the start so doesn't need to be in here.
		Selected_Unmute = preload("res://Selected_Unmute.png")
		Unselected_Unmute = preload("res://Unselected_Unmute.png")
		Selected_Mute = preload("res://Selected_Mute.png")
		Unselected_Mute = preload("res://Unselected_Mute.png")

	else:
		Selected_WASD_and_arrows = preload("res://WASD_and_arrows_selected.png")
		Unselected_WASD_and_arrows = preload("res://WASD_and_arrows_unselected.png")
		Selected_cursor = preload("res://Cursor_selected.png")
		Unselected_cursor = preload("res://Cursor_unselected.png")


func normal_or_hard():
	if Global.Normal_mode:
		$Normal_Mode_Button.icon = selected_Normal
		$Hard_Mode_Button.icon = unselected_Hard
	else:
		$Normal_Mode_Button.icon = unselected_Normal
		$Hard_Mode_Button.icon = selected_Hard


func _on_hard_mode_button_pressed():
	Global.update_normal_mode(false)
	$Normal_Mode_Button.icon = unselected_Normal
	$Hard_Mode_Button.icon = selected_Hard


func _on_normal_mode_button_pressed():
	Global.update_normal_mode(true)
	$Normal_Mode_Button.icon = selected_Normal
	$Hard_Mode_Button.icon = unselected_Hard


func _on_unmute_button_pressed():
	Global.update_unmute(true)
	$Unmute_Button.icon = Selected_Unmute
	$Mute_Button.icon = Unselected_Mute


func _on_mute_button_pressed():
	Global.update_unmute(false)
	$Unmute_Button.icon = Unselected_Unmute
	$Mute_Button.icon = Selected_Mute


func mute_or_unmute():
	$Mute_Button.show()
	$Unmute_Button.show()
	if Global.Unmute:
		$Mute_Button.icon = Unselected_Mute
		$Unmute_Button.icon = Selected_Unmute
	else:
		$Mute_Button.icon = Selected_Mute
		$Unmute_Button.icon = Unselected_Unmute


func wasd_and_arrows_or_cursor():
	$WASD_and_arrows_Button.show()
	$Cursor_Button.show()
	if Global.WASD_and_arrows:
		$WASD_and_arrows_Button.icon = Selected_WASD_and_arrows
		$Cursor_Button.icon = Unselected_cursor
	else:
		$WASD_and_arrows_Button.icon = Unselected_WASD_and_arrows
		$Cursor_Button.icon = Selected_cursor


func _on_wasd_and_arrows_button_pressed():
	Global.update_WASD_and_arrows(true)
	$WASD_and_arrows_Button.icon = Selected_WASD_and_arrows
	$Cursor_Button.icon = Unselected_cursor


func _on_cursor_button_pressed():
	Global.update_WASD_and_arrows(false)
	$WASD_and_arrows_Button.icon = Unselected_WASD_and_arrows
	$Cursor_Button.icon = Selected_cursor
