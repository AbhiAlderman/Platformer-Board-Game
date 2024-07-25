extends Node2D

signal on_player_death
@onready var test = $Tilemaps/test
@onready var platformer_player = $Platformer_Player
@onready var more_traps = $Tilemaps/more_traps
@onready var pressure_plate = $Button/Pressure_Plate
@onready var toggle_blocks = $Button/Toggle_Blocks

# Called when the node enters the scene tree for the first time.
func _ready():
	more_traps.visible = false
	for block in toggle_blocks.get_children():
		block.active = true
		block.collision_shape.disabled = false
		pressure_plate.button_pressed.connect(block.on_plate_pressed)
		pressure_plate.button_released.connect(block.on_plate_released)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_died() -> void:
	get_parent().player_died()

func player_won() -> void:
	get_parent().player_won()

func kill_player() -> void:
	platformer_player.die()

func disable_player_control() -> void:
	platformer_player.disable_player_control()

func enable_player_control() -> void:
	platformer_player.enable_player_control()
	
func enable_double_jump() -> void:
	platformer_player.enable_double_jump()

func enable_wall_jump() -> void:
	platformer_player.enable_wall_jump()
	
func enable_glide() -> void:
	platformer_player.enable_glide()

func enable_traps() -> void:
	platformer_player.enable_traps()
	more_traps.visible = true
	
func enable_speed_boost() -> void:
	platformer_player.enable_speed_boost()
	
func enable_jump_boost() -> void:
	platformer_player.enable_jump_boost()

