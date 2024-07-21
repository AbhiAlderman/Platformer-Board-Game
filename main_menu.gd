extends Node2D

@onready var color_rect = $ColorRect
@onready var button_1 = $Button1/Button1
@onready var button_2 = $Button2/Button2
@onready var button_3 = $Button3/Button3

# Called when the node enters the scene tree for the first time.
func _ready():
	button_1.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_1_pressed():
	color_rect.color = Color(255, 0, 255, 255)
	button_1.focus_mode = 0
	button_2.focus_mode = 0
	button_3.focus_mode = 0
func _on_button_2_pressed():
	color_rect.color = Color(255, 255, 0, 255)
	button_1.focus_mode = 2
	button_2.focus_mode = 2
	button_3.focus_mode = 2
	button_2.grab_focus()
func _on_button_3_pressed():
	color_rect.color = Color(255, 255, 255, 255)
