extends Node2D

const GRID_SIDE_LENGTH := 128

const FRONT = 1
const BACK = 2
const LEFT = 3
const RIGHT = 4
const TOP = 5
const BOTTOM = 6
export(int) var win_number = 5

var top_is_flipped := false
var left_is_flipped := false
var right_is_flipped := false
var rightback_is_flipped := false
var leftback_is_flipped := false

var die := []
var position_to_move_to := Vector2()

func initialize_die() -> Array:
	var die := [0,0,0,0,0,0,0]
	die[TOP] = 1
	die[FRONT] = 4
	die[RIGHT] = 5
	die[LEFT] = 2
	die[BACK] = 3
	die[BOTTOM] = 6
	return die

func roll_forward() -> Array:
	var new_die := die.duplicate()
	new_die[FRONT] = die[TOP]
	new_die[TOP] = die[BACK]
	new_die[BACK] = die[BOTTOM]
	new_die[BOTTOM] = die[FRONT]
	return new_die

func roll_backward() -> Array:
	var new_die := die.duplicate()
	new_die[TOP] = die[FRONT]
	new_die[BACK] = die[TOP]
	new_die[BOTTOM] = die[BACK]
	new_die[FRONT] = die[BOTTOM]
	return new_die

func roll_right() -> Array:
	var new_die := die.duplicate()
	new_die[TOP] = die[LEFT]
	new_die[LEFT] = die[BOTTOM]
	new_die[BOTTOM] = die[RIGHT]
	new_die[RIGHT] = die[TOP]
	return new_die

func roll_left() -> Array:
	var new_die := die.duplicate()
	new_die[LEFT] = die[TOP]
	new_die[BOTTOM] = die[LEFT]
	new_die[RIGHT] = die[BOTTOM]
	new_die[TOP] = die[RIGHT]
	return new_die



# Look at the scene to obtain this value
var curr_grid_pos := Vector2(7,-1)

const FALL_TILE_ENUM := 3
const BOUNCE_TILE_ENUM := 5
const INVALID_TILE_ENUM := -1
const WIN_TILE_ENUM := 6
const GATE_TILE_ENUM := 7
var TILE_SIZE: Vector2
var SCALE: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	die = initialize_die()
	TILE_SIZE = $TileLayer1.cell_size
	SCALE = $TileLayer1.scale/2
	position_to_move_to = $Sprite.position
	$Sprite/Camera2D.offset_v = -100

func get_curr_cell(pos: Vector2) -> int:
	return $TileLayer1.get_cell(pos[0], pos[1])
func get_curr_cell_layer2(pos: Vector2) -> int:
	return $TileLayer2.get_cell(pos[0], pos[1])
	
func animate_die(direction) -> void:
	if (direction == "ui_up") or (direction == "ui_down"):
		left_is_flipped = !left_is_flipped
		rightback_is_flipped = !rightback_is_flipped
	if (direction == "ui_left") or (direction == "ui_right"):
		right_is_flipped = !right_is_flipped
		leftback_is_flipped = !leftback_is_flipped
	if direction == "ui_up":
		leftback_is_flipped = top_is_flipped
		top_is_flipped = right_is_flipped
	if direction == "ui_down":
		right_is_flipped = top_is_flipped
		top_is_flipped = leftback_is_flipped
	if direction == "ui_right":
		rightback_is_flipped = top_is_flipped
		top_is_flipped = left_is_flipped
	if direction == "ui_left":
		left_is_flipped = top_is_flipped
		top_is_flipped = rightback_is_flipped


var move_dir_to_grid_pos_modifier = {"ui_right": Vector2(0,-1), # NE
									 "ui_up": Vector2(-1,0), # NW
									 "ui_down": Vector2(1,0), # SE
									 "ui_left": Vector2(0,1)} # Sw

var move_dir_to_pos_modifier = {"ui_right": Vector2(1,-1), # NE
								"ui_up": Vector2(-1,-1), # NW
								"ui_down": Vector2(1,1), # SE
								"ui_left": Vector2(-1,1)} # Sw

var move_dir_to_roll_func = {"ui_right": "roll_right",
							 "ui_up": "roll_backward",
							 "ui_down": "roll_forward",
							 "ui_left": "roll_left"}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	print("left: " + str(left_is_flipped))
	print("top: " + str(top_is_flipped))
	# Set z_index
	$Sprite.z_index = 4+($Sprite.position.y)
	# Intro Camera
	if $Sprite/Camera2D.offset_v != 0:
		$Sprite/Camera2D.offset_v = 0
	for ui_direction in move_dir_to_grid_pos_modifier.keys():
		if Input.is_action_just_released(ui_direction):
			# Validate if the die is within bounds
			var next_grid_pos: Vector2 = curr_grid_pos + move_dir_to_grid_pos_modifier[ui_direction]
			if get_curr_cell(next_grid_pos) == INVALID_TILE_ENUM:
				break
			# Check if die is colliding with block
			if has_node("Block"):
				if $Block.curr_grid_pos == next_grid_pos:
					if get_curr_cell(next_grid_pos+ move_dir_to_grid_pos_modifier[ui_direction]) == INVALID_TILE_ENUM:
						break
			# Update grid pos
			curr_grid_pos = next_grid_pos
			# Update the position of the die within the game
			position_to_move_to += (TILE_SIZE*SCALE*move_dir_to_pos_modifier[ui_direction])
			# Rotate the die's faces
			die = call(move_dir_to_roll_func[ui_direction])

			# Animate Die
			animate_die(ui_direction)
			break
	# Set Number/Flipped/Offset

	$Sprite/Numberleft.frame = die[LEFT]-1
	$Sprite/Numberright.frame = die[FRONT]-1
	$Sprite/Numbertop.frame = die[TOP]-1
	$Sprite/Numberleft.offset = $Sprite.offset
	$Sprite/Numberright.offset = $Sprite.offset
	$Sprite/Numbertop.offset = $Sprite.offset

	$Sprite/Numberleft.texture = load("res://Assets/Die Sides/DieLeft" + str(left_is_flipped) + ".png")
	$Sprite/Numberright.texture = load("res://Assets/Die Sides/DieRight" + str(right_is_flipped) + ".png")
	$Sprite/Numbertop.texture = load("res://Assets/Die Sides/DieTop" + str(top_is_flipped) + ".png")

	if get_curr_cell(curr_grid_pos) == FALL_TILE_ENUM:
		curr_grid_pos += Vector2(4,4)
		position_to_move_to += TILE_SIZE*SCALE*Vector2(0,8)
	if get_curr_cell_layer2(curr_grid_pos) == BOUNCE_TILE_ENUM:
		curr_grid_pos -= Vector2(4,4)
		position_to_move_to -= TILE_SIZE*SCALE*Vector2(0,8)
	
	if get_curr_cell(curr_grid_pos) == WIN_TILE_ENUM:
		if die[TOP] == win_number:
			print(get_tree().get_current_scene().get_name())
			get_tree().change_scene("res://Level" + str(int(get_tree().current_scene.name) + 1) + ".tscn")
	if get_curr_cell(curr_grid_pos) == WIN_TILE_ENUM:
		if die[TOP] == win_number:
			print(get_tree().get_current_scene().get_name())
			get_tree().change_scene("res://Level" + str(int(get_tree().current_scene.name) + 1) + ".tscn")
	$Sprite.position = lerp($Sprite.position, position_to_move_to, 0.3)
