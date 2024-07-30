extends CharacterBody2D

#constants
#movement
const DEFAULT_GROUND_SPEED: float = 190
const DEFAULT_AIR_SPEED: float = 190
const LIFTING_SPEED_PERCENTAGE: float = 0.55
const STARTUP_SPEED_PERCENTAGE: float = 0.77
const GROUND_DECELERATION: float = 30
const AIR_DECELERATION: float = 25
#jumping
const DEFAULT_JUMP_VELOCITY: float = -400
const PLATFORM_JUMP_HEIGHT: float = -320
const DEFAULT_RISE_GRAVITY: float = 1600
const DEFAULT_FALL_GRAVITY: float = 2200
const MAX_FALL_GRAVITY: float = 1050
const DOUBLE_JUMP_VELOCITY: float = -375
const JUMP_HOLD_GRAVITY: float = 500
const JUMP_BUFFER_TIME: float = 0.15
const JUMP_HOLD_TIME: float = 0.2
const COYOTE_TIME: float = 0.08
const WALL_SLIDE_SPEED: float = 100
const DEFAULT_WALL_JUMP_VELOCITY: float = -350
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
var control_disabled: bool = false
var paused: bool = false
#possible player buffs
var enabled_double_jump: bool = false
var enabled_wall_jump: bool = false
var enabled_glide: bool = false
var enabled_traps: bool = false
var enabled_lift: bool = false
var enabled_smart: bool = false
#vars for buffs
var can_double_jump: bool = true
var is_wall_sliding: bool = false
var wall_jumping: bool = false
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
var moved_by_platform: bool = false
var platform: StaticBody2D
var old_velocity: Vector2
var confused: bool
enum states {
	GROUNDED,
	AIRBORNE,
	DYING,
	WINNING,
	WALL_SLIDE,
}


@onready var leftray1: RayCast2D = $leftray1
@onready var rightray1: RayCast2D = $rightray1
@onready var leftray2 = $leftray2
@onready var rightray2 = $rightray2
@onready var wall_jump_timer: Timer = $Timers/Wall_Jump_Timer
@onready var run_start_timer = $Timers/Run_Start_Timer
@onready var dying_timer: Timer = $Timers/Dying_Timer
@onready var collision_shape_2d = $CollisionShape2D
@onready var jump_sound = $Sounds/jump_sound
@onready var death_sound = $Sounds/death_sound
@onready var pause_sound = $Sounds/pause_sound
@onready var resume_sound = $Sounds/resume_sound
@onready var wing_flap_sound = $Sounds/wing_flap_sound
@onready var sprite = $player_sprite
@onready var wings_sprite = $wings
@onready var spider_sprite = $spider
@onready var bulb_sprite = $bulb
@onready var confused_timer = $Timers/confused_timer
@onready var strong_sprite = $strong

signal player_died
signal player_won
signal player_restart

func _ready():
	player_state = states.AIRBORNE
	sprite.play("idle")
	sprite.pause()
	coyote_time_left = COYOTE_TIME
	jump_buffer_time_left = JUMP_BUFFER_TIME
	player_spawn_point = position
	collision_shape_2d.disabled = false
	wings_sprite.play("invisible")
	bulb_sprite.play("invisible")
	strong_sprite.play("invisible")
	spider_sprite.play("invisible")
	
func _process(_delta):
	animate_player()

func _physics_process(delta):
	match player_state:
		states.WINNING:
			velocity.y += DEFAULT_FALL_GRAVITY * delta
			velocity.x = 0
			move_and_slide()
		states.DYING:
			velocity.y = 0
			velocity.x = 0
			move_and_slide()
		_:
			if control_disabled:
				return
			if paused:
				if Input.is_action_just_pressed("restart"):
					player_restart.emit()
				if Input.is_action_just_pressed("show_cards"):
					if get_parent().show_cards(false):
						resume_sound.play()
						paused = false
						velocity = old_velocity
						if velocity.y > 0:
							velocity.y *= 0.5
			else:
				if Input.is_action_just_pressed("show_cards"):
					if get_parent().show_cards(true):
						pause_sound.play()
						paused = true
						old_velocity = velocity
			if not paused:
				handle_gravity(delta)
				handle_input_buffer(delta)
				handle_jump()
				handle_inputs()
				handle_movement()
				move_and_slide()
				if lifting:
					lifted_box.position = position
				if moved_by_platform and platform:
					position += platform.get_position_changed() * delta

func get_gravity() -> float:
	if velocity.y > 0:
		return rise_gravity
	return fall_gravity

func handle_gravity(delta) -> void:
	if not is_on_floor() and not moved_by_platform:
		coyote_time_left -= delta
		if is_on_wall() and enabled_wall_jump and velocity.y >= -30 and not lifting:
			#wall slide
			current_wall_direction = wall_direction()
			if (current_wall_direction == "left" and Input.is_action_pressed("left") or 
				current_wall_direction == "right" and Input.is_action_pressed("right")):
				#player holding wall slide direction, apply wall slide gravity
				is_wall_sliding = true
				velocity.y = WALL_SLIDE_SPEED
				player_state = states.WALL_SLIDE
			else:
				#player not holding wall slide direction, so apply normal gravity
				velocity.y += get_gravity() * delta
				is_wall_sliding = false
				player_state = states.AIRBORNE
			return
		if Input.is_action_pressed("jump") and jump_time < JUMP_HOLD_TIME and velocity.y < 0:
			#make player jump higher when holding jump
			jump_time += delta
			velocity.y += JUMP_HOLD_GRAVITY * delta
		elif Input.is_action_pressed("jump") and enabled_glide and velocity.y >= 0:
			#if glide is enabled, make player glide while falling and holding jump
			velocity.y = GLIDE_VELOCITY
		else:
			#apply gravity normally
			velocity.y += get_gravity() * delta
		is_wall_sliding = false
		player_state = states.AIRBORNE
	else:
		#player is grounded
		player_state = states.GROUNDED
		jump_time = 0.0
		coyote_time_left = COYOTE_TIME
		is_wall_sliding = false
		can_double_jump = true
	velocity.y = min(velocity.y, MAX_FALL_GRAVITY)

func wall_direction() -> String:
	#get the direction of the wall touching the player
	leftray1.force_raycast_update()
	rightray1.force_raycast_update()
	leftray2.force_raycast_update()
	rightray2.force_raycast_update()
	if leftray1.is_colliding() or leftray2.is_colliding():
		return "left"
	elif rightray1.is_colliding() or leftray2.is_colliding():
		return "right"
	return "none"

func handle_input_buffer(delta) -> void:
	#get inputs and use input buffers to make game feel more responsive
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
			#player is holding a box
			if player_state != states.GROUNDED:
				#only drop the box when on the ground
				return
			if sprite.flip_h == false:
				#facing right
				if rightray1.is_colliding() or rightray2.is_colliding():
					return
				lifted_box.position = position + Vector2(16, -5)
				position -= Vector2(3, 0)
			else:
				#facing left
				if leftray1.is_colliding() or leftray2.is_colliding():
					return
				lifted_box.position = position + Vector2(-16, -5)
				position += Vector2(3, 0)
			lifting = false
			lifted_box.set_lifted(false)
			lifted_box.set_disabled(false)
			lifted_box = null
			player_state = states.AIRBORNE
			interact_buffer_time_left = 0
			if enabled_double_jump:
				wings_sprite.play("visible")
		elif player_state == states.GROUNDED:
			if sprite.flip_h == false:
				#facing the right
				if rightray1.is_colliding():
					if rightray1.get_collider().is_in_group("liftable"):
						if not enabled_lift:
							confused = true
							confused_timer.start()
						else:
							#player is trying to grab a box
							strong_sprite.play("visible")
							lifting = true
							lifted_box = rightray1.get_collider()
							lifted_box.set_lifted(true)
							wings_sprite.play("invisible")
					elif rightray1.get_collider().is_in_group("lever"):
						#player is trying to toggle a lever
						if not enabled_smart:
							confused = true
							confused_timer.start()
						else:
							bulb_sprite.play("visible")
							rightray1.get_collider().toggle()
				interact_buffer_time_left = 0
			elif sprite.flip_h == true:
				#facing the left
				#note: this is repeated code. could not make simpler as it did not work for some reason
				if leftray1.is_colliding():
					if leftray1.get_collider().is_in_group("liftable"):
						if not enabled_lift:
							confused = true
							confused_timer.start()
						else:
							#player is trying to grab a box
							strong_sprite.play("visible")
							lifting = true
							lifted_box = leftray1.get_collider()
							lifted_box.set_lifted(true)
							wings_sprite.play("invisible")
					elif leftray1.get_collider().is_in_group("lever"):
						#player is trying to toggle a lever
						if not enabled_smart:
							confused = true
							confused_timer.start()
						else:
							bulb_sprite.play("visible")
							leftray1.get_collider().toggle()
				interact_buffer_time_left = 0
				
		
func handle_jump() -> void:
	if jump_buffer_time_left > 0 and not lifting:
		#jump if player pressed jump within acceptable time and isnt holding a box
		if player_state == states.GROUNDED or coyote_time_left > 0:
			#jump if on the ground or recently left ground within acceptable time
			jump_sound.play()
			velocity.y = jump_velocity
		elif (is_wall_sliding or wall_direction() != "none") and enabled_wall_jump:
			#player is sliding on a wall, jump off of it
			jump_sound.play()
			velocity.y = wall_jump_velocity
			wall_jumping = true
			wall_jump_timer.start()
			last_wall_direction = wall_direction()
		elif can_double_jump and enabled_double_jump:
			#double jump if able
			wing_flap_sound.play()
			velocity.y = DOUBLE_JUMP_VELOCITY
			can_double_jump = false
		jump_buffer_time_left = 0
		jump_time = 0.0

func platform_hop() -> void:
	velocity.y = PLATFORM_JUMP_HEIGHT
	moved_by_platform = false

func on_moving_platform() -> void:
	moved_by_platform = true

func handle_movement() -> void:
	direction = Input.get_axis("left", "right")
	if wall_jumping and enabled_wall_jump:
		#give horizontal movement when jumping off a wall
		if last_wall_direction == "left":
			velocity.x = air_speed
		else:
			velocity.x = -air_speed
		return
	elif direction:
		#player is holding left or right (but not both)
		if player_state == states.GROUNDED:
			if velocity.x == 0:
				#player just began to run
				run_start_timer.stop()
				run_start_timer.start()
				run_start = true
			if run_start:
				#make run startup slightly slower
				velocity.x = direction * ground_speed * STARTUP_SPEED_PERCENTAGE
			else:
				velocity.x = direction * ground_speed
		else:
			velocity.x = direction * air_speed
		if lifting:
			#make player slower when lifting
			velocity.x *= LIFTING_SPEED_PERCENTAGE
	else:
		#player is not holding left or right (or is holding both)
		if player_state == states.GROUNDED:
			velocity.x = move_toward(velocity.x, 0, GROUND_DECELERATION)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_DECELERATION)


func die() -> void:
	#do death stuff here
	if player_state != states.DYING:
		player_state = states.DYING
		collision_shape_2d.disabled = true
		death_sound.play()
		dying_timer.start()
	
func reached_goal() -> void:
	#do goal stuff here
	if player_state != states.WINNING:
		player_state = states.WINNING
		player_won.emit()


func pause_level(pause_value: bool) -> void:
	paused = pause_value
	
func enable_player_control(value: bool) -> void:
	control_disabled = not value

func enable_double_jump(value: bool) -> void:
	if value:
		wings_sprite.play("visible")
	else:
		wings_sprite.play("invisible")
	enabled_double_jump = value

func enable_wall_jump(value: bool) -> void:	
	enabled_wall_jump = value

func enable_glide(value: bool) -> void:
	enabled_glide = value

func enable_traps(value: bool) -> void:
	enabled_traps = value

func enable_lift(value: bool) -> void:
	if lifting and value == false:
		#player drops box on himself and dies
		lifted_box.set_lifted(false)
		lifted_box.set_position(position)
		lifted_box.set_disabled(false)
		lifted_box = null
		lifting = false
		if player_state == states.GROUNDED:
			die()
		else:
			player_state = states.AIRBORNE
	if value:
		strong_sprite.play("visible")
	else:
		strong_sprite.play("invisible")
	enabled_lift = value
	
	
func enable_smart(value: bool) -> void:
	if value:
		bulb_sprite.play("visible")
	else:
		bulb_sprite.play("invisible")
	enabled_smart = value

func handle_flip() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
		spider_sprite.position.x = abs(spider_sprite.position.x) * -1
		bulb_sprite.position.x = abs(bulb_sprite.position.x)
		strong_sprite.position.x = abs(strong_sprite.position.x)
	elif velocity.x < 0:
		spider_sprite.position.x = abs(spider_sprite.position.x)
		bulb_sprite.position.x = abs(bulb_sprite.position.x) * -1
		strong_sprite.position.x = abs(strong_sprite.position.x) * -1
		sprite.flip_h = true

func animate_player() -> void:
	#handle animation logic
	if control_disabled:
		return
	handle_flip()
	match player_state:
		states.GROUNDED:
			spider_sprite.play("invisible")
			if velocity.x == 0:
				if Input.is_action_just_pressed("right"):
					sprite.flip_h = false
				elif Input.is_action_just_pressed("left"):
					sprite.flip_h = true
				if lifting:
					sprite.play("idle_box")
				elif confused:
					sprite.play("confused")
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
			spider_sprite.play("invisible")
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
			spider_sprite.play("visible")
			match wall_direction():
				"left":
					sprite.flip_h = false
				"right":
					sprite.flip_h = true
		states.DYING:
			spider_sprite.play("invisible")
			sprite.play("death")
		states.WINNING:
			spider_sprite.play("invisible")
			sprite.play("winning")

func _on_area_area_entered(area):
	if player_state == states.WINNING:
		return
	if area.is_in_group("killbox"):
		die()
	elif area.is_in_group("trap") and enabled_traps:
		die()
	elif area.is_in_group("goal"):
		area.get_parent().grab_coin()
		reached_goal()

func kill_player():
	player_died.emit()
	queue_free()
	
func _on_dying_timer_timeout():
	kill_player()

func _on_wall_jump_timer_timeout():
	wall_jumping = false

func _on_run_start_timer_timeout():
	run_start = false
	
func _on_feet_area_area_entered(area):
	if area.is_in_group("platform"):
		platform = area.get_parent()
		platform.started_moving.connect(on_moving_platform)
		platform.stopped_moving.connect(platform_hop)

func _on_feet_area_area_exited(area):
	if area.is_in_group("platform"):
		platform.started_moving.disconnect(on_moving_platform)
		platform.stopped_moving.disconnect(platform_hop)
		platform = null


func _on_confused_timer_timeout():
	confused = false


func _on_area_body_entered(body):
	if body.is_in_group("trap") and enabled_traps:
		die()
