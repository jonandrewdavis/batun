extends State
class_name PlayerEvade

func Enter():
	print('Evading!')
	player.animation_player.play("PlayerAnimationSaved/evade")
	player.max_speed = player.max_speed * 1.3
	player.acceleration = player.acceleration * 1.8

func Update(_delta): 
	if not player.animation_player.is_playing():
		Transitioned.emit(self, "PlayerIdle")

func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	
func Exit():
	player.remove_slow()
