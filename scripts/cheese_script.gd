extends Area2D

signal cheese_eaten

# Size of the game window.
var screen_size

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if active && event is InputEventMouseMotion:
		position = event.position
		position = position.clamp(Vector2.ZERO, screen_size)


func _on_area_entered(area):
	if (active):
		eat_cheese()


func start(pos):
	position = pos
	show()
	$CheeseAnims.play("cheese_intact")
	$CheeseCollision.disabled = false
	active = true


func eat_cheese():
	cheese_eaten.emit()
	active = false
	await play_cheese_being_eaten_anim()
	hide() # Cheese disappears after being eaten.
	# Must be deferred as we can't change physics properties on a physics callback.
	$CheeseCollision.set_deferred("disabled", true)


func play_cheese_being_eaten_anim():
	$CheeseAnims.play("cheese_being_eaten")
	await get_tree().create_timer(5.0).timeout
	$CheeseAnims.stop()
