extends State
class_name PlayerGhost

func Enter():
	player.animated_sprite.self_modulate.a = 0.1
	player.is_invincible = true
	player.hp = player.CONST_MAX_HP
	player.is_ghost = true
	player.health_bar.visible = false
	
func Update(_delta: float):
	if not is_multiplayer_authority(): return
	if player.velocity.length() > 10:
		player.animation_player.play("PlayerAnimationSaved/move")
	else: 
		player.animation_player.play("PlayerAnimationSaved/idle")
	player.get_input()
	player.move()
	player.can_pause()

func Exit():
	player.animated_sprite.self_modulate.a = 1.0
	player.is_ghost = false
