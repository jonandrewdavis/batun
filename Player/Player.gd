extends CharacterBody2D

var current_weapon: Node2D

const CONST_MAX_HP = 100;
const CONST_STARTING_SPEED = 120; # increase for top speed
const CONST_ACCELERATION = 300 # decrease to cause more startup time

@export var max_hp: int = CONST_MAX_HP
@export var hp: int = CONST_MAX_HP
@export var FRICTION: int = 200 # decrease to cause sliding
@export var acceleration = CONST_ACCELERATION 
@export var max_speed = CONST_STARTING_SPEED 

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mov_direction: Vector2 = Vector2.ZERO
@onready var FSM = $FSM

@onready var userlabel = $Label

# TODO: is choosing a node better? :thinking: programmatic is probably best, even though
# FSM doesn't do it.
@onready var weapon = $Weapon

# TODO: UI, weapon swapz
# var UI = preload("res://UI/UI.tscn")
var UIref = null

var mouse_direction: Vector2

const RESPAWN_RADIUS = 75
var PLAYER_START: Vector2 = Vector2(-0, 10)

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	# NOTE: Below this line, `not is_multiplayer_authority()` assures that 
	# code runs only on the client. (Since each player is it's own authority).
	# All nodes within these are LOCAL (client) only. Camera, Inventory, UI, etc.
	# TODO: Move `userlabel.text` above this line and remove from sync
	if not is_multiplayer_authority(): 
		return
	# ---- Player Client Nodes -----
	# var newUI = UI.instantiate()
	var newCamera = Camera2D.new()
	userlabel.text = SavedData.username
	# All local. Weapons are in /Weapons, so those exist on server, and need to.
	# emit_signal("weapon_picked_up", weapons.get_child(0).get_texture())
	newCamera.ignore_rotation = true
	newCamera.limit_smoothed = true
	add_child(newCamera)
	# add_child(newUI)
	# UIref = get_node("UI")
	_restore_previous_state()
	
func is_player():
	return true

func _physics_process(delta: float) -> void:
	if mov_direction != Vector2.ZERO:
		velocity = velocity.move_toward(mov_direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

func set_state(state):
	FSM.on_child_transition(FSM.current_state, state)


func move() -> void:
	move_and_slide()
	
# take_damage drives a lot of logic
# source is from HitBox on enemies or on weapon
func take_damage(dam: int, dir: Vector2, force: int) -> void:
	pass

func take_knockback(_dam: int, dir: Vector2, force: int) -> void:
		velocity += dir * force

func _spawn_hit_effect() -> void:
	pass
	
func apply_slow(_factor = 10):
	max_speed = CONST_STARTING_SPEED / _factor
	
func remove_slow():
	max_speed = CONST_STARTING_SPEED
	acceleration = CONST_ACCELERATION

# not used, maybe do on ever state change.
func cooldown():
	max_speed = CONST_STARTING_SPEED / 8
	acceleration = CONST_ACCELERATION / 2
	

func _restore_previous_state() -> void:
	# TODO: Better "respawn" logic
	hp = CONST_MAX_HP
	max_speed = CONST_STARTING_SPEED
	if self.name == str(1):
		PLAYER_START = Vector2.ZERO
	if randi() % 2 == 0:
		position = Vector2(PLAYER_START.x + randf() * RESPAWN_RADIUS, PLAYER_START.y + randf() * RESPAWN_RADIUS)
	else: 
		position = Vector2(PLAYER_START.x - randf() * RESPAWN_RADIUS, PLAYER_START.y - randf() * RESPAWN_RADIUS)


func _process(_delta: float) -> void:
	if OS.is_debug_build(): userlabel.text = FSM.current_state.name
	if not is_multiplayer_authority(): return
	mouse_direction = (get_global_mouse_position() - global_position).normalized()
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true


func _unhandled_input(_event):
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("escape"):
		if OS.is_debug_build(): 
			get_tree().quit()
		else:
			pass
			
func attack():
	if Input.is_action_just_pressed("left_click"): 
		set_state('PlayerAttack1')
	elif Input.is_action_just_pressed("right_click"):
		set_state('PlayerAttack2')

func evade():
	if Input.is_action_just_pressed("space"):
		print('trying evade!')
		set_state('PlayerEvade')

# TODO: check weapon length to make sure it's present.
func change_weapon(): 
	if Input.is_action_just_pressed("1"):
		weapon.current_weapon = weapon.all_weapons[0]
		set_state("PlayerBusy")
	if Input.is_action_just_pressed("2"):
		weapon.current_weapon = weapon.all_weapons[1]
		set_state("PlayerBusy")
	if Input.is_action_just_pressed("3"):
		# weapon.current_weapon = weapon.all_weapons[2]
		set_state("PlayerBusy")
	if Input.is_action_just_pressed("4"):
		# weapon.current_weapon = weapon.all_weapons[3]
		set_state("PlayerBusy")
		
func get_input() -> void:
	if not is_multiplayer_authority(): return
		
	mov_direction = Vector2.ZERO
	mov_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	mov_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	mov_direction = mov_direction.normalized()
	
func cancel_attack() -> void:
	pass
#	current_weapon.cancel_attack()
	
func respawn() -> void:
	delay_loot(global_position)
	_restore_previous_state()

func delay_loot(new_pos):
	pass

func interact(): 
	# Look for interactable bodies,
	# pick closest
	pass

# TODO: This should be emit, (signal up)
func player_pvp(value):
	if value == true:
		userlabel.add_theme_color_override("font_color", Color(1,0,0))
	else:
		userlabel.remove_theme_color_override("font_color")
	self.set_collision_layer_value(6, value)



# TODO: Change wepaons
# TODO: hitboxes, knockback, dummy
