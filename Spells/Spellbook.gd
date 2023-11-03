extends Node2D

@onready var Spell = load("res://Spells/Spell.tscn")
@onready var player = get_parent()

# firebolt, lightningbolt, block?, rain of fire, powershot
# cooldown

var all_spells = [
	{
		'name': 'Firebolt',
		'damage': 9,
		'slow': 1000,
		'knockback': 100,
		'cast_time': 0.8,
		'speed' : 140

	},
	{
		'name': 'LightningBolt',
		'damage': 13,
		'slow': 1000,
		'knockback': 0,
		'cast_time': 0.8,
		'speed' : 1000
	},
]

var current_spell = all_spells[0]

func spell1():
	player.apply_slow(current_spell.slow)
	player.animation_player.play('PlayerAnimationSaved/action')
	await get_tree().create_timer(0.8).timeout
	var spell_rotation = self.global_position.direction_to(get_global_mouse_position()).angle()
	var spell_direction = self.global_position.direction_to(get_global_mouse_position())
	var spell_position = player.global_position
	spawn_spell.rpc(spell_rotation, spell_direction, spell_position, current_spell, get_multiplayer_authority())
	player.set_state('PlayerIdle')


@rpc('call_local', 'authority', 'unreliable')
func spawn_spell(_rotation, _direction, _position, _current_spell, playerID):
	var spell: Node2D = Spell.instantiate()
	# standard
	spell.rotation = _rotation
	spell.direction = _direction
	spell.position = _position
	spell.player_id = playerID

	# Stats
	spell.damage = _current_spell.damage
	spell.knockback = _current_spell.knockback
	spell.speed = _current_spell.speed
	
	get_tree().current_scene.get_node("World").add_child(spell, true)

func ult():
	print('ult')
	pass 
