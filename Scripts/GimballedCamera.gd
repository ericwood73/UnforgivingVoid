extends Spatial
class_name GimballedCamera

export var MIN_DISTANCE = 2
export var MAX_DISTANCE = 10
export var CAMERA_SPEED = 2
export var ZOOM_SPEED = 2
export var CHANGE_TARGET_DURATION = 1

signal camera_target_transition_complete

var current_target

func _ready():
	# Set camera distance to minimum
	$YawGimbal/PitchGimbal/Camera.translation.z = MIN_DISTANCE

func _process(delta):
	# Yaw movement
	if (Input.is_action_pressed("camera_left") and !Input.is_action_pressed("camera_right")):
		$YawGimbal.rotate_y(CAMERA_SPEED*delta)
	if (Input.is_action_pressed("camera_right") && !Input.is_action_pressed("camera_left")):
		$YawGimbal.rotate_y(-CAMERA_SPEED*delta)
	
	# Pitch movement
	if (Input.is_action_pressed("camera_up") and !Input.is_action_pressed("camera_down")):
		$YawGimbal/PitchGimbal.rotate_x(CAMERA_SPEED*delta)
	if (Input.is_action_pressed("camera_down") && !Input.is_action_pressed("camera_up")):
		$YawGimbal/PitchGimbal.rotate_x(-CAMERA_SPEED*delta)	
	
	# Zoom
	if (Input.is_action_pressed("camera_zoom_in") and !Input.is_action_pressed("camera_zoom_out")):
		var updated_z = $YawGimbal/PitchGimbal/Camera.translation.z - (ZOOM_SPEED * delta)
		$YawGimbal/PitchGimbal/Camera.translation.z = max(updated_z, MIN_DISTANCE)
	if (Input.is_action_pressed("camera_zoom_out") && !Input.is_action_pressed("camera_zoom_in")):
		var updated_z = $YawGimbal/PitchGimbal/Camera.translation.z + (ZOOM_SPEED * delta)
		$YawGimbal/PitchGimbal/Camera.translation.z = min(updated_z, MAX_DISTANCE)	
			
func update_target(target):
	print("Updating target for camera: " + str(target))
	current_target = target
	$Tween.interpolate_property(self, "translation", global_transform.origin,
								target.global_transform.origin, CHANGE_TARGET_DURATION, 
								Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	get_parent().remove_child(self)
	translation = Vector3(0, 0, 0)
	current_target.add_child(self)
	print("Target updated")
	emit_signal("camera_target_transition_complete")
	
	
