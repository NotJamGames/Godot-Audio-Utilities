@tool
class_name LFO
extends Node


@export_category("LFO Routing")
## The name of the AudioBus to which the LFO will be sent, as String.
@export var bus_name : String
## The index of the AudioEffect
@export var bus_effect_index : int
## StringName for the setter method of the effect parameter to be changed.
## [br][br]
## For instance, to route the LFO to the cutoff parameter of an 
## AudioEffectFilter, use "set_cutoff". 
@export var bus_effect_setter : String

var bus_index : int


@export_category("LFO Parameters")
enum Waveforms {SAW, SQUARE, TRIANGLE, SINE}
## The waveform used by the LFO
@export var waveform : Waveforms = Waveforms.SAW : set = set_waveform
var wave_funcs : Array[Callable] = \
		[calculate_saw, calculate_square, calculate_triangle, calculate_sine] 
var curr_wave_func : Callable


## The rate of the LFO, in HZ. [br][br]
## Must be greater than 0.
@export var rate : float = 1.0 : set = set_rate
@onready var cycle_duration : float = 1.0 / rate
var time : float = .0


## The initial value for the effect parameter, to which the amplitude generated
## by the LFO will be added.
## [br][br]
## For instance, if assigned to an AudioEffectFilter, setting a 
## bus_effect_baseline of 2000.0 and LFO strength of 3000.0 would allow the 
## LFO to modulate between values of 2000Hz and 5000Hz.
## [br][br]
## Please note that the effect of amplitude depends greatly on the particular
## AudioEffect and parameter, and should be set accordingly. 
@export var bus_effect_baseline : float
## Sets the strength of the LFO. [br][br]
## Please note that the effect of amplitude depends greatly on the particular
## AudioEffect and parameter, and should be set accordingly. [br][br]
## Accepts negative values. 
@export var amplitude : float


@export_category("Init Parameters")
## If true, the LFO is cycling.
@export var cycling : bool = false : set = set_cycling
## If true, the LFO will automatically start when added to the scene tree.
## [br][br]
## Please note this has no effect when running in editor.
@export var autostart : bool = false
## If true, the LFO will be reset to it's baseline position whenever
## cycling is set to true, either via start() or via set_cycling()
@export var retrig_on_start : bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		set_cycling(false); return
	if autostart: start()


func _process(delta : float) -> void:
	if !cycling: return
	time += delta
	if time > cycle_duration:
		time = fmod(time, cycle_duration)

	var new_lfo_amplitude : float = curr_wave_func.call() * amplitude
	AudioServer.get_bus_effect(bus_index, bus_effect_index).call\
			(bus_effect_setter, bus_effect_baseline + new_lfo_amplitude)


func set_cycling(new_state : bool) -> void:
	if new_state == false:
		cycling = new_state

	if !verify_paths(): return

	if retrig_on_start: time = .0
	cycling = new_state


func start() -> void:
	if !verify_paths(): return

	if retrig_on_start: time = .0
	cycling = true


func stop() -> void:
	cycling = false


func verify_paths() -> bool:
	bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_error("Error: bus %s not found in AudioServer" % bus_name)
		return false

	if bus_effect_index >= AudioServer.get_bus_effect_count(bus_index):
		push_error\
				("Error: provided index %s exceeds effect count on bus %s" \
				% [bus_effect_index, bus_name])
		return false

	

	return true


func set_waveform(new_waveform : Waveforms) -> void:
	waveform = new_waveform
	curr_wave_func = wave_funcs[new_waveform]


func set_rate(new_rate : float) -> void:
	if new_rate <= 0:
		push_error("Rate must be greater than zero") 
		return

	rate = new_rate
	cycle_duration = 1.0 / rate


func calculate_saw() -> float:
	return time / cycle_duration


func calculate_square() -> float:
	return float(time < .5 * cycle_duration)


func calculate_triangle() -> float:
	return abs(time - (time / (cycle_duration * .5)))


func calculate_sine() -> float:
	return 0.5 * (1 + sin(2 * PI * rate * time))
