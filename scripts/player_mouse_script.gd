extends Area2D

signal cheese_eaten
signal light_cheese_eaten
signal mouse_goes_to_sleep

@export var speed = 100.0
@export var minor_speed_up = 5.0
@export var major_speed_up = 9.0

# Size of the game window.
var screen_size
var active = false

var mouse_eat_duration = 5.0
var facing_right = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# The big cheese was eaten! Now the mouse will eat its big prize, then get a
# well deserved nap. The signal that the mouse went to sleep is also emitted
# from this function.
func _on_cheese_cursor_cheese_eaten():
	active = false
	await play_mouse_eating_anim()
	if (facing_right):
		$PlayerMouseAnims.flip_h = false
		$PlayerMouseAnims.play("mouse_sleep_right")
	else:
		$PlayerMouseAnims.play("mouse_sleep_left")
	mouse_goes_to_sleep.emit()


# Initializes the mouse at the given position.
func start(pos):
	position = pos
	show()
	$PlayerMouseAnims.play("mouse_still")
	$PlayerMouseCollision.disabled = false
	active = true
	speed = 100.0


# Moves the mouse towards the given position. The mouse's facing direction
# is tracked here for use in other functions.
func move_to(delta, pos):
	if (active):
		var velocity = pos - position;
		facing_right = velocity.x > 0
		if (velocity.length() > 0):
			velocity = velocity.normalized() * speed
			$PlayerMouseAnims.play("mouse_move")
		else:
			$PlayerMouseAnims.play("mouse_still")
		if (velocity.x != 0):
			$PlayerMouseAnims.flip_h = facing_right
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)


func get_speed():
	return speed


func set_speed(new_speed : int):
	speed = new_speed


func get_minor_speed_up():
	return minor_speed_up


func get_major_speed_up():
	return major_speed_up


# Plays the mouse's eating animation, and also sets a timer for how long the
# animation should play. The eating duration should match however long it takes
# for the big cheese eaten aniamtion to finish.
func play_mouse_eating_anim():
	$PlayerMouseAnims.play("mouse_eat")
	await get_tree().create_timer(mouse_eat_duration).timeout
