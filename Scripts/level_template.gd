extends Node2D

signal on_player_death
@onready var test = $Tilemaps/test
@onready var platformer_player = $Platformer_Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_died():
	get_parent().player_died()

func player_won():
	get_parent().player_won()

func kill_player():
	platformer_player.die()

func disable_player_control():
	platformer_player.disable_player_control()

func enable_player_control():
	platformer_player.enable_player_control()
	
func enable_double_jump():
	platformer_player.enable_double_jump()

func enable_wall_jump():
	platformer_player.enable_wall_jump()
	
func enable_glide():
	platformer_player.enabled_glide()

