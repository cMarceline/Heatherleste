extends RigidBody2D

const maxSpeed : float = 400
const friction : float = 0.2 * 60
const dashSpeed : float = 500

@onready var dashTimer : Timer = $dashTimer

@export var groundSpeed : Vector2
var onFloor : bool

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for contacts in state.get_contact_count() :
		print(state.get_contact_local_normal(contacts))

	linear_velocity.x = groundSpeed.x
	pass

func _physics_process(delta: float) -> void:
	pass
	groundSpeed.x = lerp(groundSpeed.x, float(maxSpeed * Global.inputVector.x), friction*delta)
	# Walking
	
