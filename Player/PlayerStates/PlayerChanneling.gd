extends State
class_name PlayerChanneling

var busy_timer
const busy_value = 5

func Enter():
	# player.SFX.play('swap')
	player.animation_player.play("PlayerAnimationSaved/idle",true)
	player.apply_slow()
	busy_timer = get_tree().create_timer(busy_value)
	player.progress.visible = true
	player.progress.max_value = busy_value * 100
	
	
func Update(_delta): 
	player.recover()
	player.progress.value = busy_timer.time_left * 100
	if player.velocity.length() > 10:
		Transitioned.emit(self, "PlayerIdle")
	if busy_timer.time_left == 0:
		Transitioned.emit(self, "PlayerIdle")
		player.open_chest()

func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	
func Exit():
	player.remove_slow()
	player.progress.visible = false
