extends State
class_name PlayerAttack1

func Enter():
	player.animation_player.stop()

		
func Update(_delta): 
	if not (player.weapon.animation_player.is_playing()):
		Transitioned.emit(self, "PlayerIdle")
	else:
		if Input.is_action_just_released("left_click"):
			player.weapon.attack1_release()
			
func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	
func Exit():
	player.weapon.animation_player.play("WeaponAnimations/RESET")
	if not is_multiplayer_authority(): return
	# Note: should not need this reset of the weapon if your
	# animations are properly set up!
	# player.weapon.combo_window = false
	# player.weapon.combo_factor = 1
	player.remove_slow()
	player.weapon.pointer.visible = true	
	player.start_recovery()
