extends State
class_name PlayerSpell1

## TODO: proliferation of attacks & spells helps customization, but may hurt long run
func Enter():
	player.animation_player.stop()
	player.spellbook.spell1()

func Update(_delta): 
	pass


func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	# TODO: Allow cancelling spells, with evade?
	# is this too powerful? 
	player.evade()
	
func Exit():
	player.remove_slow()
