class_name PlayerMouse
extends Area2D

signal cheese_eaten
signal light_cheese_eaten
signal mouse_is_knocked_out
signal mouse_goes_to_sleep
signal goon_touched(goon, me)

@export var vibes = 100.0
@export var minor_speed_up = 3.0
@export var major_speed_up = 5.0

# Size of the game window.
var screen_size

var active = false

var mouse_eat_anim_duration = 2.4
var facing_right = false

var invulnerable = false
var base_invul_duration : float = 3.0

const init_invul_flash_delay : float = 0.17
const min_invul_flash_delay : float = 0.05
const delta_invul_flash_delay : float = 0.01
const invul_flash_alpha_001 : float = 0.0
const invul_flash_alpha_002 : float = 0.5

const knock_out_limit = 50

const speed_multiplier = 1.5

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
	vibes = 100.0


# Moves the mouse towards the given position. The mouse's facing direction
# is tracked here for use in other functions.
func move_to(delta, pos):
	if (active):
		var velocity = pos - position;
		facing_right = velocity.x > 0
		if (velocity.length() > 0):
			velocity = velocity.normalized() * vibes * speed_multiplier
			$PlayerMouseAnims.play("mouse_move")
		else:
			$PlayerMouseAnims.play("mouse_still")
		if (velocity.x != 0):
			$PlayerMouseAnims.flip_h = facing_right
		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)


# Plays the mouse's eating animation, and also sets a timer for how long the
# animation should play. The eating duration should match however long it takes
# for the big cheese eaten aniamtion to finish.
func play_mouse_eating_anim():
	$PlayerMouseAnims.play("mouse_eat")
	await get_tree().create_timer(mouse_eat_anim_duration).timeout


func _on_body_entered(body):
	if active && body.has_method("is_an_active_goon") && body.is_an_active_goon():
		goon_touched.emit(body, self)


func activate_invul(invul_duration := base_invul_duration):
	if !invulnerable:
		invulnerable = true
		invul_alpha_flash()
		await get_tree().create_timer(invul_duration).timeout
		invulnerable = false
		modulate.a = 1.0


func invul_alpha_flash():
	var alpha_flip = true
	var invul_flash_delay = init_invul_flash_delay
	while invulnerable:
		if alpha_flip:
			modulate.a = invul_flash_alpha_001
		else:
			modulate.a = invul_flash_alpha_002
		await get_tree().create_timer(invul_flash_delay).timeout
		alpha_flip = !alpha_flip
		invul_flash_delay = max(invul_flash_delay - delta_invul_flash_delay, min_invul_flash_delay)


func keep_going():
	if vibes > knock_out_limit:
		return true
	active = false
	knocked_out()
	return false


func knocked_out():
	active = false
	if (facing_right):
		$PlayerMouseAnims.flip_h = false
		$PlayerMouseAnims.play("mouse_knockout")
	else:
		$PlayerMouseAnims.play("mouse_knockout")
	mouse_is_knocked_out.emit()
	
