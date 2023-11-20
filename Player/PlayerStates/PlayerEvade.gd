extends State
class_name PlayerEvade

func Enter():
	player.animation_player.play("PlayerAnimationSaved/evade")
	player.max_speed = player.max_speed * 1.3
	player.acceleration = player.acceleration * 1.8
	await get_tree().create_timer(0.1).timeout
	player.is_invincible = true

func Update(_delta): 
	player.recover()
	if not player.animation_player.is_playing():
		Transitioned.emit(self, "PlayerIdle")

func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	
func Exit():
	player.radial.max_value = 6 * 100
	player.evade_timer.one_shot = true
	player.evade_timer.wait_time = 6
	player.evade_timer.start()
	player.remove_slow()
	player.is_invincible = false
	player.start_recovery()
