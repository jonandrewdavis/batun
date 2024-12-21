extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal score_signal(peer_id)
signal win_signal(peer_id)
signal coin_signal(peer_id)

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name", "score": 0, "wins": 0, "color": Color(1,1,1,1), "coins": 0}

## TODO: Use a Syncronizer in network or health
@onready var main_menu = $MainMenuCanvas/MainMenu
@onready var username = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/user
@onready var address_entry = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/address
@onready var join_button = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/Join
@onready var host_button = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/Host
@onready var check_button = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/CheckButton
@onready var world_ref =  get_tree().get_root().get_node('/root/Main/World')




# TODO: The Network component needs to be completely re-done.
# We should have a strategy more similar to the one in this video: 
# ----- https://www.youtube.com/watch?v=AytWpymeVJw
# A short to do list:
# - Enable PNP
# - Treat host as a "real player"
# - use the `is_server` for ALL game logic, on $World,
# - Treat multiplayer spawner, better, generally.  at that time, re-do Spellbook to function more sensibly,
# - Allows us to remove RPC calls that do weird shit on client /server double up. It's unpredictable.
# - Server / Player responsbility is more clear when doing RPCs
# - Use a Multiplayer Syncronizer to track score or world events?
# - Just... fix everything. Re-do it. As, it stands it's not maintainable. 
# - Long term goal to make the UI tolerable. Menus and HUD are not great.

var toggle_upnp = false
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

var _Player = load("res://Player/Player.tscn")

var nospawn = false
var debug_override = false
var include_host_player_body = true

const AWS_SERVER_IP = ''

func _ready():
	if OS.is_debug_build() and debug_override == true:
		_on_host_pressed()
		return
	else:
		# NOTE: Could do this in features, but the sever is more flexible this way
		var args = OS.get_cmdline_user_args()
		print('DEBUG: STARTING')
		$MainMenuCanvas.show()
		# NOTE: These are CLI args for running the server
		for arg in args:
			var key_value = arg.rsplit("=")
			match key_value[0]:
				"server":
					print('DEBUG: SERVER STARTING -- server found')
					await get_tree().create_timer(2).timeout
					_on_host_pressed()
				"nospawn":
					nospawn = true
			
		if OS.has_feature('client'):
			host_button.hide()
			check_button.hide()
			address_entry.text = AWS_SERVER_IP
		
		address_entry.text = AWS_SERVER_IP
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
		multiplayer.connected_to_server.connect(_on_connected_ok)
		multiplayer.connection_failed.connect(_on_connected_fail)
		multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_join_pressed():
	main_menu.hide()
	player_info = {"name" : username.text, "score": 0, "wins": 0, "color": player_info.color, "coins": 0}
	if username.text != '': SavedData.username = username.text
	#if OS.has_feature('client'):
		#enet_peer.create_client(address_entry.text, PORT)
	#else: 
		#enet_peer.create_client(address_entry.text, PORT)
	#multiplayer.multiplayer_peer = enet_peer


func _on_host_pressed():
	main_menu.hide()
	if username.text != '': SavedData.username = username.text
	#enet_peer.create_server(PORT)
	#multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	#print('DEBUG: SEVER IS READY:', multiplayer.get_unique_id())
	if include_host_player_body == true: 
		print("ADDING A PLA AYER", username.text)
		add_player(multiplayer.get_unique_id())
		_register_player.rpc({"name" : username.text, "score": 0, "wins": 0, "color": player_info.color, "coins": 0})

	world_ref.is_host = true
	world_ref.RoundTimer.start()

func add_player(peer_id):
	var player = _Player.instantiate()
	player.name = str(peer_id)
	print('DEBUG: Add player: ', peer_id)
	world_ref.add_child.call_deferred(player)

func remove_player(peer_id):
	var player = world_ref.get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
		

func _on_user_text_changed(new_text):
	if new_text != "":
		join_button.disabled = false
	else:
		join_button.disabled = true
		
func _on_color_picker_button_color_changed(new_color):
	player_info.color = new_color.lightened(0.2)
	pass # Replace with function body.


func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	var host_address = upnp.query_external_address()
	print("UPNP: Success! Join Address: %s" % host_address)
	SavedData.host_name = str(host_address)

func _on_check_button_toggled(button_pressed):
	toggle_upnp = button_pressed



# From the high_level_multiplayer docs

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	# save self
	players[id] = player_info
	# transmit my self to others
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "call_local")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	# emits: on_connected_ok
	player_connected.emit(players)
	for player in players:
		var world_children = world_ref.get_node_or_null(str(player))
		if world_children and world_children.animated_sprite != null:
			world_children.animated_sprite.set_modulate(players[player].color)

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

# TODO: Probably easier to just do a Syncronizer, lol.
@rpc("any_peer", "call_local", "reliable")
func _on_player_scored(player_id):
	players[player_id].score += 1
	score_signal.emit(player_id)

@rpc("any_peer", "call_local", "reliable")
func _on_player_win(player_id):
	players[player_id].wins += 1
	win_signal.emit(player_id)

@rpc("any_peer", "call_local", "reliable")
func _on_player_coin(player_id):
	players[player_id].coins += 1
	coin_signal.emit(player_id, players[player_id].coins)

@rpc("call_local", "authority", "reliable")
func reset_coins():
	for _id in players:
		players[_id].coins = 0
		coin_signal.emit(_id, 0)
