extends Node2D


@export var connected: Node2D

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var Network = get_tree().get_root().get_node('/root/Main/Network')

var current_players = 0
var player_nodes = []

@rpc('authority', 'reliable')
func spawn(spawn_positions):
	for child in get_parent().get_children():
		if child is Player:
			var rng = RandomNumberGenerator.new()
			var posIndex = rng.randi_range(0, spawn_positions.size() - 1)
			var rndX = rng.randi_range(spawn_positions[posIndex].x - 50, spawn_positions[posIndex].x + 50)
			var rndY = rng.randi_range(spawn_positions[posIndex].y - 50, spawn_positions[posIndex].y + 50)
			child.position = Vector2(rndX, rndY)

func _on_area_2d_area_entered(area):
	if area.name == "PlayerArea":
		animation_player.play("fade")
		current_players = current_players + 1
		if current_players + 1 == Network.players.values().size() and current_players + 1 > 2:
			animation_player.stop()
			animation_player.play('blink')

func _on_area_2d_area_exited(area):
	if area.name == "PlayerArea":
		current_players = current_players - 1
		if current_players == 0:
			animation_player.stop()
			$Effects.modulate.a = 0
		elif current_players > 0:
			animation_player.play("fade")
