extends State
class_name PlayerIdle

func Enter():

	if (player.animation_player): player.animation_player.play("PlayerAnimationSaved/move")
	
func Update(_delta: float):
	if not is_multiplayer_authority(): return
	if player.velocity.length() > 10:
		player.animation_player.play("PlayerAnimationSaved/move")
	else: 
		player.animation_player.play("PlayerAnimationSaved/idle")
	player.get_input()
	player.move()
	player.attack()
	player.evade()
	player.change_weapon()
	player.activate()
