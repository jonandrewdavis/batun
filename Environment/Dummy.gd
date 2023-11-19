extends CharacterBody2D

var hp = 1000
@export var FRICTION: int = 200 # decrease to cause sliding


func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	# move_and_slide()

func take_damage(damage: int, knockback: int, direction: Vector2) -> void:
		hp -= damage
		$StatusFeedback/Label.text = "%s" % damage
		$StatusFeedback/AnimationPlayer.play("show_number")
		velocity += direction * knockback
		
# DUMMY CODE
func _on_hurtbox_area_entered(area):
	# TODO: Better check here.
	# don't get hit by server objects, TODO: understand authority better!
	# TODO: test working 
	if "damage" in area.get_parent():
		var spell = area.get_parent()
		take_damage(spell.damage, spell.knockback, spell.direction)
	
	if "weapon_ref" in area and area.weapon_ref != null:
		var hit: Hit = area.weapon_ref.get_weapon_hit()
		if hit != null:
			take_damage(hit.damage, hit.knockback, hit.angle)
			$AnimationPlayer.play('dummy')
