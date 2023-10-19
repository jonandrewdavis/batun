extends State
class_name PlayerAttack1

func Enter():
	print('Attack')
	player.animation_player.stop()
	player.weapon.attack1()

func Update(_delta): 
	if not (player.weapon.animation_player.is_playing()):
		Transitioned.emit(self, "PlayerIdle")
	
func Physics_Update(_delta: float):
	player.get_input()
	player.move()

	
func Exit():
	player.remove_slow()
