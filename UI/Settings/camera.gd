extends VBoxContainer
@onready var sensititvity_slider: HSlider = $Sensitivity/HBoxContainer/HSlider
@onready var invert_x_button: CheckButton = $InvertX/HBoxContainer/CheckButton
@onready var invert_y_button: CheckButton = $InvertY/HBoxContainer/CheckButton

func _ready() -> void:
	sensititvity_slider.value = SaveLoad.settings.camera_sensitivity * 1000
	invert_x_button.button_pressed = SaveLoad.settings.camera_invert_x
	invert_y_button.button_pressed = SaveLoad.settings.camera_invert_y
	invert_x_button.toggled.connect(on_button_toggled.bind("invert_x"))
	invert_y_button.toggled.connect(on_button_toggled.bind("invert_y"))
	sensititvity_slider.value_changed.connect(on_slider_changed)
	
func on_slider_changed(new_value: float):
	SaveLoad.settings.camera_sensitivity = new_value / 1000
	SaveLoad.save_settings()
	pass

func on_button_toggled(state: bool, button_name: String):
	if button_name == "invert_x":
		SaveLoad.settings.camera_invert_x = state
	else:
		SaveLoad.settings.camera_invert_y = state
	SaveLoad.save_settings()
