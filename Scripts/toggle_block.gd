extends Node2D

var active: bool = true
@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $StaticBody2D/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_shape.disabled = false
	active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		sprite.play("activated")
		sprite.modulate = Color.html("#ffffff")
	else:
		sprite.play("deactivated")
		sprite.modulate = Color.html("#ffffffa6")


func on_plate_pressed():
	print("pressed")
	active = false
	collision_shape.disabled = true

func on_plate_released():
	print("released")
	active = true
	collision_shape.disabled = false
