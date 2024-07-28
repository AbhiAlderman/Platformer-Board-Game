extends Node2D

signal slot_selected
@onready var button = $Button
@onready var sprite = $AnimatedSprite2D
var has_focus: bool
var active_position: Vector2
var inactive_position: Vector2
var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func disable_slot():
	disable_selecting()
	tween = create_tween()
	tween.tween_property(self, "position", inactive_position, 0.3)
	await get_tree().create_timer(0.5).timeout
	button.disabled = true
	visible = false

func enable_slot():
	visible = true
	enable_selecting()
	button.disabled = false
	tween = create_tween()
	tween.tween_property(self, "position", active_position, 0.3)
	await get_tree().create_timer(0.5).timeout

func disable_selecting() -> void:
	button.focus_mode = 0
	
func enable_selecting() -> void:
	button.focus_mode = 2
	
func set_active_position(pos: Vector2) -> void:
	active_position = pos
	inactive_position = pos - Vector2(0, 200)

func _on_button_focus_entered():
	change_scale(1.5)
	z_index += 10


func _on_button_focus_exited():
	change_scale(1)
	z_index -= 10

func _on_button_pressed():
	slot_selected.emit(self)

func get_button_path() -> String:
	return button.get_path()

func set_left_neighbor(path: String) -> void:
	button.focus_neighbor_left = path

func set_right_neighbor(path: String) -> void:
	button.focus_neighbor_right = path

func grab_focus():
	button.grab_focus()
	
func change_scale(val: float) -> void:
	scale.x = val
	scale.y = val
