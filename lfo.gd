@tool
class_name LFO
extends Node

enum Waveforms {SAW, SQUARE, TRIANGLE, SINE}
@export var waveform : Waveforms = Waveforms.SAW : set = set_waveform
var wave_funcs : Array[Callable] = [calculate_saw, calculate_square, calculate_triangle, calculate_sine] 
var curr_wave_func : Callable


func set_waveform(new_waveform : Waveforms) -> void:
	waveform = new_waveform
	curr_wave_func = wave_funcs[new_waveform]


func calculate_saw() -> float:
	return .0


func calculate_square() -> float:
	return .0


func calculate_triangle() -> float:
	return .0


func calculate_sine() -> float:
	return .0