extends Node2D

@export var direction: Vector2 = Vector2.ZERO
@export var player_id: int
@export var damage: int
@export var knockback: int

@export var speed = 0
var acceleration = null

func _ready():
	if not multiplayer.is_server():
		return
	await get_tree().create_timer(3).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_area_2d_area_exited(area):
	if area.get_multiplayer_authority() != player_id:
		queue_free()

