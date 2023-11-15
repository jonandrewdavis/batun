extends CharacterBody2D


const CONST_MAX_HP = 100;
const CONST_STARTING_SPEED = 130; # increase for top speed
const CONST_ACCELERATION = 220 # decrease to cause more startup time
const CONST_FRICTION = 280


@export var max_hp: int = CONST_MAX_HP
@export var hp: int = CONST_MAX_HP
@export var friction: int = 250 # decrease to cause sliding
@export var acceleration = CONST_ACCELERATION
@export var max_speed = CONST_STARTING_SPEED

@onready var health_bar = $Healthbar
@onready var radial = $TextureProgressBar
@onready var progress = $ProgressBar
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var mov_direction: Vector2 = Vector2.ZERO
@onready var FSM = $FSM
@onready var userlabel = $Label
@onready var weapon = $Weapon
@onready var spellbook = $Spellbook

@onready var Network = get_tree().get_root().get_node('/root/Main/Network')

var evade_timer = Timer.new()
var is_invincible = false	

# TODO: UI, weapon swapz
var UI = load("res://UI/UI.tscn")
var UIref = null

var PlayerLight = preload("res://Player/PlayerLight.tscn")

var mouse_direction: Vector2

const RESPAWN_RADIUS = 70
var PLAYER_START: Vector2 = Vector2(-5, -35)

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
	var newUI = UI.instantiate()
	var newCamera = Camera2D.new()
	var newLight = PlayerLight.instantiate()

	userlabel.text = SavedData.username
	newCamera.ignore_rotation = true
	newCamera.limit_smoothed = true
	add_child(newCamera)
	add_child(evade_timer)
	add_child(newUI)
	add_child(newLight)
	UIref = get_node("UI")
	restore_previous_state()
	animated_sprite.set_modulate(Network.player_info.color)


func is_player():
	return true
	
var shift = false
	
@onready var sprint_timer = $SprintTimer

func sprint():
	shift = true
	sprint_timer.start()
	await sprint_timer.timeout
	acceleration = CONST_ACCELERATION * 1.8
	max_speed = CONST_STARTING_SPEED * 1.05
	friction = CONST_FRICTION * 1.5
		
func cancel_sprint():
	shift = false
	sprint_timer.stop()
	acceleration = CONST_ACCELERATION
	max_speed = CONST_STARTING_SPEED
	friction = CONST_FRICTION

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	# if Input.is_action_pressed("shift") and shift == false:
		# sprint()
	
	# if Input.is_action_just_released("shift") and shift == true:
		# cancel_sprint()
		
	if mov_direction != Vector2.ZERO:
		velocity = velocity.move_toward(mov_direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	if is_on_wall():
		velocity = velocity.move_toward(mov_direction * max_speed * 0.9, (acceleration * 1.05) * delta)

	move_and_slide()

	
func _process(_delta: float) -> void:
	# if OS.is_debug_build(): userlabel.text = FSM.current_state.name
	if not is_multiplayer_authority(): return
	mouse_direction = (get_global_mouse_position() - global_position).normalized()
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	# NOTE: maybe have a node that mounts the timers and UI? 
	# the UI node would be persistent, that way it's _process
	# can be used instead of crowding up the Player one.
	if not evade_timer.is_stopped():
		radial.value = 	evade_timer.time_left * 100

func set_state(state):
	# userlabel.text = state
	FSM.on_child_transition(FSM.current_state, state)

func move() -> void:
	pass

	
# take_damage should set state: hurt
func take_damage(damage: int, knockback: int, direction: Vector2, source) -> void:
	if not is_multiplayer_authority(): return
	if is_invincible == false:
		set_state('PlayerHurt')
		$StatusFeedback/Label.text = "%s" % damage
		$StatusFeedback/AnimationPlayer.play("show_number")
		hp -= damage
		health_bar.value = hp
		health_bar.visible = true
		velocity += direction * knockback
		# TODO: keep a log of most recent damage, clear it ~10 seconds
		# Credit the one with the most damage in last 5-10 seconds
		if (hp <= 0):
			Network._on_player_scored.rpc(source)

func apply_slow(_factor = 10):
	if _factor != 0:
		max_speed = CONST_STARTING_SPEED / _factor
	
func remove_slow():
	max_speed = CONST_STARTING_SPEED
	acceleration = CONST_ACCELERATION

func restore_previous_state() -> void:
	if not is_multiplayer_authority(): return
	# TODO: Better "respawn" logic
	hp = CONST_MAX_HP
	max_speed = CONST_STARTING_SPEED
	health_bar.max_value = CONST_MAX_HP
	health_bar.value = CONST_MAX_HP
	set_state("PlayerIdle")
	if self.name == str(1):
		PLAYER_START = Vector2.ZERO
	if randi() % 2 == 0:
		position = Vector2(PLAYER_START.x + randf() * RESPAWN_RADIUS, PLAYER_START.y + randf() * RESPAWN_RADIUS)
	else:
		position = Vector2(PLAYER_START.x - randf() * RESPAWN_RADIUS, PLAYER_START.y - randf() * RESPAWN_RADIUS)

func _unhandled_input(_event):
	if OS.is_debug_build():
		if Input.is_action_just_pressed("escape"):
			get_tree().quit()
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("escape"):
		if OS.is_debug_build():
			get_tree().quit()
		else:
			pass

# Reduce boilerplate by abstracting instances of "attack1"
# TODO: use just released, for charging!
func attack():
	if Input.is_action_just_pressed("left_click"):
		set_state('PlayerAttack1')
	elif Input.is_action_just_pressed("right_click"):
		set_state('PlayerAttack2')
	elif Input.is_action_just_pressed('f'):
		set_state('PlayerSpell1')

func activate():
	if Input.is_action_just_pressed("e"):
		set_state('PlayerBusy')

func evade():
	if Input.is_action_just_pressed("space") and evade_timer.is_stopped():
		set_state('PlayerEvade')
	elif Input.is_action_just_pressed("space"):
		radial.visible = true
		await get_tree().create_timer(1.4).timeout
		radial.visible = false

# TODO: Improve saftey. Check weapon length to make sure it's present.
func change_weapon():
	if Input.is_action_just_pressed("1"):
		weapon.set_weapon(0)
		UIref.set_weapon(0)
		set_state("PlayerBusy")
	if Input.is_action_just_pressed("2"):
		weapon.set_weapon(1)
		UIref.set_weapon(1)
		set_state("PlayerBusy")
	if Input.is_action_just_pressed("3"):
		weapon.set_weapon(2)
		UIref.set_weapon(2)
		set_state("PlayerBusy")
	if Input.is_action_just_pressed("4"):
		weapon.set_weapon(3)
		UIref.set_weapon(3)
		set_state("PlayerBusy")


func get_input() -> void:
	if not is_multiplayer_authority(): return
	mov_direction = Vector2.ZERO
	mov_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	mov_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	mov_direction = mov_direction.normalized()

func interact():
	# Look for interactable bodies,
	# pick closest
	pass

func _on_area_2d_area_entered(area: Area2D):
	# IMPORTANT.
	# prevents self damage.
	if area.get_multiplayer_authority() == get_multiplayer_authority():
		return
	
	if "player_id" in area.get_parent():
		var spell = area.get_parent()
		if spell.player_id != get_multiplayer_authority() and spell.player_id != 0:
			take_damage(spell.damage, spell.knockback, spell.direction, spell.player_id)
			spell.destroy()

	if "weapon_ref" in area and area.weapon_ref != null:
		var hit: Hit = area.weapon_ref.get_weapon_hit()
		if hit.damage > 0: take_damage(hit.damage, hit.knockback, hit.angle, area.get_multiplayer_authority())
		
