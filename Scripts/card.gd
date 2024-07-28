extends Node2D

signal card_selected
signal card_got_focus
signal card_lost_focus
signal card_done_moving
var effect_name: String
@onready var button = $Button
@onready var sprite = $sprite
var tween
var active_position: Vector2
var inactive_position: Vector2
var hand_rotation: float
# Called when the node enters the scene tree for the first time.
func _ready():
	enable_card()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func disable_card() -> void:
	disable_selecting()
	tween = create_tween()
	tween.tween_property(self, "position", inactive_position, 0.3)
	await get_tree().create_timer(0.3).timeout
	card_done_moving.emit()
	visible = false
	button.disabled = true

func disable_selecting() -> void:
	button.focus_mode = 0
	
func enable_selecting() -> void:
	button.focus_mode = 2
	
func enable_card() -> void:
	visible = true
	enable_selecting()
	button.disabled = false
	tween = create_tween()
	tween.tween_property(self, "position", active_position, 0.3)
	await get_tree().create_timer(0.3).timeout
	card_done_moving.emit()
	
	
func set_active_position(pos: Vector2) -> void:
	active_position = pos
	
func set_inactive_position(pos: Vector2) -> void:
	inactive_position = pos

func get_active_position() -> Vector2:
	return active_position

func get_inactive_position() -> Vector2:
	return inactive_position

func set_effect(effect: String) -> void:
	effect_name = effect 
	sprite.play("default_" + effect_name)

func get_effect() -> String:
	return effect_name
	
func _on_button_focus_entered():
	change_scale(1.5)
	z_index += 10
	card_got_focus.emit(self)

func _on_button_focus_exited():
	change_scale(1)
	z_index -= 10
	card_lost_focus.emit(self)

func _on_button_pressed():
	card_selected.emit(self)
	change_scale(1)
	
func get_button_path() -> String:
	return button.get_path()

func set_left_neighbor(path: String) -> void:
	button.focus_neighbor_left = path

func set_right_neighbor(path: String) -> void:
	button.focus_neighbor_right = path

func set_top_neighbor(path: String) -> void:
	button.focus_neighbor_top = path

func grab_focus():
	button.grab_focus()

func release_focus():
	button.release_focus()
	
func set_hand_rotation(val: float) -> void:
	hand_rotation = val
	rotation_degrees = val
func reset_rotation() -> void:
	rotation_degrees = hand_rotation

func change_scale(val: float) -> void:
	scale.x = val
	scale.y = val


func _on_button_mouse_entered():
	if button.focus_mode == 2:
		grab_focus()

func _on_button_mouse_exited():
	if button.focus_mode == 2:
		release_focus()
