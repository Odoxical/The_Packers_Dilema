extends Node2D

var visibility = 0

func _on_ready():
	preload("res://audio_stream_player.gd")


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Main_Menu.tscn")

#Visibility toggle
func _on_slider_visibility_pressed() -> void:
	if $Buttonsize.visible == false:
		$Buttonsize.visible = true
	else:
		$Buttonsize.visible = false
	if $Buttonsize/TextEdit.visible == false:
		$Buttonsize/TextEdit.visible = true
	else:
		$Buttonsize/TextEdit.visible = false

func _on_buttonsize_drag_ended(value_changed: bool) -> void:
	$SliderVisibility.scale = Vector2($Buttonsize.value,$Buttonsize.value)

func _on_font_size_slider_drag_started() -> void:
	$"Main text".Vector2($"Font Size Slider".value,0)

func _on_music_pressed():
	get_tree().music_player.play
