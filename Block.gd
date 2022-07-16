extends Node2D

const GRID_SIDE_LENGTH := 128
var position_to_move_to := Vector2()
var curr_grid_pos := Vector2(12,-4)
onready var tile_layer1 = get_parent().get_node("TileLayer1")

var move_dir_to_grid_pos_modifier = {"ui_right": Vector2(0,-1), # NE
									 "ui_up": Vector2(-1,0), # NW
									 "ui_down": Vector2(1,0), # SE
									 "ui_left": Vector2(0,1)} # Sw
var move_dir_to_pos_modifier = {"ui_right": Vector2(1,-1), # NE
								"ui_up": Vector2(-1,-1), # NW
								"ui_down": Vector2(1,1), # SE
								"ui_left": Vector2(-1,1)} # Sw
const FALL_TILE_ENUM := 3
const BOUNCE_TILE_ENUM := 5
const INVALID_TILE_ENUM := -1
const WIN_TILE_ENUM := 6
var TILE_SIZE: Vector2
var SCALE: Vector2

func get_curr_cell(pos: Vector2) -> int:
	return tile_layer1.get_cell(pos[0], pos[1])

# Check if 
func get_die_pos(pos: Vector2) -> Vector2:
	return get_parent().curr_grid_pos

func _ready():

	TILE_SIZE = tile_layer1.cell_size
	SCALE = tile_layer1.scale/16
	position_to_move_to = $Sprite.position

func _process(delta):
	$Sprite.z_index = 2+(position.y+$Sprite.position.y)
	for ui_direction in move_dir_to_grid_pos_modifier.keys():
		if Input.is_action_just_released(ui_direction):
			var next_grid_pos: Vector2 = curr_grid_pos + move_dir_to_grid_pos_modifier[ui_direction]
			var prev_grid_pos: Vector2 = curr_grid_pos - move_dir_to_grid_pos_modifier[ui_direction]
			if get_curr_cell(next_grid_pos) == INVALID_TILE_ENUM:
				break
			if get_die_pos(prev_grid_pos) != curr_grid_pos:
				break 
			# Update grid pos
			curr_grid_pos = next_grid_pos
			# Update the position of the block within the game
			position_to_move_to += (TILE_SIZE*SCALE*move_dir_to_pos_modifier[ui_direction])
			break
	$Sprite.position = lerp($Sprite.position, position_to_move_to, 0.3)
