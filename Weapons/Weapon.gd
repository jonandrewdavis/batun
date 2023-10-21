extends Node2D

@onready var animation_player = $AnimationPlayer

@onready var player = get_parent()
@onready var pointer = $Pointer
@onready var hammer_holder = $HammerHolder

@export var locked = false

# TODO: on ready, loop through and connct

@onready var all_weapons = [
	{
		'name': 'Spear',
		'damage1': 10,
		'slow1': 2,
		'playerAnimation' : null,
		'node': $Spear
	},
	{ 
		'name': 'Hammer',
		'damage1': 50,
		'slow1': 30,
		'playerAnimation' : 'PlayerAnimationSaved/action',
		'node': $HammerHolder/Hammer
	}
]

@onready var current_weapon = all_weapons[0]

var all_spells = [
	{
		'name': 'LightningBolt',
		'damage1': 33,
		'slow1': 20,
	},
]

var current_spell = all_spells[0]


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

var ani_lookup1 = "WeaponAnimations/%s1"


func attack1():
	player.apply_slow(current_weapon.slow1)
	animation_player.play(ani_lookup1 % current_weapon.name)
	if current_weapon.playerAnimation: 	player.animation_player.play(current_weapon.playerAnimation)
	
func spell1():
	player.apply_slow(current_spell.slow1)	


# TODO:
# hitbox, hurtbox
# target dummy (player??)
