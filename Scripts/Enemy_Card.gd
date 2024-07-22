extends Node2D

var effect_name: String
@onready var sprite = $sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.play("default")

func set_effect(effect: String) -> void:
	effect_name = effect

func get_effect() -> String:
	return effect_name
	
