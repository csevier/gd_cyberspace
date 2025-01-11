tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("link", "Node", preload("link.gd"), preload("link.svg"))
	add_autoload_singleton("link_server", "res://addons/gd_cyberspace/link_server.gd")


func _exit_tree():
	remove_custom_type("link")
	remove_autoload_singleton("link_server")
