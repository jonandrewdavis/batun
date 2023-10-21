extends Node2D

@onready var animation_player = $AnimationPlayer

@onready var player = get_parent()
@onready var pointer = $Pointer
@onready var hammer_holder = $HammerHolder

@export var locked = false

# TODO: on ready, loop through and connct
# TODO: Clean up variables, ya goof. We're all over the place.

# TODO: generate programattically from the Animations Weapon
# is equipped with!
@onready var all_weapons = [
	{
		'name': 'Spear',
		'node': $Spear,
		'attacks': {
			'WeaponAnimations/Spear1': {
				"damage": 10,
				"knockback": 2,
				"slow": 2,
			},
		}
	},
	{ 
		'name': 'Hammer',
		'node': $HammerHolder/Hammer,
		'attacks': {
			'WeaponAnimations/Hammer1': {
				"damage": 50,
				"slow": 30,
				"knockback": 25,
			},
		}
	}
]

@export var current_weapon_index: int = 0

var all_spells = [
	{
		'name': 'LightningBolt',
		'damage1': 33,
		'slow1': 20,
	},
]

var current_spell = all_spells[0]
var current_weapon = null

func _ready():
	for single_weapon in all_weapons:
		single_weapon.node.weapon_ref = self
		# single_weapon.node.body_entered.connect(_test)
		# single_weapon.node.body_entered.connect('_on_body_entered')
	current_weapon = all_weapons[current_weapon_index]	
	
func set_weapon(index):
	current_weapon_index = index
	current_weapon = all_weapons[current_weapon_index]	
	
func _test():
	print('test')

func _process(delta):
	if not is_multiplayer_authority(): return
	# Do not allow looking or swinging if we're "mid-swing".
	if locked == true: 
		return
	# Powers the pointer!
	look_at(get_global_mouse_position())
	# This inversion works really well! It effectively makes 
	# rotation of weapons from 0 to 180 swing the same way on each side!
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	if not current_weapon:
		return
	if mouse_direction.x > 0:
		hammer_holder.scale.x = 1
		all_weapons[1].node.scale.y = 1
	elif mouse_direction.x < 0:
		hammer_holder.scale.x = -1
		all_weapons[1].node.scale.y = -1

# TODO: figure out how we want to do "activating". extend from base weapon is probably correct.
# TODO: Ton of animations, state transition when complete?

# TODO: Weapon just has a ton of nodes that show and hide. just one giant animation player.
# Question: Do weapons need an FSM to transition themselves
# Answer: probably better to just do player states.

# Question: How do weapons _update the player_?
# Answer: Freely. They can choose to modify values that are then reset by PlayerIdle
# Answer: Weapons can choose to put a player in a state.

# Locking: lock after swing has STARTEd.
# slow in windup, stop at swing
# slow in cooldown


func get_weapon_hit():
	var this_attack = all_weapons[current_weapon_index].attacks[animation_player.current_animation]
	return {
		'damage': this_attack.damage,
		'knockback': this_attack.knockback		
	}

func attack1():
	var attackRoot = "WeaponAnimations/%s1"
	var attackString = attackRoot % current_weapon.name
	animation_player.play(attackString)
	player.apply_slow(current_weapon.attacks[attackString].slow)
	player.animation_player.play('PlayerAnimationSaved/action')
	
func spell1():
	pass
	# player.apply_slow(current_spell.slow1)	

