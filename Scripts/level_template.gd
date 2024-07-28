extends Node2D

signal on_player_death
const CAMERA_ZOOM_PLATFORMER: Vector2 = Vector2(1.7, 1.7)
const CAMERA_ZOOM_CARDS: Vector2 = Vector2(1.6, 1.6)
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

const SLOT_POS_Y: float = -130
const SLOT_X_GAP: float = 90
const SLOT_POS_X_LEFTMOST: Vector2 = Vector2(-SLOT_X_GAP * 2, SLOT_POS_Y)
const SLOT_POS_X_LEFTMID: Vector2 = Vector2(-SLOT_X_GAP, SLOT_POS_Y)
const SLOT_POS_X_MID: Vector2 = Vector2(0, SLOT_POS_Y)
const SLOT_POS_X_RIGHTMID: Vector2 = Vector2(SLOT_X_GAP, SLOT_POS_Y)
const SLOT_POS_X_RIGHTMOST: Vector2 = Vector2(SLOT_X_GAP * 2, SLOT_POS_Y)
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
var card_slot_scene = preload("res://Scenes/slot.tscn")
var num_player_cards: int
var hand_positions: PackedVector2Array = []
var hand_rotations: PackedInt32Array = []
var hand_orderings: PackedInt32Array = []
var hand_map: Dictionary = {}
var slot_array: Array = []
var selected_card: Node2D = null
# Called when the node enters the scene tree for the first time.
func _ready():
	more_traps.visible = false
	load_card_slots()
	load_player_cards()
	load_level_interactables()

func load_card_slots():
	var start_x: float 
	match num_card_slots:
		1:
			start_x = SLOT_POS_X_MID.x
		2:
			start_x = SLOT_POS_X_LEFTMID.x + (SLOT_X_GAP / 2)
		3:
			start_x = SLOT_POS_X_LEFTMID.x
		4:
			start_x = SLOT_POS_X_LEFTMOST.x + (SLOT_X_GAP / 2)
		5:
			start_x = SLOT_POS_X_LEFTMOST.x
		_:
			print("INVALID NUMBER OF CARD SLOTS")
			return
	
	var prev_slot
	for i in range(num_card_slots):
		var slot = card_slot_scene.instantiate()
		card_slots.add_child(slot)
		slot.position = Vector2(start_x + i * SLOT_X_GAP, SLOT_POS_Y)
		if prev_slot:
			prev_slot.set_right_neighbor(slot.get_button_path())
			slot.set_left_neighbor(prev_slot.get_button_path())
		slot.set_active_position(slot.position)
		slot_array.append(slot)
		slot.disable_slot()
		slot.z_index = 20
		slot.slot_selected.connect(slot_selected)
		prev_slot = slot
	
func load_player_cards():
	num_player_cards = buffs.size()
	for buff in buffs:
		var card = card_scene.instantiate()
		cards.add_child(card)
		card.set_effect(buff)
		card.change_scale(1)
		set_hand(card)
		card.disable_card()
		card.card_selected.connect(card_selected)
	assign_neighbors()

func load_level_interactables():
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
			curr_card.set_left_neighbor("")
		else:
			curr_card.set_left_neighbor(prev_card.get_button_path())
			prev_card.set_right_neighbor(curr_card.get_button_path())
		curr_card.set_right_neighbor("")
		curr_card.grab_focus()
		prev_card = curr_card
		
func card_selected(card: Node2D) -> void:
	selected_card = card
	for c in hand_map.values():
		if c != card:
			c.disable_selecting()
	slot_array[0].grab_focus()
	
func slot_selected(slot: Node2D) -> void:
	print("SLOT SELECTED!")
	
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
		get_parent().change_camera_zoom(CAMERA_ZOOM_CARDS, 0.1)
		for card in cards.get_children():
			card.enable_card()
		for slot in card_slots.get_children():
			slot.enable_slot()
	else:
		get_parent().change_camera_zoom(CAMERA_ZOOM_PLATFORMER, 0.1)
		for card in cards.get_children():
			card.disable_card()
		for slot in card_slots.get_children():
			slot.disable_slot()
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
