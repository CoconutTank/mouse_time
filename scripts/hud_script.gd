class_name HudScene
extends CanvasLayer

signal start_game
signal toggle_sound

@export var game_title : String
@export var show_exit_button = true

var showing_how_to_play = false

var how_to_play_button_text = "How To Play"
var how_to_play_button_close_text = "Return"

var sound_on : bool

var game_ui_components = []

var knock_out_limit = 50
var high_vibe_limit = 200
var even_higher_vibe_limit = 300
var xtreme_vibe_limit = 400
var nuclear_knockout_detected = false


const score_elements_display_delay = 0.5
const score_roller_display_delay = 0.025
const score_roller_deltas = [
	100000000,
	10000000,
	1000000,
	100000,
	10000,
	1000,
	100,
	10,
	1
]


const guide_book_scene_path = "res://scenes/game_guide/guide_book.tscn"
const goon_gallery_scene_path = "res://scenes/goon_gallery/goon_gallery.tscn"


# Called when the node enters the scene tree for the first time.
func _ready():
	reset_score()
	game_ui_components = [
		$MessageLabel,
		$TimeCounter,
		$CheeseEatenCounter,
		$MouseVibesDisplay,
		$MultiCheeseAnims,
		$TimerAnims,
		$MouseVibesAnims,
		$UIBar
	]
	$HowToPlayText.hide()
	start_animated_ui(false)
	if (!show_exit_button):
		$ExitGameButton.hide()
	sound_on = false
	nuclear_knockout_detected = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	$StartButton.hide()
	$HowToPlayButton.hide()
	$WhatAreGoonsButton.hide()
	$ExitGameButton.hide()
	if sound_on:
		$SoundOnButton.hide()
	else:
		$SoundOffButton.hide()
	$MouseVibesAnims.play("mouse_still")
	display_game_ui(true)
	start_game.emit()


func _on_how_to_play_button_pressed():
	add_child(load(guide_book_scene_path).instantiate())


func _on_button_pressed():
	add_child(load(goon_gallery_scene_path).instantiate())


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
	$WhatAreGoonsButton.show()
	if sound_on:
		$SoundOnButton.show()
	else:
		$SoundOffButton.show()
	if (show_exit_button):
		$ExitGameButton.show()


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
			"timer_squash_up_down" if (randi() % 2 == 0)
			else "timer_squash_left_right")
		$MouseVibesAnims.play("mouse_wiggle")
	else:
		$MultiCheeseAnims.play("multi_cheese_intact")
		$TimerAnims.play("timer_intact")
		if nuclear_knockout_detected:
			$MouseVibesAnims.play("mouse_knockout")
		else:
			$MouseVibesAnims.play("mouse_sleep")


func update_time_counter(time : int):
	$TimeCounter.text = str(time)


func update_cheese_counter(cheese : int):
	$CheeseEatenCounter.text = str(cheese)


func update_vibe_display(vibes : int):
	if vibes <= knock_out_limit:
		$MouseVibesAnims.play("mouse_knockout")
		$MouseVibesDisplay.text = "KO!"
		nuclear_knockout_detected = true
		return
	if vibes >= xtreme_vibe_limit:
		$MouseVibesAnims.play("mouse_spin")
	elif vibes >= even_higher_vibe_limit:
		$MouseVibesAnims.play("mouse_wiggle_really_fast")
	elif vibes >= high_vibe_limit:
		$MouseVibesAnims.play("mouse_wiggle_faster")
	else:
		$MouseVibesAnims.play("mouse_wiggle")
	$MouseVibesDisplay.text = str(vibes)


func _on_exit_game_button_pressed():
	get_tree().quit()


func reset_score():
	$VibeScoreAnims.hide()
	$MultiplySymbol001.hide()
	$TimeScoreAnims.hide()
	$MultiplySymbol002.hide()
	$CheeseScoreAnims.hide()
	$ScoreDisplay.text = ""
	$ScoreDisplay.hide()
	$ScoreDisplayBar.hide()


func show_score_lively(vibe_score : int, time_score : int, cheese_score : int):
	var score = 0
	var vibe_times_time = vibe_score * time_score
	var total_score = vibe_score * time_score * cheese_score
	$ScoreDisplayBar.show()
	$VibeScoreAnims.show()
	$VibeScoreAnims.play("score")
	await get_tree().create_timer(score_elements_display_delay).timeout
	$ScoreDisplay.text = "= " + str(score)
	$ScoreDisplay.show()
	# Roll the score!
	while score != vibe_score:
		score = score_roller_helper_func(score, vibe_score)
		$ScoreDisplay.text = "= " + str(score)
		await get_tree().create_timer(score_roller_display_delay).timeout
	await get_tree().create_timer(score_elements_display_delay).timeout
	$MultiplySymbol001.show()
	$MultiplySymbol001.play("score")
	await get_tree().create_timer(score_elements_display_delay).timeout
	$TimeScoreAnims.show()
	$TimeScoreAnims.play("score")
	# Roll the score!
	while score != vibe_times_time:
		score = score_roller_helper_func(score, vibe_times_time)
		$ScoreDisplay.text = "= " + str(score)
		await get_tree().create_timer(score_roller_display_delay).timeout
	await get_tree().create_timer(score_elements_display_delay).timeout
	$MultiplySymbol002.show()
	$MultiplySymbol002.play("score")
	await get_tree().create_timer(score_elements_display_delay).timeout
	$CheeseScoreAnims.show()
	$CheeseScoreAnims.play("score")
	# Roll the score!
	while score != total_score:
		score = score_roller_helper_func(score, total_score)
		$ScoreDisplay.text = "= " + str(score)
		await get_tree().create_timer(score_roller_display_delay).timeout
	await get_tree().create_timer(score_elements_display_delay).timeout
	$ScoreDisplay.text = "= " + str(score) + "!"


# Helper function for rolling a score to a score_target value, digit by digit.
func score_roller_helper_func(score : int, score_target : int):
	var diff = score_target - score
	if diff > 0:
		for score_delta in score_roller_deltas:
			if diff >= score_delta:
				return score + score_delta
	elif diff < 0:
		for score_delta in score_roller_deltas:
			if diff <= -score_delta:
				return score - score_delta
	else:
		return score


func _on_sound_on_button_pressed():
	toggle_sound.emit()
	$SoundOnButton.hide()
	$SoundOffButton.show()
	sound_on = false


func _on_sound_off_button_pressed():
	toggle_sound.emit()
	$SoundOffButton.hide()
	$SoundOnButton.show()
	$SoundToggledOnSound.play()
	sound_on = true
