extends Node2D


var level_template = preload("res://Scenes/level_template.tscn")
var card_scene = preload("res://Scenes/card.tscn")
var current_level_number: int
var current_level_node
var tween: Tween
var card_positions: Array = [Vector2(-500, 525), Vector2(-250, 525), Vector2(0, 525), Vector2(250, 525), Vector2(500, 525)]
var cards: Array = []
var card_count: int
var game_state: states 
enum states {
	MAP, #the worldmap the player is moving through to progress
	PLATFORMER, #the actual platformer game
	CARDS, #zoomed out view to choose cards
	ENEMY #looking at enemy face
}

@onready var camera = $Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level_number = 0
	load_level()
	load_cards()
	change_gamestate(states.PLATFORMER)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match game_state:
		states.MAP:
			#print("map state")
			pass
		states.PLATFORMER:
			#print("platformer state")
			pass
		states.CARDS:
			#print("cards state")
			pass
		states.ENEMY:
			#print("enemy state")
			pass
		_:
			print("invalid game state")
			return

func load_level():
	match current_level_number:
		0:
			current_level_node = level_template.instantiate()
		_:
			print("made it to some other level")
			return
	add_child(current_level_node)
	current_level_node.position.x = 0
	current_level_node.position.y = 0

func load_cards():
	var previous_card
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
	card_count = 5
	
func player_died():
	#change the level
	level_template.queue_free()

func player_won():
	#change the level
	current_level_node.queue_free()
	#current_level_number += 1
	load_level()
	if card_count > 0:
		change_gamestate(states.CARDS)
	else:
		print("you won!")
		change_gamestate(states.MAP)

func disable_player_control():
	current_level_node.disable_player_control()
	
func enable_player_control():
	current_level_node.enable_player_control()
	
func card_selected(card):
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
	

func change_gamestate(state: states):
	tween = create_tween()
	match state:
		states.MAP:
			tween.tween_property(camera, "zoom", Vector2(1, 1), 0.6)
			game_state = states.MAP
			disable_player_control()
			for c in cards:
				if c != null:
					c.disable_card()
		states.PLATFORMER:
			tween.tween_property(camera, "zoom", Vector2(1.2, 1.2), 0.6)
			game_state = states.PLATFORMER
			enable_player_control()
			for c in cards:
				if c != null:
					c.disable_card()
		states.CARDS:
			tween.tween_property(camera, "zoom", Vector2(0.48, 0.48), 0.6)
			game_state = states.CARDS
			disable_player_control()
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
		_:
			print("invalid game state")
			return
