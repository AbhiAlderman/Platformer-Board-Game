extends StaticBody2D

var on: bool
var toggleable: bool 
@onready var sprite = $AnimatedSprite2D
signal toggled

# Called when the node enters the scene tree for the first time.
func _ready():
	on = false
	toggleable = true
	sprite.play("blue")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func toggle() -> void:
	if not toggleable:
		return
	if on:
		on = false
		sprite.play("blue")
	else:
		on = true
		sprite.play("purple")
	toggled.emit()

func set_toggleable(value: bool) -> void:
	toggleable = value
