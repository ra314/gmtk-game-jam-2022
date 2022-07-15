extends Node2D

const GRID_SIDE_LENGTH := 128

const FRONT = 1
const BACK = 2
const LEFT = 3
const RIGHT = 4
const TOP = 5
const BOTTOM = 6
var dice := []
var curr_grid_pos := Vector2(1,1)
const FALL_TILE_GRID_POS = Vector2(3,0)

func initialize_dice() -> Array:
	var dice := [0,0,0,0,0,0,0]
	dice[TOP] = 1
	dice[FRONT] = 4
	dice[RIGHT] = 5
	dice[LEFT] = 2
	dice[BACK] = 3
	dice[BOTTOM] = 6
	return dice

func roll_forward() -> Array:
	var new_dice := dice.duplicate()
	new_dice[FRONT] = dice[TOP]
	new_dice[TOP] = dice[BACK]
	new_dice[BACK] = dice[BOTTOM]
	new_dice[BOTTOM] = dice[FRONT]
	return new_dice

func roll_backward() -> Array:
	var new_dice := dice.duplicate()
	new_dice[TOP] = dice[FRONT]
	new_dice[BACK] = dice[TOP]
	new_dice[BOTTOM] = dice[BACK]
	new_dice[FRONT] = dice[BOTTOM]
	return new_dice

func roll_right() -> Array:
	var new_dice := dice.duplicate()
	new_dice[TOP] = dice[LEFT]
	new_dice[LEFT] = dice[BOTTOM]
	new_dice[BOTTOM] = dice[RIGHT]
	new_dice[RIGHT] = dice[TOP]
	return new_dice

func roll_left() -> Array:
	var new_dice := dice.duplicate()
	new_dice[LEFT] = dice[TOP]
	new_dice[BOTTOM] = dice[LEFT]
	new_dice[RIGHT] = dice[BOTTOM]
	new_dice[TOP] = dice[RIGHT]
	return new_dice

# Called when the node enters the scene tree for the first time.
func _ready():
	dice = initialize_dice()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("ui_right"):
		curr_grid_pos += Vector2(1,0)
		$Label.rect_position += Vector2(GRID_SIDE_LENGTH, 0)
		dice = roll_right()
	elif Input.is_action_just_released("ui_left"):
		curr_grid_pos -= Vector2(1,0)
		$Label.rect_position -= Vector2(GRID_SIDE_LENGTH, 0)
		dice = roll_left()
	elif Input.is_action_just_released("ui_up"):
		curr_grid_pos -= Vector2(0,1)
		$Label.rect_position -= Vector2(0, GRID_SIDE_LENGTH)
		dice = roll_backward()
	elif Input.is_action_just_released("ui_down"):
		curr_grid_pos += Vector2(0,1)
		$Label.rect_position += Vector2(0, GRID_SIDE_LENGTH)
		dice = roll_forward()
	$Label.text = str(dice[TOP])
	
	if curr_grid_pos == FALL_TILE_GRID_POS:
		curr_grid_pos -= Vector2(0,4)
		$Label.rect_position += Vector2(0, GRID_SIDE_LENGTH*4)
