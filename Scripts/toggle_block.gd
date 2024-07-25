extends Node2D

var active: bool = true
@onready var sprite = $AnimatedSprite2D
@onready var staticbody = $StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	staticbody.set_collision_layer_value(1, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		sprite.play("activated")
		sprite.modulate = Color.html("#ffffff")
	else:
		sprite.play("deactivated")
		sprite.modulate = Color.html("#ffffffa6")


func on_plate_pressed():
	active = false
	staticbody.set_collision_layer_value(1, false)

func on_plate_released():
	active = true
	staticbody.set_collision_layer_value(1, true)
