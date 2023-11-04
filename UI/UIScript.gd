extends Node2D

@onready var weapon_panels = $CanvasLayer/Control/PanelContainer/WeaponContainer/WeaponPanels
@onready var scores = $CanvasLayer/Scores
@onready var scores_vbox  = $CanvasLayer/Scores/MarginContainer/VBoxContainer

var LineItem = preload('res://UI/PlayerLineItem.tscn')

func _ready():
	set_weapon(0)
	var primary = get_tree().get_root().get_node('/root/Main/Network')
	primary.connect("player_connected", _on_player_connected)
	primary.connect("score_signal", _on_player_scored)
	
func _process(_delta):
	if Input.is_action_just_pressed("tab"):
		$CanvasLayer/Scores.visible = true
	if Input.is_action_just_released("tab"):
		$CanvasLayer/Scores.visible = false
		
func set_weapon(index): 
	for panel in weapon_panels.get_children():
		panel.get_node("ColorRect").visible = false
	weapon_panels.get_children()[index].get_node("ColorRect").visible = true

func _on_player_connected(players):
	for n in scores_vbox.get_children():
		scores_vbox.remove_child(n)
		n.queue_free()
	
	for player_id in players:
		var new_line_item = LineItem.instantiate()
		# Node name
		new_line_item.name = str(player_id)
		new_line_item.id = str(player_id)
		# Player name
		new_line_item.player_name = players[player_id].name
		new_line_item.score = players[player_id].score
		scores_vbox.add_child(new_line_item)

# TODO: keep a struct of all the players, and update that.
func _on_player_scored(player_id: int):
	for n in scores_vbox.get_children():
		if n.id == str(player_id):
			n.score = n.score + 1
			n.make_score(0) 
	# get the id, new score
