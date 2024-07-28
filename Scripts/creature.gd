extends CharacterBody2D


const SPEED: float = 100
const GRAVITY: float = 2200
# Get the gravity from the project settings to be synced with RigidBody nodes.
var facing_right: bool = false
var paused: bool = false
@onready var down_ray = $down_ray
@onready var straight_feet_ray = $straight_feet_ray
@onready var straight_chest_ray = $straight_chest_ray
@onready var straight_head_ray = $straight_head_ray
@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $CollisionShape2D
@onready var hurtbox = $killzone/CollisionShape2D

func _ready():
	sprite.play("run")

func _physics_process(delta):
	if paused:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	check_rays()
	if facing_right:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED
	move_and_slide()

func check_rays():
	if straight_rays_colliding() or !down_ray.is_colliding():
		flip_direction()
		
func flip_direction() -> void:
	if facing_right:
		facing_right = false
		sprite.flip_h = false
		hitbox.position.x = abs(hitbox.position.x) * -1
		hurtbox.position.x = abs(hurtbox.position.x) * -1
		down_ray.position.x = abs(down_ray.position.x) * -1
		straight_chest_ray.target_position.x = abs(straight_chest_ray.target_position.x) * -1
		straight_feet_ray.target_position.x = abs(straight_feet_ray.target_position.x) * -1
		straight_head_ray.target_position.x = abs(straight_head_ray.target_position.x) * -1
	else:
		facing_right = true
		sprite.flip_h = true
		hitbox.position.x = abs(hitbox.position.x)
		hurtbox.position.x = abs(hurtbox.position.x)
		down_ray.position.x = abs(down_ray.position.x)
		straight_chest_ray.target_position.x = abs(straight_chest_ray.target_position.x)
		straight_feet_ray.target_position.x = abs(straight_feet_ray.target_position.x)
		straight_head_ray.target_position.x = abs(straight_head_ray.target_position.x)
	

func straight_rays_colliding() -> bool:
	return straight_chest_ray.is_colliding() or straight_feet_ray.is_colliding() or straight_head_ray.is_colliding()
	
func pause_level(value: bool) -> void:
	paused = value
	if value:
		sprite.pause()
	else:
		sprite.play("run")

