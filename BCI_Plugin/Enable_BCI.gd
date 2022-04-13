tool
extends EditorProperty
class_name Enable_BCI

var checkbox = CheckBox.new()

var edited_control = null
var has_refreshed = false
var _checked = false
var _Script  = load("res://addons/BCI_Plugin/Flash_node_Script.gd")

var data = []
#func _print_data():
#	print(data)
#
#func _update_data(value):
#	data.append(value)

#initializes the 
func _init():
	_add_checkbox()
	
	
#_add_checkbox
#adds the checkbox to enable and disable BCI 
#connects the checkbox to the "toggled" signal
#when a toggled signal is emited then _on_checkbox_checked is called on self
#adds the checkbox to sidebar
func _add_checkbox():
	label = "Enable BCI"
	checkbox.connect("toggled", self, "_on_checkbox_checked")
	add_child(checkbox)

func _on_checkbox_checked(is_checked):
	_checked = true
	edited_control = get_edited_object()
	if is_checked:
		emit_changed("BCI_Enabled", is_checked)
		set_physics_process(is_checked)
		edited_control.set_script(_Script)
		checkbox.set_pressed(true)
	else:
		checkbox.set_pressed(false)
		set_physics_process(is_checked)
		edited_control.set_script(null)
		checkbox.set_pressed(false)
		
		
func update_property():
	if !has_refreshed:
		has_refreshed = true
		edited_control = get_edited_object()
		if edited_control.get_script() == _Script:
			checkbox.set_pressed(true)
	else:
		checkbox.set_pressed(_checked)


				
