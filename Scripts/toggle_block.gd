extends Node2D

var active: bool = true
@onready var sprite = $AnimatedSprite2D
@onready var staticbody = $StaticBody2D
var touching_bodies: Array = []
var trying_to_become_active: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	staticbody.set_collision_layer_value(1, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if active:
		sprite.play("activated")
		sprite.modulate = Color.html("#ffffff")
	else:
		sprite.play("deactivated")
		sprite.modulate = Color.html("#ffffffa6")


func on_plate_pressed():
	active = false
	staticbody.set_collision_layer_value(1, false)
	var trying_to_become_active: bool = false

func on_plate_released():
	if touching_bodies.size() > 0:
		trying_to_become_active = true
	else:
		active = true
		staticbody.set_collision_layer_value(1, true)


func _on_area_2d_area_entered(area):
	if !area.is_in_group("touches_toggle_blocks"):
		return
	touching_bodies.append(area)



func _on_area_2d_area_exited(area):
	if !area.is_in_group("touches_toggle_blocks"):
		return
	var index: int = touching_bodies.find(area)
	if index != -1:
		touching_bodies.remove_at(index)
	if trying_to_become_active:
		if touching_bodies.size() <= 0:
			touching_bodies = []
			trying_to_become_active = false
			active = true
			staticbody.set_collision_layer_value(1, true)
