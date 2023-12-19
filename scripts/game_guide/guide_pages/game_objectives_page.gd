class_name GameObjectivesPage
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$MultiCheeseSprite.play("shimmer")
	$TimerSprite.play("shimmer")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
