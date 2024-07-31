extends Control
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var music = $Music


# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite_2d.play("default")
	music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_music_finished():
	music.play()
