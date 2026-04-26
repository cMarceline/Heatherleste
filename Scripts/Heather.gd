extends RigidBody2D

const gravity : float = 9.8
const maxSpeed : float = 400
const friction : float = 0.1 * 60
const dashSpeed : float = 1000
const aerialDrag := Vector2(0.999,0.98)

@onready var dashTimer : Timer = $dashTimer

var groundSpeed : Vector2 #groundSpeed.y acts as the bounce retention
var airTrajectory : Vector2

var onFloor : bool
func _onFloorCheck(state: PhysicsDirectBodyState2D) :
	for i in state.get_contact_count() :
		var contact_norm = state.get_contact_local_normal(i)
		print(state.get_contact_impulse(i))
		if contact_norm.y == -1 :
			return true
	return false

var onWall : bool
func _onWallCheck(state: PhysicsDirectBodyState2D) :
	for i in state.get_contact_count() :
		var contact_norm = state.get_contact_local_normal(i)
		if abs(contact_norm.x) == 1 :
			return true
	return false


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	onFloor = _onFloorCheck(state)
	onWall = _onWallCheck(state)
	
	if !dashTimer.is_stopped: 
		pass
	
	if onFloor :
		linear_velocity = groundSpeed + airSpeed + dashSpeed
		#launchTrajectory.y = lerp()

	
	print(onFloor)
	
func _physics_process(delta: float) -> void:
	if !dashTimer.is_stopped: 
		pass

	if Global.inputDash : 
		linear_velocity = Global.inputVector.normalized() * dashSpeed

	if !onFloor :
		linear_velocity.y += gravity
		linear_velocity *= aerialDrag

	if onFloor :
		groundSpeed.x = lerp(groundSpeed.x, float(maxSpeed * Global.inputVector.x), friction*delta)
		linear_velocity.y += -400 * int(Global.inputJump)
		
	
	
	# Walking
	
