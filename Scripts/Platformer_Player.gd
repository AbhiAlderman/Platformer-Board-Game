extends CharacterBody2D

#constants
#movement
const DEFAULT_GROUND_SPEED: float = 200
const DEFAULT_AIR_SPEED: float = 200
const BOOSTED_GROUND_SPEED: float = 260
const BOOSTED_AIR_SPEED: float = 260
const LIFTING_SPEED_PERCENTAGE: float = 0.55
const GROUND_DECELERATION: float = 30
const AIR_DECELERATION: float = 25
#jumping
const DEFAULT_JUMP_VELOCITY: float = -450.0
const BOOSTED_JUMP_VELOCITY: float = -550.0
const DEFAULT_RISE_GRAVITY: float = 1600
const DEFAULT_FALL_GRAVITY: float = 2200
const JUMP_HOLD_GRAVITY: float = 600
const JUMP_BUFFER_TIME: float = 0.15
const JUMP_HOLD_TIME: float = 0.2
const COYOTE_TIME: float = 0.08
const WALL_SLIDE_SPEED: float = 100
const DEFAULT_WALL_JUMP_VELOCITY: float = -350
const BOOSTED_WALL_JUMP_VELOCITY: float = -450
const GLIDE_VELOCITY: float = 150
#for buffs
const INTERACT_BUFFER_TIME: float = 0.12
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
#possible player buffs
var enabled_double_jump: bool = false
var enabled_wall_jump: bool = false
var enabled_glide: bool = false
var enabled_traps: bool = false
#vars for buffs
var can_double_jump: bool = true
var is_wall_sliding: bool = false
var wall_jumping: bool = false
var flipping: bool = false
var current_wall_direction: String = ""
var last_wall_direction: String = ""
var wall_jump_velocity: float = DEFAULT_WALL_JUMP_VELOCITY
var player_spawn_point: Vector2
var player_state: states
var wall_speed: float
var run_start: bool = false
var lifting: bool = false
var interact_buffer_time_left: float = 0.0
var lifted_box = null
enum states {
	GROUNDED,
	AIRBORNE,
	DYING,
	WINNING,
	WALL_SLIDE,
}


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dying_timer: Timer = $Timers/Dying_Timer
@onready var leftray: RayCast2D = $leftray
@onready var rightray: RayCast2D = $rightray
@onready var wall_jump_timer: Timer = $Timers/Wall_Jump_Timer
@onready var run_start_timer = $Timers/Run_Start_Timer


func _ready():
	player_state = states.AIRBORNE
	coyote_time_left = COYOTE_TIME
	jump_buffer_time_left = JUMP_BUFFER_TIME
	player_spawn_point = position
	
func _process(_delta):
	animate_player()

func _physics_process(delta):
	if player_state != states.DYING and player_state != states.WINNING and not disabled:
		handle_gravity(delta)
		handle_input_buffer(delta)
		handle_jump()
		handle_inputs()
		handle_movement()
		move_and_slide()
		if lifting:
			lifted_box.position = position

func get_gravity() -> float:
	if velocity.y > 0:
		return rise_gravity
	return fall_gravity

func handle_gravity(delta) -> void:
	if not is_on_floor():
		coyote_time_left -= delta
		if is_on_wall() and enabled_wall_jump and velocity.y >= 0:
			current_wall_direction = wall_direction()
			if (current_wall_direction == "left" and Input.is_action_pressed("left") or 
				current_wall_direction == "right" and Input.is_action_pressed("right")):
				is_wall_sliding = true
				flipping = false
				velocity.y = WALL_SLIDE_SPEED
				player_state = states.WALL_SLIDE
			else:
				velocity.y += get_gravity() * delta
				is_wall_sliding = false
				player_state = states.AIRBORNE
			return
		if Input.is_action_pressed("jump") and jump_time < JUMP_HOLD_TIME and velocity.y < 0:
			jump_time += delta
			velocity.y += JUMP_HOLD_GRAVITY * delta
		elif Input.is_action_pressed("jump") and enabled_glide and velocity.y >= 0:
			velocity.y = GLIDE_VELOCITY
		else:
			velocity.y += get_gravity() * delta
		is_wall_sliding = false
		player_state = states.AIRBORNE
	else:
		player_state = states.GROUNDED
		jump_time = 0.0
		coyote_time_left = COYOTE_TIME
		is_wall_sliding = false
		flipping = false
		can_double_jump = true

func wall_direction() -> String:
	leftray.force_raycast_update()
	rightray.force_raycast_update()
	if is_on_wall():
		if leftray.is_colliding():
			return "left"
		elif rightray.is_colliding():
			return "right"
	return "none"

func handle_input_buffer(delta) -> void:
	jump_buffer_time_left = max(jump_buffer_time_left - delta, 0)
	interact_buffer_time_left = max(interact_buffer_time_left - delta, 0)
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time_left = JUMP_BUFFER_TIME
	if Input.is_action_just_released("jump"):
		jump_time = JUMP_HOLD_TIME
	if Input.is_action_just_pressed("interact"):
		interact_buffer_time_left = INTERACT_BUFFER_TIME

func handle_inputs() -> void:
	if interact_buffer_time_left > 0:
		if lifting:
			if sprite.flip_h == false:
				#facing right
				if rightray.is_colliding():
					return
				lifted_box.position = position + Vector2(16, 0)
				position -= Vector2(3, 0)
			else:
				if leftray.is_colliding():
					return
				lifted_box.position = position + Vector2(-16, 0)
				position += Vector2(3, 0)
			lifting = false
			lifted_box.set_lifted(false)
			lifted_box = null
			player_state = states.AIRBORNE
			interact_buffer_time_left = 0
		elif player_state == states.GROUNDED:
			if sprite.flip_h == false:
				#facing the right
				if rightray.is_colliding():
					print("GROUPS ARE: " + str(rightray.get_collider().get_groups()))
					if rightray.get_collider().is_in_group("liftable"):
						lifting = true
						lifted_box = rightray.get_collider()
						lifted_box.set_lifted(true)
					elif rightray.get_collider().is_in_group("lever"):
						rightray.get_collider().toggle()
				interact_buffer_time_left = 0
			elif sprite.flip_h == true:
				#facing the left
				if leftray.is_colliding():
					print("GROUPS ARE: " + str(leftray.get_collider().get_groups()))
					if leftray.get_collider().is_in_group("liftable"):
						lifting = true
						lifted_box = leftray.get_collider()
						lifted_box.set_lifted(true)
					elif leftray.get_collider().is_in_group("lever"):
						leftray.get_collider().toggle()
				interact_buffer_time_left = 0
				
		
func handle_jump() -> void:
	if jump_buffer_time_left > 0 and not lifting:
		if player_state == states.GROUNDED or coyote_time_left > 0:
			velocity.y = jump_velocity
		elif is_wall_sliding and enabled_wall_jump:
			velocity.y = wall_jump_velocity
			wall_jumping = true
			wall_jump_timer.start()
			last_wall_direction = wall_direction()
		elif can_double_jump and enabled_double_jump:
			velocity.y = jump_velocity
			can_double_jump = false
		jump_buffer_time_left = 0
		jump_time = 0.0

func handle_movement() -> void:
	direction = Input.get_axis("left", "right")
	if wall_jumping and enabled_wall_jump:
		if last_wall_direction == "left":
			velocity.x = air_speed
		else:
			velocity.x = -air_speed
	elif direction:
		if player_state == states.GROUNDED:
			if velocity.x == 0:
				run_start_timer.stop()
				run_start_timer.start()
				run_start = true
			if run_start:
				velocity.x = direction * ground_speed * 0.7
			else:
				velocity.x = direction * ground_speed
		else:
			velocity.x = direction * air_speed
		if lifting:
			velocity.x *= LIFTING_SPEED_PERCENTAGE
	else:
		if player_state == states.GROUNDED:
			velocity.x = move_toward(velocity.x, 0, GROUND_DECELERATION)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_DECELERATION)

func respawn() -> void:
	wall_jumping = false
	flipping = false
	is_wall_sliding = false
	#replace this logic with spawning a "explosion" sprite at player pos so
	#player can instantly respawn
	player_state = states.DYING
	await get_tree().create_timer(dying_timer.wait_time).timeout
	player_state = states.AIRBORNE
	position = player_spawn_point
	lifting = false
	get_parent().reset_level()

func die() -> void:
	#do death stuff here
	if player_state != states.DYING:
		player_state = states.DYING
		dying_timer.start()
	
func reached_goal() -> void:
	#do goal stuff here
	if player_state != states.WINNING:
		player_state = states.WINNING
		get_parent().player_won()

func disable_player_control() -> void:
	disabled = true

func enable_player_control() -> void:
	disabled = false

func enable_double_jump() -> void:
	enabled_double_jump = true	

func enable_wall_jump() -> void:	
	enabled_wall_jump = true		

func enable_glide() -> void:
	enabled_glide = true

func enable_traps() -> void:
	enabled_traps = true
	
func enable_speed_boost() -> void:
	ground_speed = BOOSTED_GROUND_SPEED
	air_speed = BOOSTED_AIR_SPEED

func enable_jump_boost() -> void:
	jump_velocity = BOOSTED_JUMP_VELOCITY
	wall_jump_velocity = BOOSTED_WALL_JUMP_VELOCITY

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
				if lifting:
					sprite.play("idle_box")
				else:
					sprite.play("idle")
			else:
				if lifting:
					sprite.play("run_box")
				elif run_start_timer.is_stopped():
					sprite.play("run")
				else:
					sprite.play("run_start")
		states.AIRBORNE:
			if lifting:
				sprite.play("fall_box")
			elif velocity.y < -80:
				sprite.play("jump_rise")
			elif velocity.y > 80:
				sprite.play("jump_fall")
			else:
				sprite.play("jump_peak")
		states.WALL_SLIDE:
			sprite.play("wall_slide")
			match wall_direction():
				"left":
					sprite.flip_h = false
				"right":
					sprite.flip_h = true
		states.DYING:
			sprite.play("death")
		states.WINNING:
			sprite.play("winning")
func _on_area_area_entered(area):
	if area.is_in_group("killbox"):
		respawn()
	elif area.is_in_group("trap") and enabled_traps:
		respawn()
	elif area.is_in_group("goal"):
		reached_goal()

func _on_dying_timer_timeout():
	get_parent().player_died()
	queue_free()

func _on_wall_jump_timer_timeout():
	wall_jumping = false

func _on_run_start_timer_timeout():
	run_start = false
