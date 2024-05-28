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
enum Waveforms {SAW, INVERTED_SAW, SQUARE, TRIANGLE, SINE}
## The waveform used by the LFO
@export var waveform : Waveforms = Waveforms.SAW : set = set_waveform
var wave_funcs : Array[Callable] = \
		[calculate_saw, calculate_inverted_saw, calculate_square, 
		calculate_triangle, calculate_sine] 
@onready var curr_wave_func : Callable = wave_funcs[waveform]


## The rate of the LFO, in HZ.
## [br][br]
## Must be greater than 0.
@export var rate : float = 1.0 : set = set_rate
@onready var cycle_duration : float = 1.0 / rate
var time : float = .0


## The initial value for the effect parameter.
## [br][br]
## Please note that the effect of amplitude depends greatly on the particular
## AudioEffect and parameter, and should be set accordingly.
## [br][br]
## Please note that baseline accepts both positive and negative values to
## ensure compatibility across a range of AudioEffect parameters. Be careful
## to set this to a value compatible with the specified parameter
@export var bus_effect_baseline : float
## Sets the strength of the LFO: the effect parameter will be modulated by
## up to this value, both above and below the baseline value.
## [br][br]
## For instance, if assigned to an AudioEffectFilter, setting a 
## bus_effect_baseline of 5000.0 and LFO strength of 3000.0 would allow the 
## LFO to modulate between values of 8000Hz and 2000Hz.
## [br][br]
## Please note that the effect of amplitude depends greatly on the particular
## AudioEffect and parameter, and should be set accordingly.
@export var amplitude : float : set = set_amplitude


@export_category("Trigger Parameters")
## The position within the waveform from which the LFO should start.
## Please note this will only affect the LFO node when the _ready() function
## is initially called, or if retrig_on_start is set to true
@export_range(.0, 1.0) var phase : float = .0
## If true, the LFO will be reset to it's baseline position whenever
## cycling is set to true, either via start() or via set_cycling()
@export var retrig_on_start : bool = false


var fade_time : float = .0
var fade_strength : float = 1.0
## If true, the LFO's effect will be faded in/out on retrig based upon the
## user's parameters
@export var fade_enabled : bool = false : set = set_fade_enabled
## The duration of the fade
@export var fade_duration : float
enum FADE_DIRECTIONS {FADE_IN, FADE_OUT}
# The direction of fade, either fading in from 0 to full strength or out 
# from full strength to 0
@export var fade_direction : FADE_DIRECTIONS = FADE_DIRECTIONS.FADE_IN


@export_category("Init Parameters")
## If true, the LFO is cycling.
@export var cycling : bool = false : set = set_cycling
## If true, the LFO will automatically start when added to the scene tree.
## [br][br]
## Please note this has no effect when running in editor.
@export var autostart : bool = false



func _ready() -> void:
	if Engine.is_editor_hint():
		set_cycling(false)
		return

	time = cycle_duration * phase

	if autostart: start()


func _process(delta : float) -> void:
	if !cycling: return
	time += delta
	if time > cycle_duration:
		time = fmod(time, cycle_duration)

	if fade_enabled: update_fade(delta)

	var new_lfo_amplitude : float = \
			(curr_wave_func.call() - .5) * amplitude * 2.0 * fade_strength
	AudioServer.get_bus_effect(bus_index, bus_effect_index).call\
			(bus_effect_setter, bus_effect_baseline + new_lfo_amplitude)


func set_cycling(new_state : bool) -> void:
	if new_state == false:
		fade_time = .0
		cycling = new_state
		return

	if !verify_paths(): return

	if retrig_on_start: time = cycle_duration * phase
	cycling = new_state


func update_fade(delta : float) -> void:
	fade_time = min(fade_time + delta, fade_duration)
	fade_strength = fade_time / fade_duration
	if fade_direction == FADE_DIRECTIONS.FADE_OUT:
		fade_strength = 1.0 - fade_strength


func start() -> void:
	if !verify_paths(): return

	if retrig_on_start: time = .0
	set_cycling(true)


func stop() -> void:
	set_cycling(false)


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

	if !AudioServer.get_bus_effect(bus_index, bus_effect_index).has_method\
			(bus_effect_setter):
		push_error("Error: setter method %s not present in bus %s effect %s" \
		% [bus_effect_setter, bus_index, bus_effect_index])
		return false

	set_waveform(waveform)

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


func set_amplitude(new_amplitude : float) -> void:
	if new_amplitude < 0:
		push_error("Amplitude must be greater than or equal to zero") 
		return

	amplitude = new_amplitude


func set_fade_enabled(new_state : bool) -> void:
	fade_enabled = new_state
	if !fade_enabled: fade_strength = 1.0


func calculate_saw() -> float:
	return time / cycle_duration


func calculate_inverted_saw() -> float:
	return (cycle_duration - time) / cycle_duration


func calculate_square() -> float:
	return float(time < .5 * cycle_duration)


func calculate_triangle() -> float:
	return 2 * abs(fmod(time, cycle_duration) - cycle_duration / 2.0)


func calculate_sine() -> float:
	return 0.5 * (1 + sin(2 * PI * rate * time))
