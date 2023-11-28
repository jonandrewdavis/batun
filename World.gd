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
	if HomeTeleport.current_players == Network.players.values().size():
		round_players = Network.players.values().size()
		round_started = true
		var spawn_positions = []
		for spawn in Spawns.get_children():
			spawn_positions.append(spawn.global_position)
		HomeTeleport.spawn.rpc(spawn_positions)

func end_round():
	# if round_players 
	var ghosts = 0
	var winner_id = null
	var winner_label = ''
	for body in BattleArea.get_overlapping_bodies():
		if body is Player:
			if body.is_ghost == true:
				ghosts = ghosts + 1

	if ghosts == round_players - 1:
		RoundTimer.stop()
		for body in BattleArea.get_overlapping_bodies():
			if body is Player and body.is_ghost == false:
				winner_id = body.get_multiplayer_authority()
				winner_label = body.userlabel.text
		Network._on_player_win.rpc(winner_id)
		reset_all_players.rpc(winner_label)
		RoundTimer.start()
		round_started = false

@rpc('authority', 'reliable')
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
	if round_started == false:
		start_round()
	else: 
		end_round()

func _on_battle_area_body_entered(body):
	if body is Player:
		body.is_invincible = false
