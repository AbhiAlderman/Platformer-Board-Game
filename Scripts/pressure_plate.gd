extends Node2D

signal button_pressed
signal button_released
@onready var sprite = $AnimatedSprite2D
var pressed: bool = false
var touched_areas: Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pressed = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if pressed:
		sprite.play("on")
	else:
		sprite.play("off")


func _on_button_area_area_entered(area):
	pressed = true
	touched_areas.append(area)
	button_pressed.emit()

func _on_button_area_area_exited(area):
	var area_index = touched_areas.find(area)
	if area_index == -1:
		print("FOUND UNADDED AREA IN PRESSURE PLATE???")
		return
	touched_areas.remove_at(area_index)
	if touched_areas.size() <= 0:
		touched_areas = []
		pressed = false
		button_released.emit()
