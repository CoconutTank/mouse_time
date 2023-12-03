extends CanvasLayer

signal start_game
signal toggle_sound

@export var game_title : String
@export var stow_exit_button = false

var showing_how_to_play = false

var how_to_play_button_text = "How To Play"
var how_to_play_button_close_text = "Return"

var sound_on : bool
var sound_on_button_text = "Sound On ♫"
var sound_off_button_text = "Sound Off"

var game_ui_components = []

# Called when the node enters the scene tree for the first time.
func _ready():
	game_ui_components = [
		$MessageLabel,
		$TimeCounter,
		$CheeseEatenCounter,
		$MouseSpeedDisplay,
		$MultiCheeseAnims,
		$TimerAnims,
		$MouseWiggleAnims,
		$UIBar
	]
	$HowToPlayText.hide()
	start_animated_ui(false)
	if (stow_exit_button):
		$ExitGameButton.hide()
	sound_on = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	$StartButton.hide()
	$HowToPlayButton.hide()
	$ExitGameButton.hide()
	$ToggleSoundButton.hide()
	$MouseWiggleAnims.play("mouse_still")
	display_game_ui(true)
	start_game.emit()


func _on_how_to_play_button_pressed():
	if (showing_how_to_play):
		close_how_to_play()
	else:
		show_how_to_play()


# Used to update the message label used for the game.
# A duration (in whole seconds) can also be specified for the message.
# If 0 (default) or a value less than 0 is specified for duration, the 
# message will remain indefinitely.
# If a value greater than 0 is specified, then this function will await for
# that duration, then hide the message.
# Do remember that, if you want the game to respect this function's duration,
# then you must "await" any calls to this function as needed.
func show_message(text : String, duration := 0):
	$MessageLabel.text = text
	$MessageLabel.show()
	if (duration > 0):
		await get_tree().create_timer(duration).timeout
		$MessageLabel.hide()


# Used to hide the message label when necessary.
func hide_message():
	$MessageLabel.hide()


func show_buttons():
	$StartButton.show()
	$HowToPlayButton.show()
	$ToggleSoundButton.show()
	if (!stow_exit_button):
		$ExitGameButton.show()


func show_how_to_play():
	$StartButton.hide()
	$ExitGameButton.hide()
	$ToggleSoundButton.hide()
	display_game_ui(false)
	$HowToPlayText.show()
	$HowToPlayButton.text = how_to_play_button_close_text
	showing_how_to_play = true


func close_how_to_play():
	$HowToPlayText.hide()
	$StartButton.show()
	$ToggleSoundButton.show()
	if (!stow_exit_button):
		$ExitGameButton.show()
	display_game_ui(true)
	$HowToPlayButton.text = how_to_play_button_text
	showing_how_to_play = false


# Use this function to toggle whether or not the normal game UI is visible.
func display_game_ui(showUi : bool):
	if (showUi):
		for component in game_ui_components:
			component.show()
	else:
		for component in game_ui_components:
			component.hide()


func start_animated_ui(animateUi : bool):
	if (animateUi):
		$MultiCheeseAnims.play("multi_cheese_flash")
		$TimerAnims.play(
			"timer_squash_up_down" if (randi() % 100 >= 50)
			else "timer_squash_left_right")
		$MouseWiggleAnims.play("mouse_wiggle")
	else:
		$MultiCheeseAnims.play("multi_cheese_intact")
		$TimerAnims.play("timer_intact")
		$MouseWiggleAnims.play("mouse_sleep")

func update_time_counter(time : int):
	$TimeCounter.text = str(time)


func update_cheese_counter(cheese : int):
	$CheeseEatenCounter.text = str(cheese)


func update_mouse_speed_display(speed : int):
	$MouseSpeedDisplay.text = str(speed) + "%"


func _on_exit_game_button_pressed():
	get_tree().quit()


func _on_toggle_sound_button_pressed():
	toggle_sound.emit()
	if (sound_on):
		sound_on = false
		$ToggleSoundButton.text = sound_off_button_text
	else:
		sound_on = true
		$ToggleSoundButton.text = sound_on_button_text
		$SoundToggledOnSound.play()
