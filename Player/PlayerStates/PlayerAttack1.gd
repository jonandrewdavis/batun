extends State
class_name PlayerAttack1

func Enter():
	player.animation_player.stop()
	player.weapon.attack1()
	player.weapon.pointer.visible = false	
		
func Update(_delta): 
	if not (player.weapon.animation_player.is_playing()):
		Transitioned.emit(self, "PlayerIdle")
	
func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	
func Exit():
	# player.weapon.animation_player.queue("RESET")
	# player.weapon.combo_window = false
	# player.weapon.combo_factor = 1
	player.remove_slow()
	player.weapon.pointer.visible = true	
