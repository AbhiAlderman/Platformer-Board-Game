extends CharacterBody2D

#constants
#movement
const DEFAULT_GROUND_SPEED: float = 300
const DEFAULT_AIR_SPEED: float = 300
#jumping
const DEFAULT_JUMP_VELOCITY: float = -450.0
const DEFAULT_RISE_GRAVITY: float = 1600
const DEFAULT_FALL_GRAVITY: float = 2200
const JUMP_HOLD_GRAVITY: float = 600
const JUMP_BUFFER_TIME: float = 0.15
const JUMP_HOLD_TIME: float = 0.2
const COYOTE_TIME: float = 0.08

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
var disabled: bool = true

var player_state: states
enum states {
	GROUNDED,
	AIRBORNE,
	DYING,
	WINNING,
}

@onready var sprite = $AnimatedSprite2D
@onready var dying_timer = $Timers/Dying_Timer
@onready var winning_timer = $Timers/Winning_Timer

func _ready():
	player_state = states.GROUNDED
	coyote_time_left = COYOTE_TIME
	jump_buffer_time_left = JUMP_BUFFER_TIME


func _process(_delta):
	animate_player()

func _physics_process(delta):
	if player_state != states.DYING and player_state != states.WINNING and not disabled:
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
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time_left = JUMP_BUFFER_TIME
	if Input.is_action_just_released("jump"):
		jump_time = JUMP_HOLD_TIME

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

func die() -> void:
	#do death stuff here
	if player_state != states.DYING:
		player_state = states.DYING
		dying_timer.start()
	
func reached_goal() -> void:
	#do goal stuff here
	if player_state != states.WINNING:
		player_state = states.WINNING
		winning_timer.start()

func disable_player_control() -> void:
	disabled = true

func enable_player_control() -> void:
	disabled = false

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
		states.DYING:
			sprite.play("death")
		states.WINNING:
			sprite.play("winning")

func _on_area_area_entered(area):
	if area.is_in_group("killbox"):
		die()
	elif area.is_in_group("goal"):
		reached_goal()

func _on_dying_timer_timeout():
	get_parent().player_died()


func _on_winning_timer_timeout():
	get_parent().player_won()
