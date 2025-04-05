class_name Menu extends Control

@export var _defaul_grab_focus : Control
var _breadcrumb : Menu

func open(breadcrumb : Menu = null) -> void:
	if breadcrumb:
		_breadcrumb = breadcrumb
		breadcrumb.close()
	visible = true
	if _defaul_grab_focus:
		_defaul_grab_focus.grab_focus()
 
 
func close() -> void:
	visible = false
	if _breadcrumb:
			_breadcrumb.open()
			_breadcrumb = null
 
