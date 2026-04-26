extends Node

var inputVector : Vector2 :
	get: return Vector2(
		Input.get_action_raw_strength("Right") - Input.get_action_raw_strength("Left"),
		Input.get_action_raw_strength("Down") - Input.get_action_raw_strength("Up")
	)

var inputJump : bool : 
	get : return Input.get_action_raw_strength("Jump")
	
var inputDash : bool :
	get : return Input.is_action_just_pressed("Dash")
