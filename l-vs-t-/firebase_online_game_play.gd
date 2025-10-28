extends Node
var database_url := "https://lvst-df784-default-rtdb.firebaseio.com/"
var api_key := "AIzaSyAq8u5PCwOz8jIPu1NBhP3PBsEUxG3b7og"
var player_uid := ""
var id_token := ""

# ─────────────────────────────────────────────
#  Read and print all players' usernames and email IDs
# ─────────────────────────────────────────────
func read_all_user_info() -> void:
	if id_token == "":
		printerr("⚠️ Not authenticated yet! Please sign in first.")
		return

	var url = "%splayers.json?auth=%s" % [database_url, id_token]
	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(url)
	if err != OK:
		printerr("❌ Failed to start read request:", err)
		return

	var result = await http.request_completed
	var response_code = result[1]
	var response_body = result[3].get_string_from_utf8()
	var response = JSON.parse_string(response_body)

	if response_code == 200 and typeof(response) == TYPE_DICTIONARY:
		print("✅ Player data retrieved successfully.")
		for uid in response.keys():
			var player = response[uid]
			var username = player.get("username", "N/A")
			var email = player.get("emailid", "N/A")
			print("👤 Username:", username, "| 📧 Email:", email)
	else:
		printerr("❌ Failed to read data. Response code:", response_code)
		printerr(response_body)

# ─────────────────────────────────────────────
#  Anonymous Sign-In
# ─────────────────────────────────────────────
func sign_in_anonymous() -> void:
	print("🟡 Starting anonymous sign-in ...")
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % api_key
	var body = { "returnSecureToken": true }

	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(url, [], HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		printerr("❌ Failed to start HTTP request:", err)
		return

	# ✅ Wait for the request_completed signal
	var result = await http.request_completed

	var response_code = result[1]
	var response_body = result[3].get_string_from_utf8()
	var response = JSON.parse_string(response_body)

	if response_code == 200 and response and "idToken" in response:
		id_token = response["idToken"]
		player_uid = response["localId"]
		print("✅ Anonymous sign-in success! UID:", player_uid)
	else:
		printerr("❌ Anonymous sign-in failed. Response code:", response_code)
		printerr(response_body)

# ─────────────────────────────────────────────
#  Save / Update Player Data
# ─────────────────────────────────────────────
func save_player_data(data: Dictionary) -> void:
	if player_uid == "" or id_token == "":
		printerr("⚠️ Player not signed in yet.")
		return

	var url = "%splayers/%s.json?auth=%s" % [database_url, player_uid, id_token]
	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(url, [], HTTPClient.METHOD_PUT, JSON.stringify(data))
	if err != OK:
		printerr("❌ Failed to start data save request:", err)
		return

	var result = await http.request_completed

	var response_code = result[1]
	var response_body = result[3].get_string_from_utf8()

	if response_code == 200:
		print("💾 Player data saved successfully.")
	else:
		printerr("❌ Failed to save data. Response code:", response_code)
		printerr(response_body)

# ─────────────────────────────────────────────
#  Load All Players (for opponent info, etc.)
# ─────────────────────────────────────────────
func load_all_players() -> Dictionary:
	if id_token == "":
		printerr("⚠️ Not authenticated yet!")
		return {}

	var url = "%splayers.json?auth=%s" % [database_url, id_token]
	var http := HTTPRequest.new()
	add_child(http)

	var err = http.request(url)
	if err != OK:
		printerr("❌ Failed to start load request:", err)
		return {}

	var result = await http.request_completed
	var response_code = result[1]
	var response_body = result[3].get_string_from_utf8()
	var response = JSON.parse_string(response_body)

	if response_code == 200 and typeof(response) == TYPE_DICTIONARY:
		print("✅ Loaded all players successfully.")
		return response
	else:
		printerr("❌ Failed to load players. Response code:", response_code)
		printerr(response_body)
		return {}
