class_name FightyLobster
extends RigidBody2D


const goon_type = GoonManager.GOON_TYPE.FIGHTY_LOBSTER


const max_offscreen_time = 2
var speed = 75.0
var offscreen_time = 0
var direction = 0.0


var active = false
var game_is_active = true
var on_screen = true


var move_horizontal = false
var move_right = false
var move_down = false
var my_spawn_area_min
var my_spawn_area_max


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spawn():
	$FightyLobsterAnims.play("walk")
	if game_is_active:
		linear_velocity = Vector2(speed, 0.0).rotated(direction)
		$FightyLobsterAnims.flip_h = linear_velocity.x < 0
		offscreen_time = max_offscreen_time
		active = true


func on_goon_tick():
	if active:
		if on_screen:
			if move_horizontal:
				if move_right:
					on_screen = position.x < my_spawn_area_max.x
				else:
					on_screen = position.x > my_spawn_area_min.x
			else:
				if move_down:
					on_screen = position.y < my_spawn_area_max.y
				else:
					on_screen = position.y > my_spawn_area_min.y
		if !on_screen:
			offscreen_time -= 1
			if offscreen_time <= 0:
				despawn()
				return


# Fighting a lobster is no joke. Especially a lobster that's fighty.
func on_fight(opponent):
	if opponent is PlayerMouse:
		opponent.vibes = opponent.vibes / 4
		queue_free()


func despawn():
	active = false
	linear_velocity = Vector2.ZERO
	queue_free()


func set_spawn_position(spawn_area_min : Vector2, spawn_area_max : Vector2):
	var x_1 = 0
	var y_1 = 0
	var x_2 = 0
	var y_2 = 0
	my_spawn_area_min = spawn_area_min
	my_spawn_area_max = spawn_area_max
	move_horizontal = randi() % 2 == 0
	if move_horizontal:
		y_1 = randi_range(spawn_area_min.y, spawn_area_max.y)
		y_2 = spawn_area_max.y - y_1
		move_right = randi() % 2 == 0
		if move_right:
			x_1 = -100
			x_2 = spawn_area_max.x + 100
		else:
			x_1 = spawn_area_max.x + 100
			x_2 = -100
	else:
		x_1 = randi_range(spawn_area_min.x, spawn_area_max.x)
		x_2 = spawn_area_max.x - x_1
		move_down = randi() % 2 == 0
		if move_down:
			y_1 = -100
			y_2 = spawn_area_max.y + 100
		else:
			y_1 = spawn_area_max.y + 100
			y_2 = -100
	position = Vector2(x_1, y_1)
	direction = (Vector2(x_2, y_2) - position).angle()


func is_an_active_goon():
	return active

