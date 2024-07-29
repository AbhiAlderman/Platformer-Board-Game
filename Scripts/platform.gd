extends StaticBody2D

const MOVE_SPEED: float = 50

@onready var sprite = $AnimatedSprite2D

var goal_position: Vector2
var position_one: Vector2
var position_two: Vector2
var moving: bool
var assigned_lever
var position_change: Vector2
var paused: bool
var blue: bool
signal started_moving
signal stopped_moving
# Called when the node enters the scene tree for the first time.
func _ready():
	position_one = position
	goal_position = position_one
	moving = false
	position_change = Vector2(0, 0)
	paused = false
	blue = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _physics_process(delta):
	if paused:
		return
	if position != goal_position:
		moving = true
		if abs(position.x - goal_position.x) < 5:
			position.x = goal_position.x
			position_change.x = 0
		else:
			if position.x < goal_position.x:
				position_change.x = MOVE_SPEED
				position.x += MOVE_SPEED * delta
			else:
				position_change.x = -MOVE_SPEED
				position.x -= MOVE_SPEED * delta
		if abs(position.y - goal_position.y) < 5:
			position.y = goal_position.y
			position_change.y = 0
		else:
			if position.y < goal_position.y:
				position_change.y = MOVE_SPEED
				position.y += MOVE_SPEED * delta
			else:
				position_change.y = -MOVE_SPEED
				position.y -= MOVE_SPEED * delta
	else:
		if moving:
			stopped_moving.emit()
		moving = false
		assigned_lever.set_toggleable(true)
		position_change = Vector2(0, 0)

func switch_position() -> void:
	if not moving:
		toggle_color()
		moving = true
		started_moving.emit()
		assigned_lever.set_toggleable(false)
		if goal_position == position_one:
			goal_position = position_two
			sprite.play("purple")
		else:
			goal_position = position_one
			sprite.play("blue")
		
func assign_positions(pos1: Vector2, pos2: Vector2) -> void:
	position_one = pos1
	position = position_one
	goal_position = position_one
	position_two = pos2
	
func assign_lever(lever) -> void:
	assigned_lever = lever
	assigned_lever.set_toggleable(true)
	
func toggle_color():
	if blue:
		sprite.play("purple")
	else:
		sprite.play("blue")
	blue = not blue
func get_position_changed() -> Vector2:
	return position_change
	
func pause_level(paused_value) -> void:
	paused = paused_value
	
