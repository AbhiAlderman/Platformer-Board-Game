extends Node2D

const CAMERA_ZOOM_MAP: Vector2 = Vector2(1, 1)
const CAMERA_ZOOM_PLATFORMER: Vector2 = Vector2(1.7, 1.7)
const CAMERA_ZOOM_CARDS: Vector2 = Vector2(0.48, 0.48)
const CAMERA_POSITION_MAP: Vector2 = Vector2(0, 0)
const CAMERA_POSITION_PLATFORMER: Vector2 = Vector2(0, 0)
const CAMERA_POSITION_CARDS: Vector2 = Vector2(0, 30)

var level_template = preload("res://Scenes/level_template.tscn")
var level_one = preload("res://Scenes/level_one.tscn")
var level_two = preload("res://Scenes/level_two.tscn")
var level_three = preload("res://Scenes/level_three.tscn")
var card_scene = preload("res://Scenes/card.tscn")
var current_level_number: int
var current_level_node
var tween: Tween
var card_positions: Array = [Vector2(-500, 525), Vector2(-250, 525), Vector2(0, 525), Vector2(250, 525), Vector2(500, 525)]
var cards: Array = []
var card_count: int
var possible_buffs: Array = ["more_time", "double_jump", "wall_jump", "glide", "jump_boost", "speed"]
var possible_debuffs: Array = ["less_time", "traps", "flip_gravity"]
var effects: Array = []
var default_time_limit: int
var current_time_limit: int
var game_state: states 
enum states {
	MAP, #the worldmap the player is moving through to progress
	PLATFORMER, #the actual platformer game
	CARDS, #zoomed out view to choose cards
	ENEMY, #looking at enemy face
	GAMEOVER #game over
}

@onready var camera = $Camera
@onready var progress_timer = $Progress/Progress_Timer
@onready var progress_sprite = $Progress/ProgressSprite


# Called when the node enters the scene tree for the first time.
func _ready():
	current_level_number = 1
	change_gamestate(states.MAP)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match game_state:
		states.MAP:
			progress_sprite.play("visible")
		states.PLATFORMER:
			progress_sprite.play("invisible")
		states.CARDS:
			progress_sprite.play("invisible")
		states.ENEMY:
			progress_sprite.play("invisible")
		_:
			print("invalid game state")

func load_level():
	match current_level_number:
		1:
			current_level_node = level_one.instantiate()
			default_time_limit = 30
		2:
			current_level_node = level_two.instantiate()
			default_time_limit = 20
		3:
			current_level_node = level_three.instantiate()
			default_time_limit = 40
		_:
			print("made it to some other level")
			return
	add_child(current_level_node)
	current_level_node.position.x = 0
	current_level_node.position.y = 0

func load_cards():
	var previous_card
	var temp_effects: Array = possible_buffs.duplicate()
	temp_effects.shuffle()
	for i in card_positions:
		var card = card_scene.instantiate()
		add_child(card)
		card.position = i
		card.enable_card()
		if previous_card:
			previous_card.get_child(0).focus_neighbor_right = card.get_child(0).get_path()
			previous_card.next_card = card
			card.get_child(0).focus_neighbor_left = previous_card.get_child(0).get_path()
			card.prev_card = previous_card
		else:
			card.get_child(0).grab_focus()
		cards.append(card)
		previous_card = card
		card.set_effect(temp_effects.pop_front())
		
	card_count = 5
	
func player_died():
	#change the level
	if card_count <= 0:
		current_level_node.queue_free()
		change_gamestate(states.GAMEOVER)
	else:
		player_won()

func player_won():
	#change the level
	await get_tree().create_timer(1.6).timeout
	current_level_node.queue_free()
	#current_level_number += 1
	load_level()
	if card_count > 0:
		change_gamestate(states.CARDS)
	else:
		current_level_number += 1
		current_level_node.queue_free()
		change_gamestate(states.MAP)

func kill_player():
	current_level_node.kill_player()

func disable_player_control():
	current_level_node.disable_player_control()
	
func enable_player_control():
	current_level_node.enable_player_control()
	
func card_selected(card):
	tween = create_tween()
	tween.tween_property(card, "position", Vector2(0, 0), 0.6)
	await get_tree().create_timer(2).timeout
	if card.next_card != null:
		var prev_card = card.prev_card
		card.next_card.prev_card = prev_card
		if prev_card != null:
			card.next_card.get_child(0).focus_neighbor_left = prev_card.get_child(0).get_path()
		else:
			card.next_card.get_child(0).focus_neighbor_left = ""
	if card.prev_card != null:
		var next_card = card.next_card
		card.prev_card.next_card = next_card
		if next_card != null:
			card.prev_card.get_child(0).focus_neighbor_right = next_card.get_child(0).get_path()
		else:
			card.prev_card.get_child(0).focus_neighbor_right = ""
	effects.append(card.get_effect())
	print(card.get_effect())
	card.queue_free()
	match card.position.x:
		-500:
			cards[0] = null
		-250:
			cards[1] = null
		0:
			cards[2] = null
		250:
			cards[3] = null
		500:
			cards[4] = null
	card_count -= 1
	change_gamestate(states.PLATFORMER)
	
func handle_effects():
	#handle the card effect here
	for i in range(effects.size()):
		match effects[i]:
			"double_jump":
				current_level_node.enable_double_jump()
			"wall_jump":
				current_level_node.enable_wall_jump()
			"glide":
				current_level_node.enable_glide()
			"speed":
				current_level_node.enable_speed_boost()
			"jump_boost":
				current_level_node.enable_jump_boost()
			"traps":
				current_level_node.enable_traps()
			"more_time":
				current_time_limit += 10
			"less_time":
				current_time_limit -= 10
			_:
				print("invalid effect")

func change_gamestate(state: states):
	tween = create_tween()
	match state:
		states.MAP:
			game_state = states.MAP
			effects = []
			tween.tween_property(camera, "position", CAMERA_POSITION_MAP, 0.2)
			tween.tween_property(camera, "zoom", CAMERA_ZOOM_MAP, 0.2)
			await get_tree().create_timer(0.5).timeout
			progress_timer.start()
		states.PLATFORMER:
			game_state = states.PLATFORMER
			tween.tween_property(camera, "position", CAMERA_POSITION_PLATFORMER, 0.2)
			tween.tween_property(camera, "zoom", CAMERA_ZOOM_PLATFORMER, 0.2)
			await get_tree().create_timer(0.5).timeout
			enable_player_control()
			for c in cards:
				if c != null:
					c.disable_card()
			current_time_limit = default_time_limit
			handle_effects()
		states.CARDS:
			game_state = states.CARDS
			tween.tween_property(camera, "zoom", CAMERA_ZOOM_CARDS, 0.6)
			tween.tween_property(camera, "position", CAMERA_POSITION_CARDS, 0.5)
			disable_player_control()
			await get_tree().create_timer(1.2).timeout
			var foundfirst: bool = false
			for c in cards:
				if c != null:
					c.enable_card()
					if not foundfirst:
						c.get_child(0).grab_focus()
						foundfirst = true
		states.ENEMY:
			game_state = states.ENEMY
			disable_player_control()
			for c in cards:
				if c != null:
					c.disable_card()
		states.GAMEOVER:
			game_state = states.GAMEOVER
			print("game over")
		_:
			print("invalid game state")
			return


func _on_progress_timer_timeout():
	change_gamestate(states.PLATFORMER)
	load_level()
	load_cards()
