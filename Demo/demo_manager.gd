@tool
class_name DemoManager
extends Node


var previous_demo_player : DemoPlayer = null : set = set_previous_demo_player


func _ready() -> void:
	for child : Node in get_children():
		child = child as DemoPlayer
		if child == null: return

		child.played.connect(set_previous_demo_player)


func set_previous_demo_player(demo_player : DemoPlayer) -> void:
	if previous_demo_player != null:
		previous_demo_player.set_play_demo(false)

	previous_demo_player = demo_player
