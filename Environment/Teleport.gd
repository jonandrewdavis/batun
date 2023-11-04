extends Node2D


@export var connected: Node2D

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

func _on_area_2d_area_entered(area):
	if area.name == "PlayerArea":
		animation_player.play("blink")
		timer.start()
		await timer.timeout
		area.get_parent().position = connected.global_position
		pass # Replace with function body.


func _on_area_2d_area_exited(area):
	if area.name == "PlayerArea":
		animation_player.stop()
		timer.stop()
		pass # Replace with function body.
