extends Node2D

var has_focus: bool
var effect_name: String
@onready var button = $Button
@onready var sprite = $sprite
var tween
var active_position: Vector2
var inactive_position: Vector2
# Called when the node enters the scene tree for the first time.
var selected: bool = false
func _ready():
	has_focus = false
	enable_card()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func disable_card() -> void:
	button.focus_mode = 0
	tween = create_tween()
	tween.tween_property(self, "position", inactive_position, 0.5)
	await get_tree().create_timer(0.5).timeout
	visible = false
	button.disabled = true

func enable_card() -> void:
	visible = true
	button.focus_mode = 2
	button.disabled = false
	tween = create_tween()
	tween.tween_property(self, "position", active_position, 0.5)
	await get_tree().create_timer(0.5).timeout
	button.grab_focus()
	
	
func set_active_position(pos: Vector2) -> void:
	active_position = pos
	inactive_position = pos + Vector2(0, 200)
	
func set_effect(effect: String) -> void:
	effect_name = effect 
	sprite.play("default_" + effect_name)

func get_effect() -> String:
	return effect_name
	
func _on_button_focus_entered():
	change_scale(1.5)
	has_focus = true
	z_index += 10

func _on_button_focus_exited():
	change_scale(1)
	has_focus = false
	z_index -= 10

func _on_button_pressed():
	get_parent().card_selected(self)
	disable_card()
	selected = true
	change_scale(1)
	
func change_scale(val: float) -> void:
	scale.x = val
	scale.y = val
