extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal score_signal(peer_id)

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name", "score": 0, "color": Color(1,1,1,1)}
# var chosen_color_ui: Color = Color(0.35, 0.22, 0.46, 1)
var players_loaded = 0

@onready var main_menu = $MainMenuCanvas/MainMenu
@onready var username = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/user
@onready var address_entry = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/address
@onready var join_button = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/Join
@onready var host_button = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/Host
@onready var check_button = $MainMenuCanvas/MainMenu/MarginContainer/VBoxContainer/CheckButton
@onready var world_ref =  get_tree().get_root().get_node('/root/Main/World')

var toggle_upnp = false
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

var Player = preload('res://Player/Player.tscn')

var nospawn = false
var debug_override = false

const AWS_SERVER_IP = 'HARDCODE FOR PLAYERS HERE'

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
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
		multiplayer.connected_to_server.connect(_on_connected_ok)
		multiplayer.connection_failed.connect(_on_connected_fail)
		multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_join_pressed():
	main_menu.hide()
	player_info = {"name" : username.text, "score": 0, "color": player_info.color}
	if username.text != '': SavedData.username = username.text
	if OS.has_feature('client'):
		enet_peer.create_client(address_entry.text, PORT)
	else:
		enet_peer.create_client('', PORT)
	multiplayer.multiplayer_peer = enet_peer


func _on_host_pressed():
	main_menu.hide()
	if username.text != '': SavedData.username = username.text
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	print('DEBUG: SEVER IS READY:', multiplayer.get_unique_id())
	add_player(multiplayer.get_unique_id())
	if toggle_upnp == true:
		upnp_setup()

func add_player(peer_id):
	var player = Player.instantiate()
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
	player_info.color = new_color
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


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
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
	print('This player scored: ', player_id)
	score_signal.emit(player_id)

