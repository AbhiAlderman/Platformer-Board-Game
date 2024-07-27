extends Node2D

signal on_player_death
const HAND_LIMIT: int = 5
const HAND_EVEN_LEFTMOST: Vector2 =  Vector2(-82, 124)
const HAND_EVEN_LEFTMID: Vector2 = Vector2(-30, 110)
const HAND_EVEN_RIGHTMID: Vector2 = Vector2(30, 110)
const HAND_EVEN_RIGHTMOST: Vector2 = Vector2(-82, 124)
const HAND_ODD_LEFTMOST: Vector2 = Vector2(-100, 142)
const HAND_ODD_LEFTMID: Vector2 = Vector2(-50, 118)
const HAND_ODD_CENTER: Vector2 = Vector2(0, 110)
const HAND_ODD_RIGHTMID: Vector2 = Vector2(50, 118)
const HAND_ODD_RIGHTMOST: Vector2 = Vector2(100, 142)
@onready var test = $Tilemaps/test
@onready var platformer_player = $Platformer_Player
@onready var more_traps = $Tilemaps/more_traps
@onready var pressure_plate = $Button/Pressure_Plate
@onready var toggle_blocks = $Button/Toggle_Blocks
@onready var boxes = $Boxes
@onready var platforms_and_levers = $Platforms_and_Levers
@onready var cards = $Cards
@onready var card_slots = $Card_Slots

@export var buffs: PackedStringArray
@export var debuffs: PackedStringArray
@export var num_card_slots: int

var card_scene = preload("res://Scenes/card.tscn")

var num_player_cards: int
var hand_positions: PackedVector2Array = []
var hand_rotations: PackedInt32Array = []
var hand_orderings: PackedInt32Array = []
var hand_map: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	more_traps.visible = false
	num_player_cards = buffs.size()
	for buff in buffs:
		var card = card_scene.instantiate()
		cards.add_child(card)
		card.set_effect(buff)
		print("set card")
		card.change_scale(1)
		set_hand(card)
		card.disable_card()
	assign_neighbors()
	for block in toggle_blocks.get_children():
		block.active = true
		pressure_plate.button_pressed.connect(block.on_plate_pressed)
		pressure_plate.button_released.connect(block.on_plate_released)
	for platform_bundle in platforms_and_levers.get_children():
		var platform
		var lever
		var markerone
		var markertwo
		for child in platform_bundle.get_children():
			match child.name:
				"Platform":
					platform = child
				"Lever":
					lever = child
				"Position1":
					markerone = child
				"Position2":
					markertwo = child
				_:
					print("invalid child of platform bundle")
		platform.assign_positions(markerone.position, markertwo.position)
		platform.assign_lever(lever)
		lever.toggled.connect(platform.switch_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_hand(card: Node2D):
	#check what cards are in the hand and place accordingly
	if num_player_cards % 2 != 0:
		#even number of player cards
		hand_positions = [HAND_ODD_CENTER, HAND_ODD_LEFTMID, HAND_ODD_RIGHTMID, HAND_ODD_LEFTMOST, HAND_ODD_RIGHTMOST]
		hand_rotations = [0, -15, 15, -30, 30]
		hand_orderings = [20, 21, 19, 22, 18]
	else:
		hand_positions = [HAND_EVEN_LEFTMID, HAND_EVEN_RIGHTMID, HAND_EVEN_LEFTMOST, HAND_EVEN_RIGHTMOST]
		hand_rotations = [-10, 10, -19, 19]
		hand_orderings = [20, 19, 21, 18]
	#assign card to first empty slot
	for i in range(hand_positions.size()):
		if hand_map.get(hand_positions[i]) == null:
			hand_map[hand_positions[i]] = card
			card.position = hand_positions[i]
			card.rotation_degrees = hand_rotations[i]
			card.z_index = hand_orderings[i]
			card.set_active_position(card.position)
			print("gave card position: " + str(card.position) + " and rotation " + str(hand_rotations[i]) + " with effect " + str(card.get_effect()) + " and ordering " + str(card.z_index))
			break

func assign_neighbors() -> void:
	var position_order: PackedVector2Array
	var prev_card: Node2D = null
	var curr_card: Node2D = null
	if num_player_cards == 0:
		return
	elif num_player_cards % 2 != 0:
		#odd numbered hand
		position_order = [HAND_ODD_LEFTMOST, HAND_ODD_LEFTMID, HAND_ODD_CENTER, HAND_ODD_RIGHTMID, HAND_ODD_RIGHTMOST]
	else:
		position_order = [HAND_EVEN_LEFTMOST, HAND_EVEN_LEFTMID, HAND_EVEN_RIGHTMID, HAND_EVEN_RIGHTMOST]
	for position in position_order:
		curr_card = hand_map.get(position)
		if curr_card == null:
			continue
		if prev_card == null:
			curr_card.get_child(0).focus_neighbor_left = ""
		else:
			curr_card.get_child(0).focus_neighbor_left = prev_card.get_child(0).get_path()
			prev_card.get_child(0).focus_neighbor_right = curr_card.get_child(0).get_path()
		curr_card.get_child(0).focus_neighbor_right = ""
		curr_card.get_child(0).grab_focus()
		prev_card = curr_card
		
func card_selected(card: Node2D) -> void:
	pass
	
func player_died() -> void:
	get_parent().player_died()

func player_won() -> void:
	get_parent().player_won()

func kill_player() -> void:
	platformer_player.die()

func enable_player_control(value: bool) -> void:
	platformer_player.enable_player_control(value)
	
func enable_double_jump(value: bool) -> void:
	platformer_player.enable_double_jump(value)

func enable_wall_jump(value: bool) -> void:
	platformer_player.enable_wall_jump(value)
	
func enable_glide(value: bool) -> void:
	platformer_player.enable_glide(value)

func enable_traps(value: bool) -> void:
	platformer_player.enable_traps(value)
	more_traps.visible = true

func pause_level(pause_value: bool) -> void:
	if pause_value:
		for card in cards.get_children():
			card.enable_card()
	else:
		for card in cards.get_children():
			card.disable_card()
	platformer_player.pause_level(pause_value)
	for box in boxes.get_children():
		box.pause_level(pause_value)
	for platform_bundle in platforms_and_levers.get_children():
		for child in platform_bundle.get_children():
			match child.name:
				"Platform":
					child.pause_level(pause_value)
					
func show_cards(value: bool) -> bool:
	if get_parent().is_platforming():
		pause_level(value)
		return true
	return false

#func load_cards():
	##load cards, set focus neighbors
	##NEED TO UPDATE so that cards are not random
	#var previous_card
	#var temp_effects: Array = possible_buffs.duplicate()
	#temp_effects.shuffle()
	#for i in card_positions:
		#var card = card_scene.instantiate()
		#add_child(card)
		#card.position = i
		#card.enable_card()
		#if previous_card:
			#previous_card.get_child(0).focus_neighbor_right = card.get_child(0).get_path()
			#previous_card.next_card = card
			#card.get_child(0).focus_neighbor_left = previous_card.get_child(0).get_path()
			#card.prev_card = previous_card
		#else:
			#card.get_child(0).grab_focus()
		#cards.append(card)
		#previous_card = card
		#card.set_effect(temp_effects.pop_front())
	#
	
	
#func card_selected(card):
	#tween = create_tween()
	#tween.tween_property(card, "position", Vector2(0, 0), 0.6)
	#await get_tree().create_timer(2).timeout
	#if card.next_card != null:
		#var prev_card = card.prev_card
		#card.next_card.prev_card = prev_card
		#if prev_card != null:
			#card.next_card.get_child(0).focus_neighbor_left = prev_card.get_child(0).get_path()
		#else:
			#card.next_card.get_child(0).focus_neighbor_left = ""
	#if card.prev_card != null:
		#var next_card = card.next_card
		#card.prev_card.next_card = next_card
		#if next_card != null:
			#card.prev_card.get_child(0).focus_neighbor_right = next_card.get_child(0).get_path()
		#else:
			#card.prev_card.get_child(0).focus_neighbor_right = ""
	#effects.append(card.get_effect())
	#print(card.get_effect())
	#card.queue_free()
	#match card.position.x:
		#-500:
			#cards[0] = null
		#-250:
			#cards[1] = null
		#0:
			#cards[2] = null
		#250:
			#cards[3] = null
		#500:
			#cards[4] = null
	#change_gamestate(states.PLATFORMER)
	
#func handle_effects():
	##handle the card effect here
	#for i in range(effects.size()):
		#match effects[i]:
			#"double_jump":
				#current_level_node.enable_double_jump()
			#"wall_jump":
				#current_level_node.enable_wall_jump()
			#"glide":
				#current_level_node.enable_glide()
			#"speed":
				#current_level_node.enable_speed_boost()
			#"jump_boost":
				#current_level_node.enable_jump_boost()
			#"traps":
				#current_level_node.enable_traps()
			#"more_time":
				#current_time_limit += 10
			#"less_time":
				#current_time_limit -= 10
			#_:
				#print("invalid effect")

#loop for changing to platformer
#for c in cards:
				#if c != null:
					#c.disable_card()

#loop for changing to card menu
			#for c in cards:
				#if c != null:
					#c.enable_card()
					#if not foundfirst:
						#c.get_child(0).grab_focus()
						#foundfirst = true
