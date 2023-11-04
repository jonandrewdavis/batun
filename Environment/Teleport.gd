extends Node2D


@export var connected: Node2D

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var clearing_shape = $StaticBody2D/CollisionShape2D

func _on_area_2d_area_entered(area):
	if area.name == "PlayerArea":
		animation_player.play("blink")
		connected.animation_player.play("blink")
		timer.start()
		await timer.timeout
		connected.clearing_shape.disabled = false
		await get_tree().create_timer(0.1).timeout
		connected.clearing_shape.disabled = true
		
		var new_pos = connected.global_position
		if randi() % 2 == 0:
			if randi() % 2 == 0:
				area.get_parent().position = Vector2(new_pos.x - randf() * 8 + 10, new_pos.y - randf() * -8 - 5)	
			else:
				area.get_parent().position = Vector2(new_pos.x + randf() * 8 - 15, new_pos.y + randf() * 8)
		else:
			area.get_parent().position = Vector2(new_pos.x + randf() * 12, new_pos.y + randf() * 12 - 15)



func _on_area_2d_area_exited(area):
	if area.name == "PlayerArea":
		animation_player.stop()
		connected.animation_player.stop()
		timer.stop()
		pass # Replace with function body.
