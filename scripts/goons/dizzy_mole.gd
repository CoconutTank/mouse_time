class_name DizzyMole
extends RigidBody2D


const goon_type = GoonManager.GOON_TYPE.DIZZY_MOLE


const emerge_anim_time = 2.185
const emerge_soon_anim_time = 0.9
const despawn_anim_time = 1.0
const max_timed_life = 10
const max_change_direction_time = 3
const min_change_direction_time = 1


var active = false
var game_is_active = true
var speed = 30.0
var timed_life = 0
var direction = 0.0
var change_direction_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spawn():
	$DizzyMoleAnims.play("emerge")
	await get_tree().create_timer(emerge_anim_time).timeout
	$DizzyMoleAnims.play("emerge_soon")
	await get_tree().create_timer(emerge_soon_anim_time).timeout
	$DizzyMoleAnims.play("walk")
	if game_is_active:
		direction = randf_range(0.0, 2*PI)
		linear_velocity = Vector2(speed, 0.0).rotated(direction)
		$DizzyMoleAnims.flip_h = linear_velocity.x < 0
		timed_life = max_timed_life
		change_direction_time = randi_range(min_change_direction_time, max_change_direction_time)
		active = true


func despawn():
	active = false
	linear_velocity = Vector2.ZERO
	$DizzyMoleAnims.play("despawn")
	await get_tree().create_timer(despawn_anim_time).timeout
	queue_free()


func set_spawn_position(spawn_area_min : Vector2, spawn_area_max : Vector2):
	position = Vector2(
		randi_range(spawn_area_min.x, spawn_area_max.x),
		randi_range(spawn_area_min.y, spawn_area_max.y))


func on_goon_tick():
	if active:
		timed_life -= 1
		if timed_life <= 0:
			despawn()
			return
		change_direction_time -= 1
		if change_direction_time <= 0:
			change_direction()


# The life of a dizzy mole is brief. It beats itself up more than it beats up
# its opponents.
func on_fight(opponent):
	if opponent is PlayerMouse:
		opponent.vibes = opponent.vibes / 2
		queue_free()


# Dizzy moles tend to wander about with no consistency.
func change_direction():
	direction = randf_range(0.0, 2*PI)
	linear_velocity = Vector2(speed, 0.0).rotated(direction)
	$DizzyMoleAnims.flip_h = linear_velocity.x < 0
	change_direction_time = randi_range(min_change_direction_time, max_change_direction_time)


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func is_an_active_goon():
	return active
