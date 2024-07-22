extends Node2D

var has_focus: bool
var effect_name: String
@onready var button = $Button
@onready var sprite = $sprite
@export var prev_card: Node2D
@export var next_card: Node2D
# Called when the node enters the scene tree for the first time.
var selected: bool = false
func _ready():
	has_focus = false
	enable_card()
	prev_card = null
	next_card = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if selected:
		scale.x = 2.5
		scale.y = 2.5
		sprite.play("selected")
	elif has_focus:
		scale.x = 2.5
		scale.y = 2.5
		sprite.play("focused")
	else:
		scale.x = 2
		scale.y = 2
		sprite.play("default")

func disable_card() -> void:
	button.focus_mode = 0
	button.disabled = true

func enable_card() -> void:
	button.focus_mode = 2
	button.disabled = false
	
func set_effect(effect: String) -> void:
	effect_name = effect 

func get_effect() -> String:
	return effect_name
	
func _on_button_focus_entered():
	has_focus = true

func _on_button_focus_exited():
	has_focus = false

func _on_button_pressed():
	get_parent().card_selected(self)
	disable_card()
	selected = true
