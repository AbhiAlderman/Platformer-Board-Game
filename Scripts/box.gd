extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.\
const PLATFORM_JUMP_HEIGHT: float = -350
var default_gravity: float = 2200
var lifted: bool = false
var default_position: Vector2
var disabled: bool
@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite = $AnimatedSprite2D
@onready var area_detection = $area_detection
var moved_by_platform: bool = false
var platform: StaticBody2D
@onready var detect_player_on_top = $Detect_Player_On_Top

func _ready():
	default_position = position
	disabled = false

func _physics_process(delta):
	if disabled:
		return
	if moved_by_platform and not lifted and platform:
		position += platform.get_position_changed() * delta
		return
	if not is_on_floor() and not lifted and not platform:
		velocity.y += get_gravity() * delta
	move_and_slide()

func _process(_delta):
	if lifted:
		sprite.play("invisible")
	else:
		sprite.play("visible")

func get_gravity() -> float:
	return default_gravity

func set_disabled(val: bool) -> void:
	disabled = val
	
func set_lifted(lift_bool: bool) -> void:
	lifted = lift_bool
	#change collision layer and mask
	if lifted:
		collision_shape_2d.disabled = true
	else:
		collision_shape_2d.disabled = false
		
func reset_position() -> void:
	position = default_position
	set_lifted(false)

func change_gravity(grav: float) -> void:
	default_gravity = grav
	
func pause_level(pause_value: bool) -> void:
	disabled = pause_value

func platform_hop() -> void:
	if not lifted:
		if detect_player_on_top.is_colliding():
			detect_player_on_top.get_collider().velocity.y = PLATFORM_JUMP_HEIGHT * 1.2
			await get_tree().create_timer(0.06).timeout
		velocity.y = PLATFORM_JUMP_HEIGHT
	moved_by_platform = false

func on_moving_platform() -> void:
	moved_by_platform = true
	
func _on_area_detection_area_entered(area):
	if area.is_in_group("platform"):
		platform = area.get_parent()
		platform.started_moving.connect(on_moving_platform)
		platform.stopped_moving.connect(platform_hop)

func _on_area_detection_area_exited(area):
	if area.is_in_group("platform"):
		platform.started_moving.disconnect(on_moving_platform)
		platform.stopped_moving.disconnect(platform_hop)
		platform = null
