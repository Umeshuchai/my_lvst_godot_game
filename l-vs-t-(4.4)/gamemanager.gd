extends Node2D
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
var tiger_won=false
var lion_won=false
@onready var sxs_board=$Board_sxs
@onready var fxf_board=$Board_fxf

func set_scaling_values():
	if Globaldata.board_size==5:
		pos_init_x=50
		pos_init_y=155
		tkn_scale=0.08
		btn_size=70
		box_size=154.4
		btn_pos_diff=Vector2(32,20)
	elif Globaldata.board_size==7:
		pos_init_x=49.4
		pos_init_y=155
		tkn_scale=0.0725
		btn_size=49
		box_size=103.45
		btn_pos_diff=Vector2(23,15)

#sets positions to variables
func set_positions():
	if Globaldata.board_size==5:
		for pos_const in range(25):
			pos.append(Vector2(pos_init_x+(pos_const-(pos_const/5)*5)*box_size,pos_init_y+(pos_const/5)*box_size))
	elif Globaldata.board_size==7:
		for pos_const in range(49):
			pos.append(Vector2(pos_init_x+(pos_const-(pos_const/7)*7)*box_size,pos_init_y+(pos_const/7)*box_size))
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
func create_btns():
	delete_all_old_buttons()
	token_moved=false
 #for tigers 
	if tiger_move:
		for i in range(Globaldata.board_size):
			var btn=Button.new()
			btn.size=Vector2(btn_size,btn_size)
			btn.position=tiger[i].position-btn_pos_diff
			btn.modulate.a=0
			btn.pressed.connect(func():
				selected_tiger=i
				create_btns_around()
				)
			add_child(btn)
			tiger_btn.append(btn)
	else:
		for i in range(Globaldata.board_size):
			var btn=Button.new()
			btn.size=Vector2(btn_size,btn_size)
			btn.position=lion[i].position-btn_pos_diff
			btn.modulate.a=0
			btn.pressed.connect(func():
				selected_lion=i
				create_btns_around()
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

	if Globaldata.board_size==5:
		for i in [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23]:
			if selected_tiger != -1 and pos[i].distance_to(tiger[selected_tiger].position)<5:
				for m in [8, 6, 2, 0]:
					if m < around_btn.size() and is_instance_valid(around_btn[m]):
						around_btn[m].queue_free()
			elif selected_lion != -1 and pos[i].distance_to(lion[selected_lion].position)<5:
				for m in [8, 6, 2, 0]:
					if m < around_btn.size() and is_instance_valid(around_btn[m]):
						around_btn[m].queue_free()
	else:
		for i in [1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47]:
			if selected_tiger != -1 and pos[i].distance_to(tiger[selected_tiger].position)<5:
				for m in [8, 6, 2, 0]:
					if m < around_btn.size() and is_instance_valid(around_btn[m]):
						around_btn[m].queue_free()
			elif selected_lion != -1 and pos[i].distance_to(lion[selected_lion].position)<5:
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
func create_btns_around():
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
			create_btns()
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
	if lion_move:
		selected_tiger=-1
	else:
		selected_lion=-1
#checks if a player won match
func check_victory():
	if selected_tiger!=-1:
		var pos1=tiger[0].position
		tiger_won=true
		for i in range(1,Globaldata.board_size):
			if abs(pos1.x-tiger[i].position.x)>2 and abs(pos1.y-tiger[i].position.y)>2:
				tiger_won=false
				break
	elif selected_lion!=-1:
		var pos1=lion[0].position
		lion_won=true
		for i in range(1,Globaldata.board_size):
			if abs(pos1.x-lion[i].position.x)>2 and abs(pos1.y-lion[i].position.y)>2:
				lion_won=false
				break
	if lion_won or tiger_won:
		$BlurLayer/blur_rect.visible=true
		menu.get_parent().visible=true
		menu.visible=true
		disable_btns()
#enters to pause button
func pause_button():
	pause_btn.pressed.connect(func():
		$BlurLayer/blur_rect.visible=true
		if !menu.get_parent().visible:
			menu.get_parent().visible=true
		menu.visible=true
		disable_btns()
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
		
func _ready():
	set_board_size()
	set_scaling_values()
	token_move_sound.stream=preload("res://sounds/token-move-sound.mp3")
	load_token()
	set_positions()
	create_btns()
	pause_button()
