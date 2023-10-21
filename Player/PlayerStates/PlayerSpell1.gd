extends State
class_name PlayerSpell1

## TODO: proliferation of attacks & spells helps customization, but may hurt long run
func Enter():
	player.animation_player.stop()
	player.weapon.spell1()

func Update(_delta): 
	if not (player.weapon.animation_player.is_playing()):
		Transitioned.emit(self, "PlayerIdle")
	
func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	
func Exit():
	player.remove_slow()
