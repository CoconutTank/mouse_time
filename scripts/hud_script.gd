extends CanvasLayer

signal start_game

@export var game_title : String

var showing_how_to_play = false

var how_to_play_button_text = "How To Play"
var how_to_play_button_close_text = "Close"

# Called when the node enters the scene tree for the first time.
func _ready():
	$HowToPlayText.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	$StartButton.hide()
	$HowToPlayButton.hide()
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


func show_how_to_play():
	$StartButton.hide()
	display_top_ui(false)
	$HowToPlayText.show()
	$HowToPlayButton.text = how_to_play_button_close_text
	showing_how_to_play = true


func close_how_to_play():
	$HowToPlayText.hide()
	$StartButton.show()
	display_top_ui(true)
	$HowToPlayButton.text = how_to_play_button_text
	showing_how_to_play = false


func display_top_ui(show : bool):
	if (show):
		$MessageLabel.show()
		$TimeLabel.show()
		$TimeCounter.show()
		$CheeseEatenLabel.show()
		$CheeseEatenCounter.show()
		$MouseSpeedLabel.show()
		$MouseSpeedDisplay.show()
	else:
		$MessageLabel.hide()
		$TimeLabel.hide()
		$TimeCounter.hide()
		$CheeseEatenLabel.hide()
		$CheeseEatenCounter.hide()
		$MouseSpeedLabel.hide()
		$MouseSpeedDisplay.hide()
		

func update_time_counter(time : int):
	$TimeCounter.text = str(time)


func update_cheese_counter(cheese : int):
	$CheeseEatenCounter.text = str(cheese)


func update_mouse_speed_display(speed : int):
	$MouseSpeedDisplay.text = str(speed)
