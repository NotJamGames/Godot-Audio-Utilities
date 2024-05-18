@tool
class_name LFO
extends Node

enum Waveforms {SAW, SQUARE, TRIANGLE, SINE}
@export var waveform : Waveforms = Waveforms.SAW : set = set_waveform
var wave_funcs : Array[Callable] = [calculate_saw, calculate_square, calculate_triangle, calculate_sine] 
var curr_wave_func : Callable


## The rate of the LFO, in HZ. [br][br]
## Must be greater than 0.
@export var rate : float = 60.0 : set = set_rate
@onready var cycle_duration : float = 1.0 / rate
var time : float = .0


## Sets the strength of the LFO. [br][br] 
## Accepts negative values. 
@export var amplitude : float


func _process(delta : float) -> void:
	time += delta
	if time > cycle_duration:
		time = fmod(time, cycle_duration) 


func set_waveform(new_waveform : Waveforms) -> void:
	waveform = new_waveform
	curr_wave_func = wave_funcs[new_waveform]


func set_rate(new_rate : float) -> void:
	if new_rate <=. 0:
		push_error("Rate must be greater than zero") 
		return

	rate = new_rate
	cycle_duration = 1.0 / rate


func calculate_saw() -> float:
	return .0


func calculate_square() -> float:
	return .0


func calculate_triangle() -> float:
	return .0


func calculate_sine() -> float:
	return .0