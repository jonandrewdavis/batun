extends State
class_name PlayerLocked

func Enter():
	player.animation_player.play("PlayerAnimationSaved/locked")
	player.velocity = Vector2.ZERO
	player.mov_direction = Vector2.ZERO
	# player.weapon.pointer.visible = false	
	
func Update(_delta): 
	player.can_pause()
	pass

func Physics_Update(_delta: float):
	pass
	# player.move()
	
func Exit():
	# player.weapon.pointer.visible = true	
	pass
