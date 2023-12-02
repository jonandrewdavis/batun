extends State
class_name PlayerMove

# TODO: Consider removing Move, unless some actions
# depened on being in motion, but even then! 
# just put it on the animation check in Idle

# UPDATE: "PlayerMove" is now the forced movement state. It's a little like "locked",
# You can't even change your direction! Oof!

func Enter():
	player.animation_player.play("PlayerAnimationSaved/channel")

func Physics_Update(_delta: float):
	player.move()

func Exit():
	player.cancel_sprint()
