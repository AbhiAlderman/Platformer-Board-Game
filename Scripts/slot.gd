extends Node2D

signal slot_selected
signal slot_got_focus
signal slot_lost_focus
signal slot_done_moving
@onready var button = $Button
@onready var sprite = $AnimatedSprite2D
var has_focus: bool
var active_position: Vector2
var inactive_position: Vector2
var tween
var held_card: Node2D = null

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
	if held_card != null:
		tween.tween_property(held_card, "position", inactive_position, 0.3)
	await get_tree().create_timer(0.3).timeout
	slot_done_moving.emit()
	button.disabled = true
	visible = false

func enable_slot():
	visible = true
	enable_selecting()
	button.disabled = false
	tween = create_tween()
	tween.tween_property(self, "position", active_position, 0.3)
	if held_card != null:
		tween.tween_property(held_card, "position", active_position, 0.3)
	await get_tree().create_timer(0.3).timeout
	slot_done_moving.emit()

func disable_selecting() -> void:
	button.focus_mode = 0
	
func enable_selecting() -> void:
	button.focus_mode = 2
	
func set_active_position(pos: Vector2) -> void:
	active_position = pos

func set_inactive_position(pos: Vector2) -> void:
	inactive_position = pos

func get_active_position() -> Vector2:
	return active_position

func get_inactive_position() -> Vector2:
	return inactive_position

func _on_button_focus_entered():
	slot_got_focus.emit(self)

func _on_button_focus_exited():
	slot_lost_focus.emit(self)

func _on_button_pressed():
	slot_selected.emit(self)

func get_button_path() -> String:
	return button.get_path()

func set_left_neighbor(path: String) -> void:
	button.focus_neighbor_left = path

func set_right_neighbor(path: String) -> void:
	button.focus_neighbor_right = path

func set_bottom_neighbor(path: String) -> void:
	button.focus_neighbor_bottom = path

func hold_card(card: Node2D) -> void:
	held_card = card
	card.z_index = self.z_index + 1

func get_card() -> Node2D:
	return held_card

func release_card():
	held_card = null

func grab_focus():
	button.grab_focus()
	
func release_focus():
	button.release_focus()

func _on_button_mouse_entered():
	if button.focus_mode == 2:
		grab_focus()

func _on_button_mouse_exited():
	if button.focus_mode == 2:
		release_focus()
