extends Node2D

@export var direction: Vector2 = Vector2.ZERO
@export var player_id: int
@export var damage: int
@export var knockback: int

@export var speed = 0
var acceleration = null

var destroy_timer = Timer.new()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_area_2d_area_exited(_area):
	pass

func _on_area_2d_area_entered(area: Area2D):
	if "weapon_ref" in area and area.get_multiplayer_authority() != player_id:  
		var hit: Hit = area.weapon_ref.get_weapon_hit()
		direction = hit.angle
		rotation = area.weapon_ref.get_position().angle_to_point(hit.angle)
		player_id = area.get_multiplayer_authority()
		$Timer.start()
		return
	elif area.get_parent().has_method("is_player"):
		return
	

func _on_timer_timeout():
	queue_free()

func destroy():
	queue_free()
