extends Node2D

# When entities take a hit, they use these two values to 
# look up what hit them. 
@onready var animation_player = $AnimationPlayer
@export var current_weapon_index: int = 0

@onready var player = get_parent()
@onready var pointer = $Pointer
@onready var hammer = $Hammer

# TODO: ALL "swing directional" weapons should use a SINGLE "sheathe",
# $Holder, for now to mirror the swing properly,
# this makes the swing more predictable for the player.
@onready var holder = $Holder
@onready var inner_holder = $Holder/InnerHolder
@export var locked = true

var all_weapons = null

# TODO: Pointer, Locked, Visible, is controlled in animations
# this is a pain if I have to redo the animations.
# granular control is nice, but a quick "lock / unlock" that does
# all the things would be a nice func.

func _prepare_all_weapons(): 
	var spearAttack1 = Attack.new()
	spearAttack1.animation = 'WeaponAnimations/Spear1'
	spearAttack1.damage = 4
	spearAttack1.self_slow = 1
	spearAttack1.knockback = 50

	return [
	{
		'name': 'Spear',
		'node': $Spear,
		'attacks': [
			spearAttack1
		]
	},
	{ 
		'name': 'Hammer',
		'node': $Hammer,
		'attacks': [
			{
				"animation": 'WeaponAnimations/Hammer1',
				"damage": 30,
				"self_slow": 80,
				"knockback": 170,
			},
		]
	},
	{ 
		'name': 'Axe',
		'node': $Holder/InnerHolder/Axe,
		'attacks': [
			{
				"animation": 'WeaponAnimations/Axe1',
				"damage": 15,
				"self_slow": 20,
				"knockback": 70,
			},
		]
	},
		{ 
		'name': 'Sword',
		'node': $Holder/InnerHolder/Sword,
		'attacks': [
			{
				"animation" : 'WeaponAnimations/Sword1',
				"damage": 7,
				"self_slow": 4,
				"knockback": 50,
			},
		]
	}
]

var all_spells = [
	{
		'name': 'LightningBolt',
		'damage1': 13,
		'slow': 1000,
		'knockback': 0,
		'cast_time': 0.8,
	},
]

var current_spell = all_spells[0]
var current_weapon = null

func _ready():
	if is_multiplayer_authority:
		all_weapons = _prepare_all_weapons()
		for single_weapon in all_weapons:
			single_weapon.node.weapon_ref = self
		current_weapon = all_weapons[current_weapon_index]
	animation_player.play('RESET')

func set_weapon(index):
	current_weapon_index = index
	current_weapon = all_weapons[current_weapon_index]

func _process(_delta):
	if not is_multiplayer_authority(): return
	# Do not allow looking or swinging if we're "mid-swing".
	if locked == true: 
		return
	# Powers the pointer!
	look_at(get_global_mouse_position())
	
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	if mouse_direction.x > 0:
		holder.scale.x = 1
		inner_holder.scale.y = 1
		inner_holder.scale.x = 1
		if mouse_direction.y < 0:
			hammer.skew = -10
		else:
			hammer.skew = 10
	elif mouse_direction.x < 0:
		holder.scale.x = -1
		inner_holder.scale.y = -1
		inner_holder.scale.x = -1
		if mouse_direction.y < 0:
			hammer.skew = 10
		else:
			hammer.skew = -10

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

# RESET i think needs to be a seperate animation, it's not pic,king up

# TODO: 
func get_weapon_hit() -> Hit:
	if animation_player.is_playing():
		var animation_index = int(animation_player.current_animation.left(animation_player.current_animation.length() - 1))
		var attack_stats = current_weapon.attacks[animation_index]
		if current_weapon.attacks[animation_index]:
			var hit = Hit.new()
			hit.damage = attack_stats.damage
			hit.knockback = attack_stats.knockback
			hit.angle = Vector2(cos(self.rotation), sin(self.rotation))
			return hit
	return Hit.new()

func attack1():
	var current_attack = current_weapon.attacks[0]
	animation_player.play(current_attack.animation)
	player.apply_slow(current_attack.self_slow)
	player.animation_player.play('PlayerAnimationSaved/action')
	pass

func spell1():
	player.apply_slow(current_spell.slow)
	player.animation_player.play('PlayerAnimationSaved/action')
	pass


func ult():
	print('ult')
	pass 
