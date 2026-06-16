extends Node

# This function creates a timer that can be awaited in async functions. It takes an optional parameter for the number of seconds to wait, defaulting to 1 second if not provided.
func wait(seconds: float = 1.0):
	return get_tree().create_timer(seconds).timeout


# This function converts a movement direction vector into a string representing the cardinal direction (up, down, left, right). 
# It checks the components of the vector to determine the dominant direction and returns the corresponding string.
func movement_direction_to_string(direction: Vector2) -> String:
	if direction == Vector2.ZERO:
		return ""


	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			return "right"
		else:
			return "left"
	else:
		if direction.y > 0:
			return "down"
		else:
			return "up"
