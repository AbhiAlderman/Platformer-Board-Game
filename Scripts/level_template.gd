extends Node2D

signal on_player_death
@onready var test = $Tilemaps/test
@onready var platformer_player = $Platformer_Player
@onready var more_traps = $Tilemaps/more_traps
@onready var pressure_plate = $Button/Pressure_Plate
@onready var toggle_blocks = $Button/Toggle_Blocks
@onready var boxes = $Boxes
@onready var platforms_and_levers = $Platforms_and_Levers


# Called when the node enters the scene tree for the first time.
func _ready():
	more_traps.visible = false
	for block in toggle_blocks.get_children():
		block.active = true
		pressure_plate.button_pressed.connect(block.on_plate_pressed)
		pressure_plate.button_released.connect(block.on_plate_released)
	for platform_bundle in platforms_and_levers.get_children():
		var platform
		var lever
		var markerone
		var markertwo
		for child in platform_bundle.get_children():
			match child.name:
				"Platform":
					platform = child
				"Lever":
					lever = child
				"Position1":
					markerone = child
				"Position2":
					markertwo = child
				_:
					print("invalid child of platform bundle")
		platform.assign_positions(markerone.position, markertwo.position)
		platform.assign_lever(lever)
		lever.toggled.connect(platform.switch_position)
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


