extends Control

@onready var color_rect = $ColorRect
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var music = $Music

var main_scene: PackedScene = load("res://Scenes/main_scene.tscn")
@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite_2d.play("default")
	music.play()
	sprite.play("startup")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("jump"):
		get_tree().change_scene_to_packed(main_scene)


func _on_music_finished():
	music.play()


func _on_animated_sprite_2d_animation_finished():
	sprite.play("run")
