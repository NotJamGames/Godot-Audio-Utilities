# GODOT AUDIO UTILITIES

## LFO For Godot: lfo.gd

LFO For Godot is a simple class for Godot 4.X that allows the user to manipulate any float property of an AudioEffect smoothly over time.

Use it for subtle tremolo or dramatic filter sweeps or anything else you can think of!

All parameters can be freely adjusted whilst the LFO is running, allowing for fun effects - tweening the rate or amplitude of the LFO is highly recommended.

A full demo project is included, allowing the user to easily try LFOs affecting a variety of parameters. Find out how it works [here](#lfo-demo-project).

Please feel free to suggest improvements, changes or additional features. LFO For Godot is under CC0 Licence terms and can be freely used in any commercial or non-commercial projects and modified however the user sees fit.


________


### Setup

To begin, set up an AudioBus with the desired AudioEffect, and route any AudioStreamPlayers that should be affected to this bus.

Next, add an instance of the LFO class (lfo.gd) to your SceneTree, and ensure all parameters are configured correctly. 

As LFO For Godot uses the @tool annotation, it can be tested in Editor if required.


________


### Parameters

LFO For Godot requires the following variables to be set by the user:

- **Bus Name:** the name of the AudioBus to which the LFO will be sent, as String.
- **Bus Effect Index:** the index of the AudioEffect
- **Bus Effect Setter:** StringName for the setter method of the effect parameter to be changed.
For instance, to route the LFO to the cutoff parameter of an AudioEffectFilter, use "set_cutoff".

____

- **Waveform:** the waveform used by the LFO. Includes options for Sawtooth, Inverted Sawtooth, Square, Triangle and Sine
- **Rate:** the rate of the LFO, in Hz. Must be set to a float > .0
- **Bus Effect Baseline:** the initial value for the effect parameter.
- **Amplitude:**: the strength of the LFO's effect: the effect parameter will be modulated by up to this value, both above and below the baseline value.

For instance, if the LFO is assigned to the cutoff parameter of an AudioEffectFilter, setting a bus_effect_baseline of 5000.0 and LFO strength of 3000.0 would allow the LFO to modulate between values of 8000Hz and 2000Hz.

*Please note that the effect of bus effect baseline and amplitude depends greatly on the particular AudioEffect and parameter, and should be set accordingly.*

____


- **Phase:** The position within the waveform from which the LFO should start.
*Please note this will only affect the LFO node when the _ready() function is initially called, or if retrig_on_start is set to true
- **Retrig On Start:** if true, the LFO will restart from the beginning of the waveform when cycling is toggled. If false, it will instead recommence from the last known position in the waveform.
- **Fade Enabled:** if true, the LFO's effect will be faded in/out on retrig based upon the user's parameters
- **Fade Duration:** the duration of the fade
- **Fade Direction:** # the direction of fade, either fading in from 0 to full strength or out from full strength to 0

____


- **Cycling:** if true, the LFO will cycle. This can be toggled within the editor to hear the effect of the LFO, provided an AudioStreamPlayer routed to the targeted AudioBus is playing.
- **Autostart:** if true, the LFO will automatically start when the LFO's ready() function is called. Has no effect in Editor.

*Please note that the LFO will throw an error message if the user attempts to start a cycle whilst Bus Name, Bus Effect Index or Bus Effect Setter are configured incorrectly. Check for typos!*
________


### Limitations 

LFO For Godot is unfortunately not configured to work well at audio rates.


## LFO Demo Project

To get started, download all files and open the project within the Godot Editor (4.X only).

Navigate to the SceneTree at the top left corner, and select any DemoPlayer node. 

![image](https://github.com/NotJamGames/Godot-Audio-Utilities/assets/77352023/71cd57a5-28ac-40de-aa20-6e6a82039665)

Next, via the inspector panel, simply click "Play Demo" to hear the LFO in action!

![image](https://github.com/NotJamGames/Godot-Audio-Utilities/assets/77352023/b2971690-a3d0-4bcc-bb70-c9aa8705f835)

Some of the LFOs (denoted by the term "Accelerating") demonstrate the use of tweens to affect LFO parameters - feel free to browse through the code to see one way to implement this
