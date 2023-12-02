extends Area2D

var weapon_ref = null
var collision_ref = null

# TODO: This could hold dummy func like get_weapon_hit(), so we don't have to look at the ref.

func _ready():
	# This could be useful to get the collision shape if needed for a signal
	
	#for child in get_children():
	#	if child is CollisionShape2D or child is CollisionPolygon2D:
	#		collision_ref = child
	
	# The one signal we care about on Area2D. 
	# A refactor could detect entering another player to _perform_ damage
	self.connect('area_entered', weapon_ref_collision)
	
	# This is for spawning hit "X" or ticks for damage if needed.
	# not used.
	# self.connect('area_exited', weapon_area_exited)
	
enum Status {STUN, BURN}
# when two weapons collide.
func weapon_ref_collision(incoming_area):

	# ignore self owned collisions (prevents self damage)
	if incoming_area.get_multiplayer_authority() == get_multiplayer_authority():
		# do nothing
		return
	if 'weapon_ref' in incoming_area:
		if incoming_area.name == 'Shield':
			weapon_ref.animation_player.call_deferred('stop')
			weapon_ref.player.apply_status(Status.STUN, 2)

func weapon_area_exited(exiting_area):
	if exiting_area.get_multiplayer_authority() == get_multiplayer_authority():
		# do nothing, prevent self damage
		return
	# we caused damage, play a sound
	if 'is_player' in exiting_area.get_parent():
		if exiting_area.get_parent().FSM.current_state.name == 'PlayerHurt':
			pass

