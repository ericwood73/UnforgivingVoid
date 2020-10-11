extends Reference

# A class for respresenting data associated with 6 degress of freedom, i.e.
# pitch yaw, roll, vertical, lateral, and axial
class_name SixDOF

var _data = {
	pitch = 0,
	roll = 0,
	yaw = 0,
	vertical = 0,
	lateral = 0,
	axial = 0
}

func clone():
	var clone = get_script().new()
	clone._data = _data.duplicate()
	return clone

func pitch(value := NAN): 
	if !is_nan(value):
		_data.pitch = value
	return _data.pitch
	
func yaw(value := NAN): 
	if !is_nan(value):
		_data.yaw = value
	return _data.yaw
	
func roll(value := NAN): 
	if !is_nan(value):
		_data.roll = value
	return _data.roll
	
func vertical(value := NAN): 
	if !is_nan(value):
		_data.vertical = value
	return _data.vertical
	
func lateral(value := NAN): 
	if !is_nan(value):
		_data.lateral = value
	return _data.lateral
	
func axial(value := NAN): 
	if !is_nan(value):
		_data.axial = value
	return _data.axial
	
func set(axis, value):
	_data[axis] = value
	
func as_dictionary():
	return _data.duplicate()
	
#func update_from(other_sixdof):
#	data = other_sixdof.data.duplicate()
#	data.pitch = other_sixdof.pitch()
#	data.yaw = other_sixdof.yaw()
#	data.roll = other_sixdof.roll()
#	data.vertical = other_sixdof.vertical()
#	data.lateral = other_sixdof.lateral()
#	data.axial = other_sixdof.axial()
	
