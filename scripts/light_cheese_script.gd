extends Area2D

signal light_cheese_eaten

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# This function is triggered upon an Area2D overlapping this area. In Mouse
# Time, the Area2D that matters here is the mouse.
func _on_area_entered(area):
	if (active):
		eat_light_cheese()


# Initializes the light cheese at the given position.
func start(pos):
	position = pos
	show()
	$LightCheeseAnims.play("light_cheese_intact")
	$LightCheeseCollision.disabled = false
	active = true


# Plays the animation for the light cheese being eaten. Once it's eaten, the
# light cheese removes itself.
# Eating a light cheese doesn't trigger the mouse's eating animation, but I
# think having that play every time a light cheese was eaten would slow the
# game down too much.
func eat_light_cheese():
	light_cheese_eaten.emit()
	active = false
	await play_light_cheese_being_eaten_anim()
	queue_free() # Light cheese is gone after being eaten.


# Plays the animation for the light cheese being eaten.
# There was some weird flickering with light cheese being eaten, but setting
# the timer to be slightly less than the full duration of the light cheese
# being eaten seems to help.
func play_light_cheese_being_eaten_anim():
	$LightCheeseAnims.play("light_cheese_being_eaten")
	await get_tree().create_timer(0.9).timeout
	$LightCheeseAnims.stop()
	hide()
