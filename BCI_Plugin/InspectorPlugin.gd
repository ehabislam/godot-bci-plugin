extends EditorInspectorPlugin

func can_handle(object):
	return object is Control
	
func parse_begin(object):
	var enableBCI = Enable_BCI.new()
	add_property_editor("EnableBCI", enableBCI)

