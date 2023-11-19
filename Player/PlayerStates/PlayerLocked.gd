extends State
class_name PlayerLocked

func Enter():
	player.animation_player.play("PlayerAnimationSaved/idle",true)
	player.is_invincible = true
	# player.weapon.pointer.visible = false	
	
func Update(_delta): 
	pass

func Physics_Update(_delta: float):
	player.move()
	
func Exit():
	player.is_invincible = false
	# player.weapon.pointer.visible = true	
	pass
