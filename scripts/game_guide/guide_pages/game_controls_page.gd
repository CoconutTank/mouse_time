class_name GameControlsPage
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$MouseToCheeseSprite.play("wiggle")
	$CheeseToMouseSprite.play("wiggle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
