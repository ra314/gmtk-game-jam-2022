extends Node2D

const GRID_SIDE_LENGTH := 128

const FRONT = 1
const BACK = 2
const LEFT = 3
const RIGHT = 4
const TOP = 5
const BOTTOM = 6
var dice := []

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



# Look at the scene to obtain this value
var curr_grid_pos := Vector2(7,-1)

const FALL_TILE_ENUM := 3
const INVALID_TILE_ENUM := -1
var TILE_SIZE: Vector2
var SCALE: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	dice = initialize_dice()
	TILE_SIZE = $TileLayer1.cell_size
	SCALE = $TileLayer1.scale/2

func get_curr_cell(pos: Vector2) -> int:
	return $TileLayer1.get_cell(pos[0], pos[1])

var move_dir_to_grid_pos_modifier = {"ui_right": Vector2(0,-1), # NE
									 "ui_up": Vector2(-1,0), # NW
									 "ui_down": Vector2(1,0), # SE
									 "ui_left": Vector2(0,1)} # Sw

var move_dir_to_pos_modifier = {"ui_right": Vector2(1,-1), # NE
								"ui_up": Vector2(-1,-1), # NW
								"ui_down": Vector2(1,1), # SE
								"ui_left": Vector2(-1,1)} # Sw

var move_dir_to_roll_func = {"ui_right": "roll_right",
								"ui_up": "roll_left",
								"ui_down": "roll_backward",
								"ui_left": "roll_forward"}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for ui_direction in move_dir_to_grid_pos_modifier.keys():
		if Input.is_action_just_released(ui_direction):
			# Validate if the dice is within bounds
			var next_grid_pos: Vector2 = curr_grid_pos + move_dir_to_grid_pos_modifier[ui_direction]
			if get_curr_cell(next_grid_pos) == INVALID_TILE_ENUM:
				break
			# Update grid pos
			curr_grid_pos = next_grid_pos
			# Update the position of the dice within the game
			$Sprite.position += TILE_SIZE*SCALE*move_dir_to_pos_modifier[ui_direction]
			# Rotate the dice's faces
			dice = call(move_dir_to_roll_func[ui_direction])
			break
	
	if get_curr_cell(curr_grid_pos) == FALL_TILE_ENUM:
		curr_grid_pos += Vector2(4,4)
		$Sprite.position += TILE_SIZE*SCALE*Vector2(0,8)
