extends Node2D

onready var player = get_parent()
var base_z := z_index

func _process(delta):
	if !"Level" in player.name:
		player = player.get_parent()
	else:
		player = player.get_node("Sprite")
	z_index = base_z - player.z_index
