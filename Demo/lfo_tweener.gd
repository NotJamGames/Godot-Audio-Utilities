@tool
class_name LFOTweener
extends Node


@export var lfo : LFO
@export var tween_range : Array[float] = [1.0, 10.0]
@export var tween_duration : float = 2.0

var tween : Tween
var curr_index : int


func tween_lfo() -> void:
	curr_index = wrapi(curr_index + 1, 0, 2)
	tween = get_tree().create_tween()
	tween.tween_property(lfo, "rate", tween_range[curr_index], tween_duration)
	tween.finished.connect(tween_lfo)


func kill_tween() -> void:
	tween.kill()
