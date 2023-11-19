extends State
class_name PlayerAttack1

func Enter():
	player.animation_player.stop()
	if player.last_press == 1:
		player.weapon.attack1()
	elif player.last_press == 2:
		player.weapon.block()
		
func Update(_delta): 
	if not (player.weapon.animation_player.is_playing()):
		Transitioned.emit(self, "PlayerIdle")
	
func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	
func Exit():
	# Note: should not need this reset of the weapon if your
	# animations are properly set up!
	# player.weapon.animation_player.play("RESET")
	# player.weapon.combo_window = false
	# player.weapon.combo_factor = 1
	player.remove_slow()
	player.weapon.pointer.visible = true	
