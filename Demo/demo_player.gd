@tool
class_name DemoPlayer
extends Node


@export var play_demo : bool = false : set = set_play_demo


@export_category("Demo Configuration")
@export var audio_stream_player : AudioStreamPlayer
@export var lfo : LFO
@export var bus_name : String
@export var parameter_tweener : LFOTweener = null


signal played()


func set_play_demo(new_state : bool) -> void:
	play_demo = new_state
	if new_state:
		played.emit(self)
		if parameter_tweener != null:
			parameter_tweener.tween_lfo()
		audio_stream_player.bus = bus_name
		audio_stream_player.play()
		lfo.start()

	else:
		if parameter_tweener != null:
			parameter_tweener.kill_tween()
		audio_stream_player.stop()
		lfo.stop()
