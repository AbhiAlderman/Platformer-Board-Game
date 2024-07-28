extends Node2D

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("active")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func grab_coin() -> void:
	sprite.play("inactive")
