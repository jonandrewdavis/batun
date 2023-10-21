extends State
class_name PlayerBusy

var busy_timer
const busy_value = 0.6

func Enter():
	player.animation_player.play("PlayerAnimationSaved/idle",true)
	player.apply_slow()
	busy_timer = get_tree().create_timer(busy_value)
	player.progress.visible = true
	player.progress.max_value = busy_value * 100
	await busy_timer.timeout
	Transitioned.emit(self, "PlayerIdle")
	
func Update(_delta): 
	player.progress.value = busy_timer.time_left * 100

func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	
func Exit():
	player.remove_slow()
	player.progress.visible = false
