extends Node2D


# polls 

@onready var RoundTimer = $Timers/RoundTimer
@onready var Network = get_tree().get_root().get_node('/root/Main/Network')
@onready var HomeTeleport = $HomeTeleport
@onready var Spawns = $Spawns
@onready var BattleArea = $BattleArea

var round_players = 0
var round_started = false
var is_host = false


func start_round():
	if HomeTeleport.current_players == Network.players.values().size() and HomeTeleport.current_players > 1:
		round_players = Network.players.values().size()
		round_started = true
		var spawn_positions = []
		for spawn in Spawns.get_children():
			spawn_positions.append(spawn.global_position)
		HomeTeleport.spawn.rpc(spawn_positions)
		$Timers/ChestTimer.start(4)

func end_round():
	# if round_players 
	var ghosts = 0
	for body in BattleArea.get_overlapping_bodies():
		if body is Player:
			if body.is_ghost == true:
				ghosts = ghosts + 1

	if ghosts == round_players - 1:
		for body in BattleArea.get_overlapping_bodies():
			if body is Player and body.is_ghost == false:
				trigger_end_round(body.get_multiplayer_authority(), body.userlabel.text)
				return 
				
	for player in Network.players:
		if Network.players[player].coins >= 5:
			trigger_end_round(player, Network.players[player].name)
			return
		
func trigger_end_round(winner_id, winner_label):

	RoundTimer.stop()
	Network.reset_coins.rpc()
	Network._on_player_win.rpc(winner_id)		
		
	# Chests Remove and stop:
	$Timers/ChestTimer.stop()
	for area in BattleArea.get_overlapping_areas():
		if area.name == 'ChestArea':
			area.get_parent().destroy.rpc()

	# Players, remove and make a new round, show Win screen
	reset_all_players.rpc(winner_label)
	RoundTimer.start()
	round_started = false

@rpc('authority', 'call_local')
func reset_all_players(winner_label):
	for child in get_children():
		if child is Player:
			child.show_winner("Round End. Winner %s" % winner_label, true)

	# TODO: Score the winner
	await get_tree().create_timer(5).timeout
	for child in get_children():
		if child is Player:
			child.restore_previous_state()
			child.show_winner("", false)

func _on_round_timer_timeout():
	# all but 1 dead.
	var complete = ''
	for _player_id in Network.players:
		complete += str('ID: ', _player_id, ', NAME: ', Network.players[_player_id].name, ', WINS: ', Network.players[_player_id].wins, ', ')

	print('DEBUG: ', Network.players.size(), ' PLAYERS: ', complete)
	if round_started == false:
		start_round()
	else: 
		end_round()

func _on_battle_area_body_entered(body):
	if body is Player:
		body.is_invincible = false

func _on_fire_body_entered(body):
	if body.has_method('is_player') and body.light != null:
		body.light.energy = 0.5
		body.light.set_texture_scale(0.8)
		body.light.set_item_shadow_cull_mask(0)

func _on_fire_body_exited(body):
	if body.has_method('is_player') and body.light != null:
		body.light.energy = 0.3
		body.light.set_texture_scale(1.1)
		body.light.set_item_shadow_cull_mask(1)
		

var chest = preload("res://Environment/Chest.tscn")

func get_random_spawn():
	var all_spawns = []
	for spawn in Spawns.get_children():
		all_spawns.append(spawn.global_position)
	var rng = RandomNumberGenerator.new()
	var posIndex = rng.randi_range(0, all_spawns.size() - 1)
	var rndX = rng.randi_range(all_spawns[posIndex].x - 50, all_spawns[posIndex].x + 50)
	var rndY = rng.randi_range(all_spawns[posIndex].y - 50, all_spawns[posIndex].y + 50)
	return Vector2(rndX, rndY)

func _on_chest_timer_timeout():
	var chest_counter = 0
	for area in BattleArea.get_overlapping_areas():
		if area.name == 'ChestArea':
			chest_counter += 1

	if chest_counter <= 12: 
		var new_chest = chest.instantiate()
		new_chest.position = get_random_spawn()
		get_node("/root/Main/World").add_child(new_chest, true)

	$Timers/ChestTimer.start(12)
	pass # Replace with function body.
	
func _clear_chests():
	for n in $ChestHolder.get_children():	
		$ChestHolder.remove_child(n)
		n.queue_free()
