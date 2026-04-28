extends RigidBody2D

const gravity : float = 9.8
const aerialDrag := Vector2(0.999,0.98)
const terminalVelocity := (gravity * aerialDrag.y) / (1 - aerialDrag.y) 
signal groundContactVelocity(x)

const groundSpeed : float = 400
const friction : float = 0.1 * 60
const dashSpeed : float = 1000

signal dashPressed
@onready var dashTimer : Timer = $dashTimer

var groundVelocity : Vector2 # groundVelocity.y acts as the bounce retention

func _ready() -> void:
	groundContactVelocity.connect(_bounceCalculation)
	dashPressed.connect(_bounceCalculations)
	

var onFloor : bool
func _onFloorCheck(state: PhysicsDirectBodyState2D) :
	for i in state.get_contact_count() :
		var contact_norm = state.get_contact_local_normal(i)
		if contact_norm.y == -1 :
			# Announce if just landed with velocity of landing
			var contact_impulse = state.get_contact_impulse(i)
			if contact_impulse != Vector2.ZERO :
				groundContactVelocity.emit(contact_impulse)
			# Return True if contacting floor
			return true
	return false

var onWall : bool
func _onWallCheck(state: PhysicsDirectBodyState2D) :
	for i in state.get_contact_count() :
		var contact_norm = state.get_contact_local_normal(i)
		if abs(contact_norm.x) == 1 :
			return true
	return false

func _bounceCalculation(bounce : Vector2) : 
	if -bounce.y > terminalVelocity : 
		groundVelocity.y = -bounce.y

func _dashCalc()  : 
	var normalisedInputVector = Global.inputVector.normalized()
	if Global.inputVector.x == linear_velocity.x / abs(linear_velocity.x) : 
		normalisedInputVector.x += dashSpeed
	else :
		normalisedInputVector.x = dashSpeed
	if Global.inputVector.y == linear_velocity.y / abs(linear_velocity.y) : 
		normalisedInputVector.y += dashSpeed
	else : 
		normalisedInputVector.y = dashSpeed


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	onFloor = _onFloorCheck(state)
	onWall = _onWallCheck(state)
	if !onFloor :
		linear_velocity.y += gravity
		linear_velocity.y *= aerialDrag.y
	
func _physics_process(delta: float) -> void:
	if onFloor :
		# Write to the Grounded Momentum
		groundVelocity.x = linear_velocity.x
		#if linear_velocity.y > terminalVelocity :
		linear_velocity.x = lerp(linear_velocity.x,groundSpeed*Global.inputVector.x,friction*delta)
	
	
	# Walking
	
