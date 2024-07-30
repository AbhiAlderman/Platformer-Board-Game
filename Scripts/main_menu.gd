extends Control

@onready var color_rect = $ColorRect
@onready var animated_sprite_2d = $AnimatedSprite2D

var main_scene: PackedScene = load("res://Scenes/main_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite_2d.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("jump"):
		get_tree().change_scene_to_packed(main_scene)
