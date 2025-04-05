class_name VolumeSliders
extends VBoxContainer
@onready var master_slider: HSlider = $Master/HBoxContainer/HSlider
@onready var music_slider: HSlider = $Music/HBoxContainer/HSlider
@onready var sfx_slider: HSlider = $SFX/HBoxContainer/HSlider

func _ready() -> void:
	master_slider.value = SaveLoad.settings.master_volume * 100
	music_slider.value = SaveLoad.settings.music_volume * 100
	sfx_slider.value = SaveLoad.settings.sfx_volume * 100
	master_slider.value_changed.connect(on_slider_changed.bind("Master"))
	music_slider.value_changed.connect(on_slider_changed.bind("Music"))
	sfx_slider.value_changed.connect(on_slider_changed.bind("Sfx"))
	
func on_slider_changed(new_value: float, slider: String):
	var value = new_value / 100
	match slider:
		"Master":
			SaveLoad.settings.master_volume = value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(SaveLoad.settings.master_volume))
		"Music":
			SaveLoad.settings.music_volume = value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(SaveLoad.settings.master_volume))
		"Sfx": 
			SaveLoad.settings.sfx_volume = value
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(SaveLoad.settings.master_volume))

	SaveLoad.save_settings()
