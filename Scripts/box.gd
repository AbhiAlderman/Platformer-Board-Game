extends CharacterBody2D


const DEFAULT_FALL_GRAVITY: float = 2200
# Get the gravity from the project settings to be synced with RigidBody nodes.
var lifted: bool = false
@onready var collision_shape_2d = $CollisionShape2D

func _physics_process(delta):
	if not is_on_floor() and not lifted:
		velocity.y += get_gravity()
	move_and_slide()

func get_gravity():
	return DEFAULT_FALL_GRAVITY

func set_lifted(lift_bool: bool):
	lifted = lift_bool
	#change collision layer and mask
	if lifted:
		print("lifted")
	else:
		print("set down")
