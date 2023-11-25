extends Area2D

signal light_cheese_eaten

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	if (active):
		eat_light_cheese()


func start(pos):
	position = pos
	show()
	$LightCheeseAnims.play("light_cheese_intact")
	$LightCheeseCollision.disabled = false
	active = true


func eat_light_cheese():
	light_cheese_eaten.emit()
	active = false
	await play_light_cheese_being_eaten_anim()
	queue_free() # Light cheese is gone after being eaten.


func play_light_cheese_being_eaten_anim():
	$LightCheeseAnims.play("light_cheese_being_eaten")
	await get_tree().create_timer(0.9).timeout
	$LightCheeseAnims.stop()
	hide()
