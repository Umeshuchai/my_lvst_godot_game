extends Node2D
@onready var collision_sound=$collision_sound
@onready var pause_btn=$PauseButton/Button
@onready var token_move_sound=$token_move_sound
@onready var menu=$MenuLayer/Menu
var pos_init_x:int
var pos_init_y:int
var tkn_scale
var btn_size
var box_size:float
var tiger=[]
var lion=[]
var tiger_btn=[]
var lion_btn=[]
var around_btn=[]
var selected_tiger:int =-1
var selected_lion:int=-1
var btn_pos_diff
var pos=[]
var pos_const:int 
var selected_around_btn:int=-1
var token_move_duration=0.2
var tiger_move=true
var lion_move=true
var token_moved=false
@onready var sxs_board=$Board_sxs
@onready var fxf_board=$Board_fxf
@onready var tiger_win_label=$MenuLayer/tiger_win_label
@onready var lion_win_label=$MenuLayer/lion_win_label
var Tc1_pos_init
var Tc2_pos_init
var Lc1_pos_init
var Lc2_pos_init
@onready var bot_player =$bot_player_node


func set_scaling_values():
	if Globaldata.board_size==5:
		pos_init_x=50
		pos_init_y=430
		tkn_scale=0.08
		btn_size=70
		box_size=154.4
		btn_pos_diff=Vector2(32,20)
	elif Globaldata.board_size==7:
		pos_init_x=49.4
		pos_init_y=430
		tkn_scale=0.0725
		btn_size=49
		box_size=103.45
		btn_pos_diff=Vector2(23,15)

#sets positions to variables
func set_positions():
	for pos_const in range(Globaldata.board_size*Globaldata.board_size):
		pos.append(Vector2(pos_init_x+(pos_const-(pos_const/Globaldata.board_size)*Globaldata.board_size)*box_size,pos_init_y+(pos_const/Globaldata.board_size)*box_size))
#loads tigers and lions at initially
func load_token():
	#loads tiger
	if Globaldata.board_size==5:
		for i in range(5):
			var img = preload("res://assets/tiger.png")  
			var sprite = Sprite2D.new()
			tiger.append(sprite)
			tiger[i].texture = img
			tiger[i].scale = Vector2(tkn_scale,tkn_scale)  
			if i<3:
				tiger[i].position=Vector2(pos_init_x+2*i*box_size,pos_init_y)
			if i>=3:
				tiger[i].position=Vector2(pos_init_x+(2*i-5)*box_size,pos_init_y+4*box_size)
			add_child(sprite)
	else:
		for i in range(7):
			var img=preload("res://assets/tiger.png")
			var sprite=Sprite2D.new()
			tiger.append(sprite)
			tiger[i].texture=img
			tiger[i].scale=Vector2(tkn_scale,tkn_scale)
			if i<4:
				tiger[i].position=Vector2(pos_init_x+2*i*box_size,pos_init_y)
			if i>=4:
				tiger[i].position=Vector2(pos_init_x+(2*i-7)*box_size,pos_init_y+6*box_size)
			add_child(sprite)
#loads lion 
	if Globaldata.board_size==5:
		for i in range(5):
			var img = preload("res://assets/lion.png")  
			var sprite = Sprite2D.new()
			lion.append(sprite)
			lion[i].texture = img
			lion[i].scale = Vector2(tkn_scale,tkn_scale)  
			if i<2:
				lion[i].position=Vector2(pos_init_x+(2*i+1)*box_size,pos_init_y)
			if i>=2:
				lion[i].position=Vector2(pos_init_x+2*(i-2)*box_size,pos_init_y+4*box_size)
			add_child(sprite)
	else:
		for i in range(7):
			var img = preload("res://assets/lion.png")  
			var sprite = Sprite2D.new()
			lion.append(sprite)
			lion[i].texture = img
			lion[i].scale = Vector2(tkn_scale,tkn_scale)  
			if i<3:
				lion[i].position=Vector2(pos_init_x+(2*i+1)*box_size,pos_init_y)
			if i>=3:
				lion[i].position=Vector2(pos_init_x+2*(i-3)*box_size,pos_init_y+6*box_size)
			add_child(sprite)

#creates buttons on tokens 
func create_btns_on_tokens():
	delete_all_old_buttons()
	token_moved=false
 #for tigers 
	if tiger_move and not (bot_player.bot_enabled and bot_player.bot_side == "tiger"):
		for i in range(Globaldata.board_size):
			var btn=Button.new()
			btn.size=Vector2(btn_size,btn_size)
			btn.position=tiger[i].position-btn_pos_diff
			btn.modulate.a=0
			btn.pressed.connect(func():
				selected_tiger=i
				create_btns_around_tokens()
				)
			add_child(btn)
			tiger_btn.append(btn)
	if lion_move and not (bot_player.bot_enabled and bot_player.bot_side == "lion"):
		for i in range(Globaldata.board_size):
			var btn=Button.new()
			btn.size=Vector2(btn_size,btn_size)
			btn.position=lion[i].position-btn_pos_diff
			btn.modulate.a=0
			btn.pressed.connect(func():
				selected_lion=i
				create_btns_around_tokens()
				)
			add_child(btn)
			lion_btn.append(btn)

#deletes older buttons before creating new buttons around token
func delete_all_old_buttons():
	var btn_present = false
	for btn in tiger_btn:
		if is_instance_valid(btn):
			btn_present = true
	if btn_present and token_moved:
		for btn in tiger_btn:
			if is_instance_valid(btn) :
				btn.queue_free()
		tiger_btn.clear()

	btn_present = false
	for btn in lion_btn:
		if is_instance_valid(btn):
			btn_present = true
	if btn_present and token_moved:
		for btn in lion_btn:
			if is_instance_valid(btn):
				btn.queue_free()
		lion_btn.clear()

	for btn in around_btn:
		if is_instance_valid(btn):
			btn.queue_free()
	around_btn.clear()

#deletes buttons created in restricted position
func delete_required_buttons():
	#removes around_btns if any token present
	for i in range(around_btn.size() - 1, -1, -1):
		if is_instance_valid(around_btn[i]):
			if Globaldata.board_size==5:
				for j in range(5):
					if (is_instance_valid(tiger[j]) and around_btn[i].position.distance_to(tiger[j].position - btn_pos_diff)<5) or (is_instance_valid(lion[j]) and around_btn[i].position.distance_to(lion[j].position - btn_pos_diff)<5):
						around_btn[i].queue_free()
			else:
				for j in range(7):
					if (is_instance_valid(tiger[j]) and around_btn[i].position.distance_to(tiger[j].position - btn_pos_diff)<5) or (is_instance_valid(lion[j]) and around_btn[i].position.distance_to(lion[j].position - btn_pos_diff)<5):
						around_btn[i].queue_free()


#------deletes all buttons which are present at postion with restriction of diagonal moves----------
	if Globaldata.board_size==5:
		var temp
		for i in range(0,12):
			temp=2*i+1
			if selected_tiger != -1 and pos[temp].distance_to(tiger[selected_tiger].position)<5:
				for m in [8, 6, 2, 0]:
					if m < around_btn.size() and is_instance_valid(around_btn[m]):
						around_btn[m].queue_free()
			elif selected_lion != -1 and pos[temp].distance_to(lion[selected_lion].position)<5:
				for m in [8, 6, 2, 0]:
					if m < around_btn.size() and is_instance_valid(around_btn[m]):
						around_btn[m].queue_free()
	else:
		var temp
		for i in range(0,24):
			temp=2*i+1
			if selected_tiger != -1 and pos[temp].distance_to(tiger[selected_tiger].position)<5:
				for m in [8, 6, 2, 0]:
					if m < around_btn.size() and is_instance_valid(around_btn[m]):
						around_btn[m].queue_free()
			elif selected_lion != -1 and pos[temp].distance_to(lion[selected_lion].position)<5:
				for m in [8, 6, 2, 0]:
					if m < around_btn.size() and is_instance_valid(around_btn[m]):
						around_btn[m].queue_free()

	for i in [2,1,0]:
		if selected_tiger != -1 and i < around_btn.size() and is_instance_valid(around_btn[i]):
			if abs(tiger[selected_tiger].position.y-pos_init_y)<5:
				around_btn[i].queue_free()
		elif selected_lion != -1 and i < around_btn.size() and is_instance_valid(around_btn[i]):
			if abs(lion[selected_lion].position.y-pos_init_y)<5:
				around_btn[i].queue_free()

	for i in [8,7,6]:
		if Globaldata.board_size==5:
			if selected_tiger != -1 and i < around_btn.size() and is_instance_valid(around_btn[i]):
				if abs(tiger[selected_tiger].position.y-(pos_init_y + 4*box_size))<5:
					around_btn[i].queue_free()
			elif selected_lion != -1 and i < around_btn.size() and is_instance_valid(around_btn[i]):
				if abs(lion[selected_lion].position.y-(pos_init_y + 4 * box_size))<5:
					around_btn[i].queue_free()
		else:
			if selected_tiger != -1 and i < around_btn.size() and is_instance_valid(around_btn[i]):
				if abs(tiger[selected_tiger].position.y-(pos_init_y + 6*box_size))<5:
					around_btn[i].queue_free()
			elif selected_lion != -1 and i < around_btn.size() and is_instance_valid(around_btn[i]):
				if abs(lion[selected_lion].position.y-(pos_init_y + 6 * box_size))<5:
					around_btn[i].queue_free()

#creates buttons around selected token
func create_btns_around_tokens():
	delete_all_old_buttons()
	for i in range(9):
		var btn = Button.new()
		btn.size = Vector2(btn_size, btn_size)
		btn.modulate=Color(2,8,9,1)
		if i < 3:
			if selected_tiger != -1:
				btn.position = tiger[selected_tiger].position + Vector2(-box_size + i * box_size, -box_size) - btn_pos_diff
			elif selected_lion != -1:
				btn.position = lion[selected_lion].position + Vector2(-box_size + i * box_size, -box_size) - btn_pos_diff
		elif i < 6:
			if selected_tiger != -1:
				btn.position = tiger[selected_tiger].position + Vector2(-box_size + (i - 3) * box_size, 0) - btn_pos_diff
			elif selected_lion != -1:
				btn.position = lion[selected_lion].position + Vector2(-box_size + (i - 3) * box_size, 0) - btn_pos_diff
		else:
			if selected_tiger != -1:
				btn.position = tiger[selected_tiger].position + Vector2(-box_size + (i - 6) * box_size, box_size) - btn_pos_diff
			elif selected_lion != -1:
				btn.position = lion[selected_lion].position + Vector2(-box_size + (i - 6) * box_size, box_size) - btn_pos_diff
		var tiger_index = selected_tiger
		var lion_index = selected_lion
		btn.pressed.connect(func(idx=i):
			token_move_sound.play()
			token_move_sound.seek(0.33)
			await get_tree().create_timer(0.2).timeout
			token_move_sound.stop()
			selected_tiger = tiger_index
			selected_lion = lion_index
			move_tokens(idx)
			create_btns_on_tokens()
		)
		add_child(btn)
		around_btn.append(btn)
	delete_required_buttons()
	selected_tiger = -1
	selected_lion = -1

#moves token to selected position
func move_tokens(selected_btn):
	token_moved=true
	var tween = create_tween()
	if selected_tiger != -1 and selected_btn >= 0 and selected_btn < around_btn.size() and is_instance_valid(around_btn[selected_btn]):
		tween.tween_property(tiger[selected_tiger], "position", around_btn[selected_btn].position + btn_pos_diff, token_move_duration)
		tiger_move = false
		lion_move = true
	elif selected_lion != -1 and selected_btn >= 0 and selected_btn < around_btn.size() and is_instance_valid(around_btn[selected_btn]):
		tween.tween_property(lion[selected_lion], "position", around_btn[selected_btn].position + btn_pos_diff, token_move_duration)
		lion_move = false
		tiger_move = true
	await get_tree().create_timer(0.25).timeout
	check_victory()
		
#checks if a player won match
func check_victory():
	if selected_tiger!=-1:
		var diff_of_pos_x=tiger[1].position.x-tiger[0].position.x
		var diff_of_pof_y=tiger[1].position.y-tiger[0].position.y
		Globaldata.tiger_won=true
		for i in range(2,Globaldata.board_size):
			if abs(diff_of_pos_x*(tiger[i].position.y-tiger[0].position.y)-diff_of_pof_y*(tiger[i].position.x-tiger[0].position.x))>5:
				Globaldata.tiger_won=false
				break
	elif selected_lion!=-1:
		var diff_of_pos_x=lion[1].position.x-lion[0].position.x
		var diff_of_pof_y=lion[1].position.y-lion[0].position.y
		Globaldata.lion_won=true
		for i in range(2,Globaldata.board_size):
			if abs(diff_of_pos_x*(lion[i].position.y-lion[0].position.y)-diff_of_pof_y*(lion[i].position.x-lion[0].position.x))>5:
				Globaldata.lion_won=false
				break
	if Globaldata.tiger_won:
		$MenuLayer/blur_rect.visible=true
		victory_animation()
	elif Globaldata.lion_won:
		$MenuLayer/blur_rect.visible=true
		victory_animation()
#restting values
	if lion_move:
		selected_tiger=-1
	else:
		selected_lion=-1
	if Globaldata.switeched_to_bot_mode:
		bot_player.handle_bot_turn()

#enters to pause button
func pause_button():
	pause_btn.pressed.connect(func():
		pause_btn.disabled=true
		await menu.btn_press_animation(0,pause_btn.get_parent(),"pause_menu")
		pause_btn.disabled=false
		$MenuLayer/blur_rect.visible=true
		if !menu.get_parent().visible:
			menu.get_parent().visible=true
		menu.visible=true
		disable_btns()
		#lion_won=true
		#lion_win_label.visible=true
		#victory_animation()
		)

#disables all buttons present in current condition
func disable_btns():
	for btn in tiger_btn:
		btn.disabled=true
	for btn in lion_btn:
		btn.disabled=true
	for btn in around_btn:
		if is_instance_valid(btn):
			btn.disabled=true

func set_board_size():
	if Globaldata.board_size==5:
		fxf_board.visible=true
		sxs_board.visible=false
	elif Globaldata.board_size==7:
		fxf_board.visible=false
		sxs_board.visible=true

#plays victory animation and shows victory label also 
var connections_set = false
func victory_animation():
	var tween = create_tween()
	if Globaldata.tiger_won:
		tiger_win_label.visible=true
		var play_again_btn = $MenuLayer/tiger_win_label/c1/play_again/btn
		var main_menu_btn = $MenuLayer/tiger_win_label/c2/main_menu/btn
		var tiger_win_c1 = tiger_win_label.get_node("c1")
		var tiger_win_c2 = tiger_win_label.get_node("c2")
		play_again_btn.modulate = Color(12.216, 52.329, 17.852, 0.15)
		main_menu_btn.modulate = Color(10.154, 39.258, 22.437, 0.15)
		play_again_btn.disabled = true
		main_menu_btn.disabled = true
		play_again_btn.get_parent().visible = false
		main_menu_btn.get_parent().visible = false
		tiger_win_c1.position.x -= 450
		tiger_win_c2.position.x += 450
		tween.tween_property(tiger_win_c1, "position", Tc1_pos_init, 0.2)
		tween.parallel().tween_property(tiger_win_c2, "position", Tc2_pos_init, 0.2)
		await get_tree().create_timer(0.16).timeout
		collision_sound.play()
		shake_node($MenuLayer/tiger_win_label)
		play_again_btn.get_parent().visible = true
		main_menu_btn.get_parent().visible = true
		play_again_btn.disabled = false
		main_menu_btn.disabled = false
		if not connections_set:
			connections_set = true
			play_again_btn.pressed.connect(func():
				play_again_btn.disabled=true
				var blur_rect = $MenuLayer/blur_rect
				await menu.btn_press_animation(2, play_again_btn.get_parent(), "tiger_win_label")
				blur_rect.visible = false
				var tween2 = create_tween()
				tween2.tween_property(tiger_win_c1, "position", Tc1_pos_init - Vector2(450, 0), 0.15)
				tween2.parallel().tween_property(tiger_win_c2, "position", Tc2_pos_init + Vector2(450, 0), 0.15)
				await get_tree().create_timer(0.31).timeout
				tiger_win_label.visible = false
				tiger_win_c1.position = Tc1_pos_init
				tiger_win_c2.position = Tc2_pos_init
				play_again_btn.disabled=false
			)
			main_menu_btn.pressed.connect(func():
				menu.btn_press_animation(3, main_menu_btn.get_parent(), "tiger_win_label")
			)
		Globaldata.tiger_won=false
	if Globaldata.lion_won:
		
		lion_win_label.visible=true
		var play_again_btn = $MenuLayer/lion_win_label/c1/play_again/btn
		var main_menu_btn = $MenuLayer/lion_win_label/c2/main_menu/btn
		var lion_win_c1 = lion_win_label.get_node("c1")
		var lion_win_c2 = lion_win_label.get_node("c2")
		play_again_btn.modulate = Color(12.216, 52.329, 17.852, 0.15)
		main_menu_btn.modulate = Color(10.154, 39.258, 22.437, 0.15)
		play_again_btn.disabled = true
		main_menu_btn.disabled = true
		play_again_btn.get_parent().visible = false
		main_menu_btn.get_parent().visible = false
		lion_win_c1.position.x -= 450
		lion_win_c2.position.x += 450
		tween.tween_property(lion_win_c1, "position", Lc1_pos_init, 0.2)
		tween.parallel().tween_property(lion_win_c2, "position", Lc2_pos_init, 0.2)
		await get_tree().create_timer(0.16).timeout
		collision_sound.play()
		shake_node($MenuLayer/lion_win_label)
		play_again_btn.get_parent().visible = true
		main_menu_btn.get_parent().visible = true
		play_again_btn.disabled = false
		main_menu_btn.disabled = false
		if not connections_set:
			connections_set = true
			play_again_btn.pressed.connect(func():
				play_again_btn.disabled=true
				var blur_rect = $MenuLayer/blur_rect
				await menu.btn_press_animation(2, play_again_btn.get_parent(), "lion_win_label")
				blur_rect.visible = false
				var tween2 = create_tween()
				tween2.tween_property(lion_win_c1, "position", Lc1_pos_init - Vector2(450, 0), 0.15)
				tween2.parallel().tween_property(lion_win_c2, "position", Lc2_pos_init + Vector2(450, 0), 0.15)
				await get_tree().create_timer(0.31).timeout
				lion_win_label.visible = false
				lion_win_c1.position = Lc1_pos_init
				lion_win_c2.position = Lc2_pos_init
				play_again_btn.disabled=false
			)
			main_menu_btn.pressed.connect(func():
				menu.btn_press_animation(3, main_menu_btn.get_parent(), "lion_win_label")
			)
		Globaldata.lion_won=false
#creats shaking effect to variavle "node"
func shake_node(node: Node, strength: float = 8.0, duration: float = 0.2) -> void:
	if not node or not (node is Control or node is Node2D):
		return
	var original_pos = node.position
	var shakes_per_second = 120                # higher = faster shake
	var steps = int(duration * shakes_per_second) # number of shake steps
	var tween = node.create_tween()
	for i in range(steps):
		var offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(node, "position", original_pos + offset, duration / steps)
	tween.tween_property(node, "position", original_pos, duration / steps)
	tween.play()

func _ready():
	Tc1_pos_init = $MenuLayer/tiger_win_label/c1.position
	Tc2_pos_init = $MenuLayer/tiger_win_label/c2.position
	Lc1_pos_init=$MenuLayer/lion_win_label/c1.position
	Lc2_pos_init=$MenuLayer/lion_win_label/c2.position
	set_board_size()
	set_scaling_values()
	load_token()
	set_positions()
	if Globaldata.switeched_to_bot_mode:
		bot_player.switch_to_bot_mode("lion",3)
	create_btns_on_tokens()
	pause_button()
