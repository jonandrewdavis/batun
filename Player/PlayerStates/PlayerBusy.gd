extends State
class_name PlayerBusy

func Enter():
	player.animation_player.play("PlayerAnimationSaved/idle",true)
	player.apply_slow()
	await get_tree().create_timer(0.6).timeout
	Transitioned.emit(self, "PlayerIdle")
	
func Update(_delta): 
	pass

func Physics_Update(_delta: float):
	player.get_input()
	player.move()
	
func Exit():
	player.remove_slow()
