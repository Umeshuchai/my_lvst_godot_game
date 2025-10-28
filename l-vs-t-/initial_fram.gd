extends Node2D
@onready var pvp_btn=$pvp_btn/btn
@onready var play_img=$pvp_btn
@onready var play_sound=$play_sound
@onready var sound_btn=$SettingLogo/menulayer/menu/SoundSetting/Button
@onready var sound_off_img=$SettingLogo/menulayer/menu/SoundSetting/SoundOff
@onready var sound_on_img=$SettingLogo/menulayer/menu/SoundSetting/SoundOn
@onready var blur_rect=$SettingLogo/menulayer/blur_rect
@onready var setting_menu=$SettingLogo/menulayer/menu
var turn_on=true
var mode_menu_open
@onready var setting_btn=$SettingLogo/Button
@onready var ok_btn=$SettingLogo/menulayer/menu/Okimg/Button
@onready var Mode_btn=$SettingLogo/menulayer/menu/Board/Button
@onready var closed_sign=$SettingLogo/menulayer/menu/Board/ClosedMenu
@onready var opened_sign=$SettingLogo/menulayer/menu/Board/OpenedMenu
@onready var fxf_img=$SettingLogo/menulayer/menu/Board/mode_menu/Five
@onready var sxs_img=$SettingLogo/menulayer/menu/Board/mode_menu/Seven
@onready var tk_f_img=$SettingLogo/menulayer/menu/Board/mode_menu/Five/tick_img
@onready var tk_s_img=$SettingLogo/menulayer/menu/Board/mode_menu/Seven/tick_img
func _ready():
	sound_off_img.visible=false
	sound_on_img.visible=true
	pvp_btn.pressed.connect(pvp_play)
	sound_btn.pressed.connect(sound_change)
	setting_btn.pressed.connect(setting)
	ok_btn.pressed.connect(ok)
	Mode_btn.pressed.connect(Mode)
	$pvc_btn/btn.pressed.connect(pvc_play)
	select_mode()

func sound_change():
	btn_press_animation(1,sound_btn.get_parent())

func btn_press_animation(process_no,img):
	if not img.has_meta("initial_scale"):
		img.set_meta("initial_scale", img.scale)
	var initial_scale = img.get_meta("initial_scale")
	if img.has_meta("active_tween"):
		var old_tween = img.get_meta("active_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	var new_scale=initial_scale*1.1
	var tween=create_tween()
	play_sound.play()
	tween.tween_property(img,"scale",new_scale,0.15)
	tween.tween_interval(0.05)
	tween.tween_property(img,"scale",initial_scale,0.15)
	tween.finished.connect(func():
		if process_no==0:
			get_tree().change_scene_to_file("res://gamemanager.tscn")
		elif process_no==1:
			if turn_on:
				sound_off_img.visible=true
				sound_on_img.visible=false
				turn_on=false
			else:
				sound_off_img.visible=false
				sound_on_img.visible=true
				turn_on=true
		elif process_no==2:
			blur_rect.visible=false
			setting_menu.visible=false
		elif process_no==3:
			if mode_menu_open:
				closed_sign.visible=false
				opened_sign.visible=true
				fxf_img.get_parent().visible=true
				mode_menu_open=false
			else:
				closed_sign.visible=true
				opened_sign.visible=false
				fxf_img.get_parent().visible=false
				mode_menu_open=true
	)
	if process_no==2:
		tween.tween_property(setting_btn.get_parent(),"rotation_degrees",-60,0.4)

func setting():
	var tween=create_tween()
	var stl=setting_btn.get_parent()
	tween.tween_property(stl,"rotation_degrees",60,0.4)
	await get_tree().create_timer(0.4).timeout
	blur_rect.visible=true
	setting_menu.visible=true
	mode_menu_open=true
	closed_sign.visible=true
	opened_sign.visible=false
	fxf_img.get_parent().visible=false

func ok():
	if blur_rect.visible and setting_menu.visible:
		btn_press_animation(2,ok_btn.get_parent())

func Mode():
	btn_press_animation(3,Mode_btn.get_parent())

func select_mode():
	tk_f_img.visible=true
	tk_s_img.visible=false
	Globaldata.board_size=5
	tk_f_img.get_parent().get_node("Button").pressed.connect(func():
		tk_f_img.visible=true
		tk_s_img.visible=false
		Globaldata.board_size=5
		btn_press_animation(4,tk_f_img.get_parent())
		)
	tk_s_img.get_parent().get_node("Button").pressed.connect(func():
		tk_f_img.visible=false
		tk_s_img.visible=true
		Globaldata.board_size=7
		btn_press_animation(4,tk_s_img.get_parent())
		)

func pvc_play():
	Globaldata.switeched_to_bot_mode=true
	btn_press_animation(0,$pvc_btn)

func pvp_play():
	btn_press_animation(0,play_img)
	Globaldata.switeched_to_bot_mode=false
#func store_profile_data_of_player():
	
