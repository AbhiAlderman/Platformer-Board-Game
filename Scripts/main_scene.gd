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
var current_level_number: int
var current_level_node
var tween: Tween
var game_state: states 
enum states {
	MAP, #the worldmap the player is moving through to progress
	PLATFORMER, #the actual platformer game
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
	pass
func load_level():
	#load the current platformer level
	match current_level_number:
		1:
			current_level_node = level_one.instantiate()
		2:
			current_level_node = level_two.instantiate()
		3:
			current_level_node = level_three.instantiate()
		_:
			print("made it to some other level")
			return
	add_child(current_level_node)
	current_level_node.on_player_won.connect(player_won)
	current_level_node.on_player_death.connect(player_died)
	current_level_node.position.x = 0
	current_level_node.position.y = 0


func player_died():
	#change the level
	await get_tree().create_timer(1.2).timeout
	current_level_node.queue_free()
	#current_level_number += 1
	load_level()
	change_gamestate(states.PLATFORMER)

func player_won():
	#change the level
	await get_tree().create_timer(1.6).timeout
	current_level_node.queue_free()
	#current_level_number += 1
	load_level()
	current_level_number += 1
	current_level_node.queue_free()
	change_gamestate(states.MAP)

func kill_player():
	current_level_node.kill_player()

func disable_player_control():
	current_level_node.enable_player_control(false)
	
func enable_player_control():
	current_level_node.enable_player_control(true)
	
func is_platforming() -> bool:
	return game_state == states.PLATFORMER

func change_camera_zoom(zoom_level: Vector2, time: float):
	tween = create_tween()
	tween.tween_property(camera, "zoom", zoom_level, time)
	await get_tree().create_timer(time).timeout


func change_gamestate(state: states):
	tween = create_tween()
	match state:
		states.MAP:
			game_state = states.MAP
			change_camera_zoom(CAMERA_ZOOM_MAP, 0.2)
			progress_timer.start()
			progress_sprite.play("visible")
		states.PLATFORMER:
			progress_sprite.play("invisible")
			game_state = states.PLATFORMER
			enable_player_control()
			change_camera_zoom(CAMERA_ZOOM_PLATFORMER, 0.2)
		states.GAMEOVER:
			progress_sprite.play("invisible")
			game_state = states.GAMEOVER
			print("game over")
		_:
			print("invalid game state")
			return

func _on_progress_timer_timeout():
	load_level()
	change_gamestate(states.PLATFORMER)
