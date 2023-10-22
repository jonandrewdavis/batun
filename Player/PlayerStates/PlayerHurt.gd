extends State
class_name PlayerHurt

var busy_timer
const busy_value = 0.6

var death_timer
const death_value = 3.5

func Enter():
	player.animation_player.play("PlayerAnimationSaved/hurt")
	player.weapon.animation_player.play("WeaponAnimations/None")
	player.remove_slow()
	player.is_invincible = true
	busy_timer = get_tree().create_timer(busy_value)
	await busy_timer.timeout
	if player.hp >= 0:
		Transitioned.emit(self, "PlayerIdle")
	else:
		player.animation_player.play("PlayerAnimationSaved/dead")
		death_timer = get_tree().create_timer(death_value)
		await death_timer.timeout
		player.restore_previous_state()

func Update(_delta): 
	pass

func Physics_Update(_delta: float):
	player.move()
	
func Exit():
	player.is_invincible = false	
	pass
