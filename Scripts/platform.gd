extends StaticBody2D

const MOVE_SPEED: float = 50

var goal_position: Vector2
var position_one: Vector2
var position_two: Vector2
var moving: bool
var assigned_lever
var position_change: Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	position_one = position
	goal_position = position_one
	moving = false
	position_change = Vector2(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
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
		moving = false
		assigned_lever.set_toggleable(true)
		position_change = Vector2(0, 0)

func switch_position() -> void:
	if not moving:
		moving = true
		assigned_lever.set_toggleable(false)
		if goal_position == position_one:
			goal_position = position_two
		else:
			goal_position = position_one
		
func assign_positions(pos1: Vector2, pos2: Vector2) -> void:
	position_one = pos1
	position = position_one
	goal_position = position_one
	position_two = pos2
	
func assign_lever(lever) -> void:
	assigned_lever = lever
	assigned_lever.set_toggleable(true)
	
func get_position_changed() -> Vector2:
	return position_change
