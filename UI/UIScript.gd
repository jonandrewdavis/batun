extends Node2D

@onready var weapon_panels = $CanvasLayer/Control/PanelContainer/WeaponContainer/WeaponPanels
@onready var scores = $CanvasLayer/Scores

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": SavedData.username}
var players_loaded = 0

func _ready():
	set_weapon(0)
	
func set_weapon(index): 
	for panel in weapon_panels.get_children():
		panel.get_node("ColorRect").visible = false
	weapon_panels.get_children()[index].get_node("ColorRect").visible = true

