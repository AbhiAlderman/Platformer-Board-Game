extends Node2D

const CAMERA_ZOOM_MAP: Vector2 = Vector2(1, 1)
const CAMERA_ZOOM_PLATFORMER: Vector2 = Vector2(1.7, 1.7)
const CAMERA_ZOOM_CARDS: Vector2 = Vector2(0.48, 0.48)
const CAMERA_POSITION_MAP: Vector2 = Vector2(0, 0)
const CAMERA_POSITION_PLATFORMER: Vector2 = Vector2(0, 0)
const LEVEL_PREPATH: String = "res://Scenes/levels/level_"
@onready var music = $Music
@onready var camera = $Camera
@onready var progress_timer = $Progress/Progress_Timer
@onready var progress_sprite = $Progress/ProgressSprite

@export var starting_level_number: int
@export var total_number_of_levels: int
var win_screen: PackedScene = preload("res://Scenes/game_end.tscn")
var song_array = []
var song_count = 0
var current_level_number: int
var current_level_scene: PackedScene
var current_level_node: Node2D
var tween: Tween
var game_state: states 
enum states {
	MAP, #the worldmap the player is moving through to progress
	PLATFORMER, #the actual platformer game
	GAMEOVER #game over
}


# Called when the node enters the scene tree for the first time.
func _ready():
	update_current_level_number(starting_level_number)
	change_gamestate(states.MAP)
	for song in music.get_children():
		song_array.append(song)
		song.finished.connect(song_ended)
	song_array.shuffle()
	song_array[0].play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func song_ended():
	song_count += 1
	if song_count >= song_array.size():
		song_count = 0
		song_array.shuffle()
	song_array[song_count].play()
	
func update_current_level_number(new_value: int) -> bool:
	current_level_number = new_value
	if current_level_number == total_number_of_levels:
		get_tree().change_scene_to_packed(win_screen)
		return false
	else:
		current_level_scene = load(LEVEL_PREPATH + str(current_level_number) + ".tscn")
		return true
	
func load_level():
	#load the current platformer level
	current_level_node = current_level_scene.instantiate()
	add_child(current_level_node)
	current_level_node.on_player_won.connect(player_won)
	current_level_node.on_player_death.connect(player_died)
	current_level_node.position.x = 0
	current_level_node.position.y = 0


func player_died():
	#change the level
	await get_tree().create_timer(0.3).timeout
	current_level_node.queue_free()
	load_level()
	change_gamestate(states.PLATFORMER)
	

func player_won(player_position: Vector2):
	#current_level_number += 1
	if update_current_level_number(current_level_number + 1):
		#returns TRUE if there is a new level to load
		#zoom on player celebration
		change_camera_position(player_position, 0)
		change_camera_zoom(Vector2(2.5, 2.5), 0.2)
		await get_tree().create_timer(2.3).timeout
		#change the level
		current_level_node.queue_free()
		change_gamestate(states.MAP)

func kill_player():
	current_level_node.kill_player()

func is_platforming() -> bool:
	return game_state == states.PLATFORMER

func change_camera_zoom(zoom_level: Vector2, time: float):
	tween = create_tween()
	tween.tween_property(camera, "zoom", zoom_level, time)
	await get_tree().create_timer(time).timeout

func change_camera_position(new_position: Vector2, time: float):
	tween = create_tween()
	tween.tween_property(camera, "position", new_position, time)
	await get_tree().create_timer(time).timeout

func change_gamestate(state: states):
	tween = create_tween()
	match state:
		states.MAP:
			game_state = states.MAP
			change_camera_position(CAMERA_POSITION_MAP, 0.05)
			change_camera_zoom(CAMERA_ZOOM_MAP, 0.2)
			progress_timer.start()
			progress_sprite.play("visible")
		states.PLATFORMER:
			progress_sprite.play("invisible")
			game_state = states.PLATFORMER
			change_camera_position(CAMERA_POSITION_PLATFORMER, 0.05)
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
