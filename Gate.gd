extends Node2D

const GRID_SIDE_LENGTH := 128
var position_to_move_to := Vector2()
onready var tile_layer1 = get_parent().get_node("TileLayer1")
export var curr_grid_pos = Vector2(12, -4)

func _ready():
	$AnimationPlayer.stop()

func _process(delta):
	z_index = 2+(position.y)
func fade() -> void:
	$AnimationPlayer.play()
