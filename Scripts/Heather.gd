extends RigidBody2D

const jumpSpeed : float = 400
const gravity : float = 9.8 * 60
const aerialDrag := Vector2(0.98,0.98) * 60
const terminalVelocity := (gravity * aerialDrag.y) / (1 - aerialDrag.y) 
signal groundContactVelocity(x)

const groundSpeed : float = 400
const friction : float = 0.1 * 60
const dashSpeed : float = 1000
var velocitySign : Vector2 :
	get : return linear_velocity.sign()

@onready var dashTimer : Timer = $dashTimer

var groundVelocity : Vector2 # groundVelocity.y acts as the bounce retention

func _ready() -> void:
	groundContactVelocity.connect(_bounceCalculation)
	Global.dashPressed.connect(_dashCalc)
	Global.jumpPressed.connect(_jumpCalc)

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
	bounce.x -= linear_velocity.x
	if bounce.y < terminalVelocity : 
		groundVelocity.y = -bounce.y - terminalVelocity

func _jumpCalc() : 
	if !onFloor : return
	print(groundVelocity.y)
	linear_velocity.y -= jumpSpeed + groundVelocity.y

func _dashCalc()  : 
	var normalisedInputVector = Global.inputVector.normalized()
	if normalisedInputVector == Vector2.ZERO :
		return
	if Global.inputVector.x == velocitySign.x : 
		linear_velocity.x += dashSpeed * normalisedInputVector.x
	else :
		linear_velocity.x = dashSpeed * normalisedInputVector.x
	if Global.inputVector.y == velocitySign.y : 
		linear_velocity.y += dashSpeed * normalisedInputVector.y
	else : 
		linear_velocity.y = dashSpeed * normalisedInputVector.y

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	onFloor = _onFloorCheck(state)
	onWall = _onWallCheck(state)
	if Global.inputDash : 
		Global.dashPressed.emit()
	if Global.inputJump : 
		Global.jumpPressed.emit()

func _physics_process(delta: float) -> void:
	if onFloor :
		# Write to the Grounded Momentum
		groundVelocity.x = linear_velocity.x
		linear_velocity.x = round(lerp(linear_velocity.x,groundSpeed*Global.inputVector.x,friction*delta))
		groundVelocity.y = round(lerp(groundVelocity.y,0.0,friction*delta))
		#print(linear_velocity)
		
	if !onFloor :
		linear_velocity.y += gravity * delta
		linear_velocity.y *= aerialDrag.y * delta
		#linear_velocity.x += gravity * Global.inputVector.x * delta
		#if Global.inputVector.x != velocitySign.x : 
		#	linear_velocity.x *= aerialDrag.x

	
	
	# Walking
	
