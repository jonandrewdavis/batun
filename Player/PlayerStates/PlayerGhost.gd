extends State
class_name PlayerGhost

func Enter():
	player.animated_sprite.self_modulate.a = 0.2
	
func Update(_delta: float):
	player.get_input()
	player.move()
