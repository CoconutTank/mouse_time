class_name Cheese
extends Area2D

signal cheese_eaten

var active = false

var play_area_min = Vector2.ZERO
var play_area_max = Vector2.INF

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# This function moves the big cheese around the play area, and makes sure that
# the big cheese stays within the play area at all times.
func _input(event):
	if active && event is InputEventMouseMotion:
		position = event.position
		position = position.clamp(play_area_min, play_area_max)


# This function is triggered upon an Area2D overlapping this area. In Mouse
# Time, the Area2D that matters here is the mouse.
func _on_area_entered(area):
	if (active):
		if area is PlayerMouse && area.active:
			eat_cheese()
		else:
			printerr("UNKNOWN AREA intersecting the big cheese!")


# Initializes the big cheese at the given position.
func start(pos):
	position = pos
	show()
	$CheeseAnims.play("cheese_intact")
	$CheeseCollision.disabled = false
	active = true


func set_play_area(new_play_area_min : Vector2, new_play_area_max : Vector2):
	play_area_min = new_play_area_min
	play_area_max = new_play_area_max


# Plays the animation for the big cheese being eaten. This function also emits
# the signal that the big cheese has been eaten, which triggers some other
# functions.
func eat_cheese():
	cheese_eaten.emit()
	active = false
	# Must be deferred as we can't change physics properties on a physics callback.
	$CheeseCollision.set_deferred("disabled", true)
	await play_cheese_being_eaten_anim()
	hide() # Cheese disappears after being eaten.


# Plays the animation for the big cheese being eaten.
func play_cheese_being_eaten_anim():
	$CheeseAnims.play("cheese_being_eaten")
	await get_tree().create_timer(2.4).timeout
	$CheeseAnims.stop()
