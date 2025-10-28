extends Control
@onready var resume_btn=$Resume/Button
@onready var mainmenu_btn=$MainMenu/Button
@onready var restart_btn=$Restart/Button
@onready var btn_sound=$Btn_sound
@onready var resume_img=$Resume
@onready var mainmenu_img=$MainMenu
@onready var restart_img=$Restart

# enables all buttons in current codition if disabled
func enable_btns():
	var parent=get_parent().get_parent()
	for btn in parent.tiger_btn:
		btn.disabled=false
	for btn in parent.lion_btn:
		btn.disabled=false
	for btn in parent.around_btn:
		if is_instance_valid(btn):
			btn.disabled=false

#for popup UI of pause button
func btn_press_animation(function_value,img):
	btn_sound.stream=preload("res://sounds/button-press-sound.mp3")
	var main_layer=resume_btn.get_parent().get_parent().get_parent()
	var blur_layer=main_layer.get_parent().get_node("BlurLayer/blur_rect")
	var tween=create_tween()
	var initial_scale=img.scale
	var new_scale=img.scale*1.1
	btn_sound.play()
	tween.tween_property(img,"scale",new_scale,0.15)
	tween.tween_interval(0.05)
	tween.tween_property(img,"scale",initial_scale,0.15)
	tween.finished.connect(func():
		if function_value==1:
			main_layer.visible=false
			blur_layer.visible=false
			enable_btns()
		elif function_value==2:
			main_layer.visible=false
			blur_layer.visible=false
			var parent=get_parent().get_parent()
			parent._ready()
		elif function_value==3:
			get_tree().change_scene_to_file("res://initial_frame.tscn")
		)

func _ready():
	resume_btn.pressed.connect(func():
		btn_press_animation(1,resume_img)
		)
	restart_btn.pressed.connect(func():
		btn_press_animation(2,restart_img)
		)
	mainmenu_btn.pressed.connect(func():
		btn_press_animation(3,mainmenu_img)
		)
