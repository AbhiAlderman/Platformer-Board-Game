extends Node2D

signal button_pressed
signal button_released
@onready var sprite = $AnimatedSprite2D
var pressed: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pressed = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if pressed:
		sprite.play("on")
	else:
		sprite.play("off")


func _on_button_area_area_entered(_area):
	pressed = true
	button_pressed.emit()


func _on_button_area_area_exited(_area):
	pressed = false
	button_released.emit()
