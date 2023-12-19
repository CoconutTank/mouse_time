extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$SleepyMouseSprite.play("sleep")
	$KnockedOutMouseSprite.play("ko")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
