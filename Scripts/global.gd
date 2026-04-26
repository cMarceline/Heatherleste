extends Node

var inputVector : Vector2 :
	get: return Vector2(
		Input.get_action_raw_strength("Right") - Input.get_action_raw_strength("Left"),
		Input.get_action_raw_strength("Up") - Input.get_action_raw_strength("Down")
	)
