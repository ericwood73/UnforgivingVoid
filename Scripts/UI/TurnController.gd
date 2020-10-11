extends Control

export var seconds_per_turn = 10

signal time_updated(time)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Container/TimeSlider.tick_count = seconds_per_turn
	$Container/TimeSlider.min_value = 0
	$Container/TimeSlider.max_value = seconds_per_turn - 1



func _on_TimeSlider_released():
	emit_signal("time_updated", $Container/TimeSlider.value)
