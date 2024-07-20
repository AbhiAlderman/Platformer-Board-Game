extends CharacterBody2D

#constants
#movement
const DEFAULT_GROUND_SPEED: float = 350
const DEFAULT_AIR_SPEED: float = 350
#jumping
const DEFAULT_JUMP_VELOCITY: float = -500.0
const DEFAULT_RISE_GRAVITY: float = 1600
const DEFAULT_FALL_GRAVITY: float = 2200
const JUMP_HOLD_GRAVITY: float = 600
const JUMP_BUFFER_TIME: float = 0.15
const JUMP_HOLD_TIME: float = 0.2
const COYOTE_TIME: float = 0.1

#variables
var coyote_time_left: float = 0.0
var jump_buffer_time_left: float = 0.0
var jump_time: float = 0.0
var direction: float = 0.0
var fall_gravity: float = DEFAULT_FALL_GRAVITY
var rise_gravity: float = DEFAULT_RISE_GRAVITY
var ground_speed: float = DEFAULT_GROUND_SPEED
var air_speed: float = DEFAULT_AIR_SPEED
var jump_velocity: float = DEFAULT_JUMP_VELOCITY
var player_state: states
enum states {
	GROUNDED,
	AIRBORNE,
}

@onready var sprite = $AnimatedSprite2D

func _ready():
	player_state = states.GROUNDED
	coyote_time_left = COYOTE_TIME
	jump_buffer_time_left = JUMP_BUFFER_TIME


func _process(_delta):
	animate_player()

func _physics_process(delta):
	handle_gravity(delta)
	handle_input_buffer(delta)
	handle_jump()
	handle_movement()
	move_and_slide()

func get_gravity() -> float:
	if velocity.y > 0:
		return rise_gravity
	return fall_gravity

func handle_gravity(delta) -> void:
	if not is_on_floor():
		coyote_time_left -= delta
		player_state = states.AIRBORNE
		if Input.is_action_pressed("jump") and jump_time < JUMP_HOLD_TIME and velocity.y < 0:
			jump_time += delta
			velocity.y += JUMP_HOLD_GRAVITY * delta
			player_state = states.AIRBORNE
		else:
			velocity.y += get_gravity() * delta
	else:
		player_state = states.GROUNDED
		jump_time = 0.0
		coyote_time_left = COYOTE_TIME

func handle_input_buffer(delta) -> void:
	jump_buffer_time_left -= delta
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_time_left = JUMP_BUFFER_TIME

func handle_jump() -> void:
	if jump_buffer_time_left > 0:
		if player_state == states.GROUNDED or coyote_time_left > 0:
			velocity.y = jump_velocity
			player_state = states.AIRBORNE
			jump_buffer_time_left = 0
			jump_time = 0.0

func handle_movement() -> void:
	direction = Input.get_axis("left", "right")
	if player_state == states.GROUNDED:
		velocity.x = direction * ground_speed
	else:
		velocity.x = direction * air_speed

func handle_flip() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func animate_player() -> void:
	handle_flip()
	match player_state:
		states.GROUNDED:
			if velocity.x == 0:
				sprite.play("idle")
			else:
				sprite.play("run")
		states.AIRBORNE:
			if velocity.y < 0:
				sprite.play("jump_rise")
			elif velocity.y > 0:
				sprite.play("jump_fall")
			else:
				sprite.play("jump_peak")
	

