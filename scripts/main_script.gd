extends Node

@export var light_cheese_blueprint : PackedScene

@export var light_cheese_spawn_buffer_x = 100
@export var light_cheese_spawn_buffer_y = 100

var get_ready_messages = ["3...", "2..", "1."]
var go_message = "Go!"
var get_ready_display_duration = 1

var finish_message = "Fin!"
var finish_display_duration = 5

var try_again_message = "Try Again?"

var active = false

var game_timer = 0
var cheese_counter = 0

# Size of the game window.
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().get_visible_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (active):
		$PlayerMouse.move_to(delta, $CheeseCursor.position)


func _on_per_second_timer_timeout():
	if (active):
		game_timer += 1
		$HUD.update_time_counter(game_timer)
		speed_up($PlayerMouse.get_minor_speed_up())

func _on_light_cheese_spawn_timer_timeout():
	if (active):
		create_light_cheese_at(
			Vector2(
				randi_range(light_cheese_spawn_buffer_x,
				screen_size.x - light_cheese_spawn_buffer_x),
				randi_range(light_cheese_spawn_buffer_y,
				screen_size.y - light_cheese_spawn_buffer_y)))


func _on_player_mouse_mouse_goes_to_sleep():
	$PerSecondTimer.stop()
	$LightCheeseSpawnTimer.stop()
	$LightCheeseSpawnTimer2.stop()
	await $HUD.show_message(finish_message, finish_display_duration)
	$HUD.show_message(try_again_message)
	$HUD.show_buttons()


func _on_cheese_cursor_cheese_eaten():
	cheese_eaten()
	active = false


func _on_light_cheese_light_cheese_eaten():
	cheese_eaten()
	speed_up($PlayerMouse.get_major_speed_up())


func new_game():
	get_tree().call_group("light_cheese_group", "queue_free")
	game_timer = 0
	cheese_counter = 0
	initiate_player_mouse()
	initiate_ui()
	await get_ready_event()
	$HUD.show_message(go_message, get_ready_display_duration)
	$PerSecondTimer.start()
	$LightCheeseSpawnTimer.start()
	$LightCheeseSpawnTimer2.start()
	initiate_cheese_cursor()
	active = true


func create_light_cheese_at(pos):
	var light_cheese = light_cheese_blueprint.instantiate()
	add_child(light_cheese)
	light_cheese.connect(
		"light_cheese_eaten", Callable(self, "_on_light_cheese_light_cheese_eaten"))
	light_cheese.start(pos)


func cheese_eaten():
	cheese_counter += 1
	$HUD.update_cheese_counter(cheese_counter)


func speed_up(speed_increase : int):
	$PlayerMouse.set_speed($PlayerMouse.get_speed() + speed_increase)
	$HUD.update_mouse_speed_display($PlayerMouse.get_speed())

func get_ready_event():
	for msg in get_ready_messages:
		await $HUD.show_message(msg, get_ready_display_duration)


func initiate_cheese_cursor():
	$CheeseCursor.start(get_viewport().get_mouse_position())


func initiate_player_mouse():
	$PlayerMouse.start(Vector2(screen_size.x / 2, screen_size.y / 2))


func initiate_ui():
	$HUD.update_time_counter(game_timer)
	$HUD.update_cheese_counter(cheese_counter)
	$HUD.update_mouse_speed_display($PlayerMouse.get_speed())
