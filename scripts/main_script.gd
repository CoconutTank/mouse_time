class_name MainScene
extends Node

var light_cheese_blueprint = preload("res://nodes/light_cheese.tscn")

const get_ready_messages = ["3...", "2..", "1."]
const go_message = "Go!"
const get_ready_display_duration = 1

const finish_message = "Fin!"
const finish_display_duration = 2

const try_again_message = "Try Again?"

var active = false

var game_timer = 0
var cheese_counter = 0

# Playable area of the game (clamps where the big cheese can be).
var play_area_min : Vector2
var play_area_max : Vector2
var play_area_center : Vector2

# Available spawning area
var spawn_area_min : Vector2
var spawn_area_max : Vector2

# Sounds emitted upon collecting a cheese
var cheese_collect_sounds = []

var sound_on : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	play_area_min = Vector2($PlayArea.position.x, $PlayArea.position.y)
	play_area_max = Vector2(
		$PlayArea.position.x + $PlayArea.size.x, 
		$PlayArea.position.y + $PlayArea.size.y)
	play_area_center = Vector2(
		(play_area_min.x + play_area_max.x) / 2,
		(play_area_min.y + play_area_max.y) / 2)
	spawn_area_min = Vector2($SpawnArea.position.x, $SpawnArea.position.y)
	spawn_area_max = Vector2(
		$SpawnArea.position.x + $SpawnArea.size.x, 
		$SpawnArea.position.y + $SpawnArea.size.y)
	$CheeseCursor.set_play_area(play_area_min, play_area_max)
	cheese_collect_sounds = [
		$CheeseCollectSound001,
		$CheeseCollectSound002,
		$CheeseCollectSound003
	]
	# This is terrible. But if I'm not using a auto-loaded signal hub, this is
	# how it'll have to be done.
	$PlayerMouse.connect("goon_touched", Callable($GoonManager, "goon_fight"))
	# aaaaaAAAAAAAAAA
	$GoonManager.spawn_area_min = spawn_area_min
	$GoonManager.spawn_area_max = spawn_area_max
	sound_on = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		$PlayerMouse.move_to(delta, $CheeseCursor.position)


# Starts a new game, by first clearing out any on-screen light cheese, then
# reseting everything back to 0 or their starting positions. Also plays the
# get ready messages.
func new_game():
	get_tree().call_group("light_cheese_group", "queue_free")
	$GoonManager.reset()
	game_timer = 0
	cheese_counter = 0
	$HUD.reset_score()
	initiate_player_mouse()
	initiate_game_ui()
	await get_ready_event()
	if (sound_on): $GoSound.play()
	$HUD.show_message(go_message, get_ready_display_duration)
	$HUD.start_animated_ui(true)
	$PerSecondTimer.start()
	$LightCheeseSpawnTimer.start()
	$LightCheeseSpawnTimer2.start()
	initiate_cheese_cursor()
	active = true
	$GoonManager.get_node("GoonTimer").start()


# This function stops all time functions, and displays a message to let the
# player know that the game has ended. After a small delay, the player can
# interact with the game again, using the buttons that show up at the start of
# the game.
func game_over():
	active = false
	$PerSecondTimer.stop()
	$LightCheeseSpawnTimer.stop()
	$LightCheeseSpawnTimer2.stop()
	$GoonManager.get_node("GoonTimer").stop()
	$GoonManager.stop_all_goons()
	$HUD.start_animated_ui(false)
	await $HUD.show_message(finish_message, finish_display_duration)
	$HUD.hide_message()
	await $HUD.show_score_lively($PlayerMouse.vibes, game_timer, cheese_counter)
	$HUD.get_node("StartButton").text = try_again_message
	$HUD.show_buttons()


# Creates a light cheese at the given position. Also attaches a callback to the
# light cheese that waits on the "light_cheese_eaten" signal and calls a
# function in this script. This connection must be done at run-time, since
# the light cheese object only exists during run-time (and not in the editor).
func create_light_cheese_at(pos):
	var light_cheese = light_cheese_blueprint.instantiate()
	add_child(light_cheese)
	light_cheese.connect(
		"light_cheese_eaten", Callable(self, "_on_light_cheese_light_cheese_eaten"))
	light_cheese.start(pos)


# A cheese is eaten, and the score is updated.
func cheese_eaten():
	cheese_counter += 1
	$HUD.update_cheese_counter(cheese_counter)


# Increases the mouse's vibes, and also updates the vibes counter display.
func speed_up(speed_increase : int):
	if $PlayerMouse.active: $PlayerMouse.vibes = $PlayerMouse.vibes + speed_increase


# Displays the get ready countdown at the start of the game.
func get_ready_event():
	for msg in get_ready_messages:
		if (sound_on): $CountdownSound.play()
		await $HUD.show_message(msg, get_ready_display_duration)


# Initiates the big cheese's position to be wherever your computer mouse is.
func initiate_cheese_cursor():
	$CheeseCursor.start(get_viewport().get_mouse_position())


# The mouse always starts in the center of the play area.
func initiate_player_mouse():
	$PlayerMouse.start(play_area_center)


# Initiates the game UI with the in-game parameters.
func initiate_game_ui():
	$HUD.update_time_counter(game_timer)
	$HUD.update_cheese_counter(cheese_counter)
	$HUD.update_vibe_display($PlayerMouse.vibes)


func _on_hud_toggle_sound():
	if (sound_on):
		sound_on = false
	else:
		sound_on = true


# Called each time the per second timer times out, which is, well, every
# second. Each time this function is called, the in-game timer is updated, and
# the mouse gets a small vibes boost.
func _on_per_second_timer_timeout():
	if (active):
		game_timer += 1
		$HUD.update_time_counter(game_timer)
		speed_up($PlayerMouse.minor_speed_up)
		$HUD.update_vibe_display($PlayerMouse.vibes)


# Called each time the light cheese spawn timers time out, which are currently
# every 3 seconds and every 5 seconds. The light cheese will spawn within a
# centered area of the play area, and should not be spawning near the edges.
func _on_light_cheese_spawn_timer_timeout():
	if (active):
		create_light_cheese_at(
			Vector2(
				randi_range(spawn_area_min.x, spawn_area_max.x),
				randi_range(spawn_area_min.y, spawn_area_max.y)))


# This function is triggered upon the mouse going to sleep. It calls the
# game_over function.
func _on_player_mouse_mouse_goes_to_sleep():
	if (sound_on): $SleepySound.play()
	game_over()


func _on_player_mouse_mouse_is_knocked_out():
	game_over()
	# These status flips in the lines underneath are strewn about.
	# They should always be called for any kind of game over event.
	$CheeseCursor.active = false
	$CheeseCursor.hide()


# This function is called once the big cheese is eaten. It basically stops
# nearly all active functions. The big cheese still counts as a point!
func _on_cheese_cursor_cheese_eaten():
	if (sound_on): $TadaSound.play()
	cheese_eaten()
	active = false


# This function is called each time a light cheese is eaten. The game doesn't
# stop, but the player's score goes up (and the mouse gets a big vibes boost).
func _on_light_cheese_light_cheese_eaten():
	if (sound_on):
		cheese_collect_sounds[randi() % cheese_collect_sounds.size()].play()
	cheese_eaten()
	speed_up($PlayerMouse.major_speed_up)
