extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.\
var default_gravity: float = 2200
var lifted: bool = false
var default_position: Vector2
@onready var collision_shape_2d = $CollisionShape2D
@onready var sprite = $AnimatedSprite2D
@onready var platform_detector_ray = $PlatformDetectorRay

func _ready():
	default_position = position

func _physics_process(delta):
	if platform_detector_ray.is_colliding():
		position += platform_detector_ray.get_collider().get_position_changed() * delta
		return
	if not is_on_floor() and not lifted:
		velocity.y += get_gravity() * delta
	move_and_slide()

func _process(_delta):
	if lifted:
		sprite.play("invisible")
	else:
		sprite.play("visible")

func get_gravity():
	return default_gravity

func set_lifted(lift_bool: bool):
	lifted = lift_bool
	#change collision layer and mask
	if lifted:
		collision_shape_2d.disabled = true
	else:
		collision_shape_2d.disabled = false
		
func reset_position():
	position = default_position
	set_lifted(false)

func change_gravity(grav: float):
	default_gravity = grav
