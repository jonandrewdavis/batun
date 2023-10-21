extends State
class_name PlayerMove

# TODO: Consider removing Move, unless some actions
# depened on being in motion, but even then! 
# just put it on the animation check in Idle

func Enter():
	player.animation_player.play("PlayerAnimationSaved/move")
	pass

func Physics_Update(_delta: float):
	if player.velocity.length() < 10:
		Transitioned.emit(self, "PlayerIdle")
	player.get_input()
	player.move()
	player.attack()
	player.evade()
