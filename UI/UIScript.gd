extends Node2D

@onready var weapon_panels = $CanvasLayer/Control/MarginContainer/VBoxContainer/WeaponPanels
@onready var scores_vbox  = $CanvasLayer/Scores/MarginContainer/VBoxContainer/ScoresContainer
@onready var menu = $CanvasLayer/Menu
@onready var player: Player = get_parent()

@onready var health = $CanvasLayer/Control/MarginContainer/VBoxContainer/Bars/VBoxContainer/Health
@onready var health_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/Bars/MarginContainer/Labels/HealthLabel

@onready var stamina = $CanvasLayer/Control/MarginContainer/VBoxContainer/Bars/VBoxContainer/StamContainer/Stamina
@onready var stamina_label = $CanvasLayer/Control/MarginContainer/VBoxContainer/Bars/MarginContainer/Labels/StaminaLabel
@onready var evade_radial = $CanvasLayer/Control/MarginContainer/VBoxContainer/SpellPanels/Spells/Evade/EvadeRadial

# settings
@onready var master_slider: HSlider = $CanvasLayer/Menu/TabBar/TabContainer/Settings/HBoxContainer/VBoxContainer/HSliderMaster
@onready var music_slider: HSlider = $CanvasLayer/Menu/TabBar/TabContainer/Settings/HBoxContainer/VBoxContainer/HSliderMusic
@onready var sfx_slider: HSlider = $CanvasLayer/Menu/TabBar/TabContainer/Settings/HBoxContainer/VBoxContainer/HSliderSFX

var LineItem = preload('res://UI/PlayerLineItem.tscn')

var bus_master = AudioServer.get_bus_index("Master")
var bus_music = AudioServer.get_bus_index("Music")
var bus_sfx = AudioServer.get_bus_index("SFX")

# TODO: programatically do all this from a List[]
var volume_master_value
var volume_music_value
var volume_sfx_value

func _ready():
	set_weapon(0)
	var primary = get_tree().get_root().get_node('/root/Main/Network')
	primary.connect("player_connected", _on_player_connected)
	primary.connect("score_signal", _on_player_scored)
	primary.connect("win_signal", _on_player_win)
	
	volume_master_value = db_to_linear(AudioServer.get_bus_volume_db(bus_master))
	volume_music_value = db_to_linear(AudioServer.get_bus_volume_db(bus_music))
	volume_sfx_value = db_to_linear(AudioServer.get_bus_volume_db(bus_sfx))

	# sliders
	master_slider.max_value = volume_master_value * 2
	music_slider.max_value = volume_music_value * 2
	sfx_slider.max_value = volume_sfx_value * 2
	# values
	master_slider.value = volume_master_value 
	music_slider.value = volume_music_value
	sfx_slider.value = volume_sfx_value
	
	# 
	var complete = ""
	for weapon in player.weapon.all_weapons:
		complete += str(weapon.attacks[0]) + "\n"
		
	for spell in player.spellbook.all_spells:
		complete += str(spell) + "\n"

	complete += "Player Max Speed: " + str(player.max_speed) + "\n"		
	complete += "Player Acceleration: " + str(player.CONST_ACCELERATION)	+ "\n"
	complete += "Player Friction: " + str(player.friction)	+ "\n"
				
	$CanvasLayer/Menu/TabBar/TabContainer/GameData/GameDataLabel.text = complete
	
func _process(_delta):
	var get_hp = player.hp
	var get_stamina = player.stamina
	if get_hp != health.value:
		health.value = get_hp
		health_label.text = str(get_hp)	

	if get_stamina != stamina.value:
		stamina.value = get_stamina
		stamina_label.text = str(get_stamina)

	if Input.is_action_just_pressed("tab"):
		$CanvasLayer/Scores.visible = true
	if Input.is_action_just_released("tab"):
		$CanvasLayer/Scores.visible = false

	if not $EvadeTimer.is_stopped():
		evade_radial.value = 	$EvadeTimer.time_left * 100

func set_weapon(index): 
	for panel in weapon_panels.get_children():
		panel.get_node("ColorRect").visible = false
	weapon_panels.get_children()[index].get_node("ColorRect").visible = true

func show_round_end(text: String, _visible: bool):
	$CanvasLayer/RoundInfo.text = text
	$CanvasLayer/RoundInfo.visible = _visible

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
		new_line_item.win = 0
		scores_vbox.add_child(new_line_item)

# TODO: keep a struct of all the players, and update that.
func _on_player_scored(player_id: int):
	for n in scores_vbox.get_children():
		if n.id == str(player_id):
			n.score = n.score + 1
			n.make_score(0)

func _on_player_win(player_id: int):
	for n in scores_vbox.get_children():
		if n.id == str(player_id):
			n.win = n.win + 1
			n.make_win(0)

var last_state = ''

func toggleMenu():
	menu.visible = !menu.visible
	if (menu.visible == true):
		last_state = player.FSM.current_state.name
		player.set_state("PlayerLocked")		
	else: 
		player.set_state(last_state)


func _on_quit_button_pressed():
	get_tree().quit()
	pass # Replace with function body.

func _on_h_slider_master_value_changed(value):
	AudioServer.set_bus_volume_db(bus_master, linear_to_db(value))
	pass # Replace with function body.

func _on_h_slider_music_value_changed(value):
	AudioServer.set_bus_volume_db(bus_music, linear_to_db(value))
	pass # Replace with function body.

func _on_h_slider_sfx_value_changed(value):
	AudioServer.set_bus_volume_db(bus_sfx, linear_to_db(value))
	pass # Replace with function body.

func flash_stamina():
	stamina.self_modulate.a = 0.1
	await get_tree().create_timer(0.1).timeout
	stamina.self_modulate.a = 1
	await get_tree().create_timer(0.1).timeout
	stamina.self_modulate.a = 0.1
	await get_tree().create_timer(0.1).timeout
	stamina.self_modulate.a = 1


func show_evade_timer(time):
	$CanvasLayer/Control/MarginContainer/VBoxContainer/SpellPanels/Spells/Evade/EvadeHighlight.visible = false
	evade_radial.max_value = time * 100
	$EvadeTimer.one_shot = true
	$EvadeTimer.wait_time = time
	$EvadeTimer.start()
	pass

func show_evade_highlight():
	$CanvasLayer/Control/MarginContainer/VBoxContainer/SpellPanels/Spells/Evade/EvadeHighlight.visible = true

func flush_max():
	pass
