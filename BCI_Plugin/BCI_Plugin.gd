tool
extends EditorPlugin

var plugin = load("res://addons/BCI_Plugin/InspectorPlugin.gd")

func _enter_tree():
	plugin = plugin.new()
	add_inspector_plugin(plugin)


func _exit_tree():
	remove_inspector_plugin(plugin)
