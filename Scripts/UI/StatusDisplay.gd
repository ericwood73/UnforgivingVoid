extends Control


func update_state(state):
	$VBoxContainer/GridContainer/RollRateDisplay.text = String(state.rate.x)
	$VBoxContainer/GridContainer/YawRateDisplay.text = String(state.rate.y)
	$VBoxContainer/GridContainer/PitchRateDisplay.text = String(state.rate.z)
	$VBoxContainer/GridContainer2/RelativeXVelocityDisplay.text = String(state.relative_velocity.x)
	$VBoxContainer/GridContainer2/RelativeYVelocityDisplay.text = String(state.relative_velocity.y)
	$VBoxContainer/GridContainer2/RelativeZVelocityDisplay.text = String(state.relative_velocity.z)
	$VBoxContainer/GridContainer2/XDistanceDisplay.text = String(state.distance.x)
	$VBoxContainer/GridContainer2/YDistanceDisplay.text = String(state.distance.y)
	$VBoxContainer/GridContainer2/ZDistanceDisplay.text = String(state.distance.z)
