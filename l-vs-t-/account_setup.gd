extends Node
var avatars:Array[TextureButton]=[]
var user_data={
	"user_name":"",
	"email_id":"",
	"avatar_code":""
}
@onready var warn_label=$input_menu/img/warn
@onready var username_label=$input_menu/img/username

func _ready():
	for i in range(1, 15):
		var path  = "avatar_bar/ScrollContainer/GridContainer/p_a%d" % i
		var button=get_node(path)
		avatars.append(button)
	load_json()
	$user_profile/btn.pressed.connect(func():
		if not FileAccess.file_exists("user://user_data_of_player_208.json"):
			signup()
		)

func signup():
	print("sign_in_anonymous function called successsfully")
	await FirebaseManager.sign_in_anonymous()
	print("sign_in_anonymous function completed successfully	")
	$blur_rect.visible=true
	$input_menu.visible=true
	$input_menu/img/emailid.text_changed.connect( func(new_text):
		$input_menu/img/Label.visible=not ("@" in new_text) and new_text !=""
		)
	username_label.text_changed.connect(func(new_text):
		warn_label.text="Please enter at least 6 characters."
		var namelength=new_text.strip_edges().length()
		warn_label.visible=namelength<6 and namelength>0
		)
	username_label.grab_focus()
	$input_menu/img/next_btn.pressed.connect(func():
		if username_label.text.strip_edges()=="" and username_label.text.strip_edges().length()<6:
			warn_label.text="Please enter a username first."
			warn_label.visible=true
			await get_tree().create_timer(1).timeout
			warn_label.visible=false
		elif username_label.text.strip_edges().length()>=6 :
			user_data["user_name"]=username_label.text.replace(" ","")
			user_data["email_id"]=$input_menu/img/emailid.text
			avatars_selection()
		)

func avatars_selection():
	$avatar_bar.visible=true
	$input_menu.visible=false
	for i in range(avatars.size()):
		avatars[i].pressed.connect(func():
			for reset_av in avatars:
				reset_av.modulate=Color(1,1,1)
			avatars[i].modulate=Color(0.3,0.3,0.3)
			user_data["avatar_code"]="p_a{i}".format({"i": i+1})
			)
	$avatar_bar/Submit_btn.pressed.connect(func():
		await FirebaseManager.save_player_data(user_data)
		save_data_locally()
		show_data(user_data["user_name"],user_data["email_id"],user_data["avatar_code"])
		$avatar_bar.visible=false
		$blur_rect.visible=false
		)

func save_data_locally():
	var json_text = JSON.stringify(user_data, "\t") # "\t" for pretty formatting
	var file = FileAccess.open("user://user_data_of_player_208.json", FileAccess.WRITE)
	file.store_string(json_text)
	file.close()
	print("✅ JSON saved.")
	
func load_json():
	var data
	var file = FileAccess.open("user://user_data_of_player_208.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		data = JSON.parse_string(content)
		if data:
			print("Loaded data:", data)
		else:
			printerr("❌ Failed to parse JSON.")
	if FileAccess.file_exists("user://user_data_of_player_208.json"):
		var code = data["avatar_code"]  
		var parts = code.split("_a")
		var number = int(parts[1])
		$user_profile.texture=avatars[number-1].texture_normal
		$user_profile/user_name.text=data["user_name"]
		



func show_data(ur,em,av):
	print("User Name:",ur)
	print("Email id:",em)
	print("Avatar code:",av)
