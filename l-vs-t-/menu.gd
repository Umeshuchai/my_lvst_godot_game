extends Control
@onready var resume_btn=$Resume/Button
@onready var mainmenu_btn=$Resign/Button
@onready var restart_btn=$Restart/Button
@onready var btn_sound=$"../../Btn_sound"
@onready var resume_img=$Resume
@onready var mainmenu_img=$Resign
@onready var restart_img=$Restart
var blur_layer

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
func btn_press_animation(function_value,img,label):
	if not img.has_meta("initial_scale"):
		img.set_meta("initial_scale", img.scale)
	var initial_scale = img.get_meta("initial_scale")
	if img.has_meta("active_tween"):
		var old_tween = img.get_meta("active_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	img.scale = initial_scale
	var tween=create_tween()
	var new_scale=img.scale*1.1
	btn_sound.play()
	tween.tween_property(img,"scale",new_scale,0.15)
	tween.tween_interval(0.05)
	tween.tween_property(img,"scale",initial_scale,0.15)
	tween.finished.connect(func():
		if function_value==0:
			pass
		elif function_value==1:
			blur_layer.visible=false
			if label!="tiger_win_lable":
				visible=false
			enable_btns()
		elif function_value==2:
			blur_layer.visible=false
			if label!="tiger_win_lable":
				visible=false
			var parent=get_parent().get_parent()
			parent._ready()
		elif function_value==3:
			get_tree().change_scene_to_file("res://initial_frame.tscn")
		)
	await tween.finished

func _ready():
	blur_layer=get_parent().get_node("blur_rect")
	resume_btn.pressed.connect(func():
		btn_press_animation(1,resume_img,"pause_menu")
		)
	restart_btn.pressed.connect(func():
		restart_btn.disabled=true
		btn_press_animation(2,restart_img,'pause_menu')
		restart_btn.disabled=false
		)
	mainmenu_btn.pressed.connect(func():
		btn_press_animation(3,mainmenu_img,'pause_menu')
		)
