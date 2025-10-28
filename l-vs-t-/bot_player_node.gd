extends Node
var gamemanager
# ===================== BOT SETTINGS =====================
var bot_enabled := false
var bot_intelligence := 1  # 1 = random | 2 = defensive | 3 = strategic
var bot_side := "lion"     # which side bot controls: "lion" or "tiger"

func switch_to_bot_mode(side: String = "lion", intelligence_level: int = 1) -> void:
	bot_enabled = true
	bot_side = side
	bot_intelligence = intelligence_level
	print("✅ Bot mode activated as ", bot_side, " | Intelligence:", bot_intelligence)

#============= ⚙️ MAIN BOT EXECUTION LOGIC ==============
func handle_bot_turn() -> void:
	if not bot_enabled:
		return
	
	# Check whose turn it is
	if (bot_side == "tiger" and gamemanager.tiger_move) or (bot_side == "lion" and gamemanager.lion_move):
		var tiger_won_temp =Globaldata.tiger_won
		var lion_won_temp=Globaldata.lion_won
		await get_tree().create_timer(0.35).timeout  # small delay for realism
		if (tiger_won_temp or lion_won_temp):
			if bot_side == "tiger":
				gamemanager.lion_move=true
			else:
				gamemanager.tiger_move=true
		else:
			perform_bot_move()

#================== 🔍 MOVE SELECTION ===================
func perform_bot_move() -> void:
	var all_tokens := []
	var possible_moves := {}
	if bot_side == "tiger":
		all_tokens = gamemanager.tiger
	else:
		all_tokens = gamemanager.lion

	# gather valid moves for each token
	for i in range(all_tokens.size()):
		if not is_instance_valid(all_tokens[i]):
			continue
		var valid_positions := get_valid_positions_for_token(all_tokens[i])
		if valid_positions.size() > 0:
			possible_moves[i] = valid_positions

	if possible_moves.size() == 0:
		print("❌ No valid moves for bot.")
		return

	var chosen_token := -1
	var chosen_target = Vector2()

	match bot_intelligence:
		1:
			# random move
			chosen_token = possible_moves.keys()[randi() % possible_moves.size()]
			var pos_list = possible_moves[chosen_token]
			chosen_target = pos_list[randi() % pos_list.size()]
		2:
			# defensive: prefer central or safe moves
			var result = get_central_move(possible_moves)
			chosen_token = result[0]
			chosen_target = result[1]
		3:
			# strategic: human-like move (offensive + defensive)
			var result = get_best_scoring_move(possible_moves)
			chosen_token = result[0]
			chosen_target = result[1]
		_:
			chosen_token = possible_moves.keys()[0]
			chosen_target = possible_moves[chosen_token][0]
	make_bot_move(chosen_token, chosen_target)

# =====🧠 VALID MOVES CALCULATOR (fully rule-based) =====
func get_valid_positions_for_token(token_node: Node2D) -> Array:
	var moves := []
	for i in range(8,-1,-1):
		var pos_candidate := token_node.position + Vector2(-gamemanager.box_size + (i % 3) * gamemanager.box_size, -gamemanager.box_size + int(i / 3) * gamemanager.box_size)
		var valid := true

		# Check collisions with other tokens
		for t in gamemanager.tiger:
			if is_instance_valid(t) and pos_candidate.distance_to(t.position) < 5:
				valid = false
				break
		for l in gamemanager.lion:
			if is_instance_valid(l) and pos_candidate.distance_to(l.position) < 5:
				valid = false
				break

		# Restricted moves based on board rules
		for j in range(0,(Globaldata.board_size*Globaldata.board_size-1)/2):
			if token_node.position.distance_to(gamemanager.pos[2*j+1])<4 and (i==8 or i==6 or i==2 or i==0):
				valid=false

		# Board edges
		if abs(token_node.position.x-(gamemanager.pos_init_x+gamemanager.box_size*(Globaldata.board_size-1)))<5 and (i==2 or i==5 or i==8):
			valid =false
		elif abs(token_node.position.x-gamemanager.pos_init_x)<5 and (i==0 or i==3 or i==6):
			valid=false
		if abs(token_node.position.y-(gamemanager.pos_init_y+gamemanager.box_size*(Globaldata.board_size-1)))<5 and (i==6 or i==7 or i==8):
			valid =false
		elif abs(token_node.position.y-gamemanager.pos_init_y)<5 and (i==0 or i==1 or i==2):
			valid=false
			
		if valid:
			moves.append(pos_candidate)
	return moves

# ============== 🧩 MOVE STRATEGY HELPERS ===============
func get_central_move(possible_moves: Dictionary) -> Array:
	var center := Vector2(gamemanager.pos_init_x + (Globaldata.board_size - 1) * gamemanager.box_size / 2, gamemanager.pos_init_y + (Globaldata.board_size - 1) * gamemanager.box_size / 2)
	var best_dist := INF
	var best_token := -1
	var best_pos = Vector2()
	for token_id in possible_moves.keys():
		for pos_candidate in possible_moves[token_id]:
			var d:float = pos_candidate.distance_to(center)
			if d < best_dist:
				best_dist = d
				best_token = token_id
				best_pos = pos_candidate
	return [best_token, best_pos]
 
#========= Adds all scores for possible moves ===========
func get_best_scoring_move(possible_moves: Dictionary) -> Array:
	var tokens = gamemanager.tiger if bot_side == "tiger" else gamemanager.lion
	var enemy_tokens = gamemanager.lion if bot_side == "tiger" else gamemanager.tiger
	var best_score := -INF
	var best_token := -1
	var best_pos = Vector2()

	for token_id in possible_moves.keys():
		for pos_candidate in possible_moves[token_id]:
			var score := 0.0
			score += get_action_efficiency_score(pos_candidate,tokens, enemy_tokens) # block opponent
			score += simulate_future_enemy_moves(token_id, pos_candidate, tokens, enemy_tokens)
			score += get_positional_score(pos_candidate)             # favor center
			if score > best_score:
				best_score = score
				best_token = token_id
				best_pos = pos_candidate

	return [best_token, best_pos]

func get_alignment_score(pos_candidate: Vector2, my_tokens: Array) -> float:
	var score := 0.0
	# Main 4 possible line directions
	var directions = [
		Vector2(1, 0),   # horizontal
		Vector2(0, 1),   # vertical
		Vector2(1, 1),   # diagonal down-right
		Vector2(1, -1)   # diagonal up-right
	]
	for dir in directions:
		var alignment_strength := 0.0
		# Step 1: find how well all existing tokens already fit this direction
		for t in my_tokens:
			if not is_instance_valid(t):
				continue
			var delta = t.position - pos_candidate
			# Check if token lies near this line direction (within angle tolerance)
			var angle_diff = abs(delta.angle_to(dir))
			if angle_diff < 0.35 or angle_diff > PI - 0.35:
				alignment_strength += 1.0  # token fits this direction
			else:
				# Token is off-direction; small penalty
				alignment_strength -= 0.2
		# Step 2: add global weighting for distance (we don't punish far tokens harshly)
		score += alignment_strength * 50
	return score

func get_blocking_score(pos_candidate: Vector2, my_tokens: Array, enemy_tokens: Array) -> float:
	var score := 0.0
	var directions = [Vector2(1,0), Vector2(0,1), Vector2(1,1), Vector2(1,-1)]
	
	for dir in directions:
		# Check each enemy token as starting point of a threat
		for e in enemy_tokens:
			if not is_instance_valid(e):
				continue
			
			var threat_tokens := [e]
			
			# Collect other enemy tokens in line with e in this direction
			for other in enemy_tokens:
				if other == e or not is_instance_valid(other):
					continue
				var delta = other.position - e.position
				if abs(delta.angle_to(dir)) < 0.2 or abs(delta.angle_to(-dir)) < 0.2:
					threat_tokens.append(other)
			
			# Only consider lines with 3 or more enemy tokens
			if threat_tokens.size() >= 3:
				# Predict next enemy position to complete the line
				var next_pos = e.position + dir * gamemanager.box_size * (threat_tokens.size())
				
				# Estimate minimum moves for bot to block this position
				var min_moves := INF
				for t in my_tokens:
					if not is_instance_valid(t):
						continue
					
					# Approximate moves using grid distance (Manhattan)
					var dist = (t.position - next_pos).abs().x / gamemanager.box_size + (t.position - next_pos).abs().y / gamemanager.box_size
					if dist < min_moves:
						min_moves = dist
				
				# Score inversely proportional to moves required
				score += 50.0 / max(min_moves, 1.0)  # fewer moves = higher score
	return score

#=calculates score for possible futures's moves of enemy=
func simulate_future_enemy_moves(bot_token_id: int, bot_pos: Vector2, bot_tokens: Array, enemy_tokens: Array) -> float:
	var original_pos = bot_tokens[bot_token_id].position
	bot_tokens[bot_token_id].position = bot_pos
	var penalty := 0.0

	for i in range(enemy_tokens.size()):
		if not is_instance_valid(enemy_tokens[i]):
			continue
		var enemy_moves := get_valid_positions_for_token(enemy_tokens[i])
		for em in enemy_moves:
			var temp = enemy_tokens[i].position
			enemy_tokens[i].position = em
			if would_enemy_win(enemy_tokens):
				penalty -= 100.0
			enemy_tokens[i].position = temp

	bot_tokens[bot_token_id].position = original_pos
	return penalty

func would_enemy_win(enemy_tokens: Array) -> bool:
	if enemy_tokens.size() < 3:
		return false
	var diff_x = enemy_tokens[1].position.x - enemy_tokens[0].position.x
	var diff_y = enemy_tokens[1].position.y - enemy_tokens[0].position.y
	for i in range(2, enemy_tokens.size()):
		if abs(diff_x * (enemy_tokens[i].position.y - enemy_tokens[0].position.y) -
			   diff_y * (enemy_tokens[i].position.x - enemy_tokens[0].position.x)) > 5:
			return false
	return true
func get_action_efficiency_score(pos_candidate: Vector2, my_tokens: Array, enemy_tokens: Array) -> float:
	var align_score = get_alignment_score(pos_candidate, my_tokens)
	var block_score = get_blocking_score(pos_candidate, my_tokens, enemy_tokens)
	# Estimate "moves to goal" inversely proportional to score
	# (Higher score → fewer moves needed)
	var moves_to_align = 1.0 / max(align_score, 1.0)
	var moves_to_block = 1.0 / max(block_score, 1.0)
	
	# Normalize them (you can tune these multipliers)
	var efficiency_align = 100.0 / (moves_to_align + 1.0)
	var efficiency_block = 100.0 / (moves_to_block + 1.0)
	
	# Combine both with equal weight
	var total_efficiency = efficiency_align + efficiency_block
	
	# Bonus: if one action is significantly faster, favor it
	if abs(moves_to_align - moves_to_block) > 0.1:
		if moves_to_align < moves_to_block:
			total_efficiency += 20.0  # alignment faster
		else:
			total_efficiency += 20.0  # blocking faster
	return total_efficiency

func get_positional_score(pos_candidate: Vector2) -> float:
	var center := Vector2(gamemanager.pos_init_x + (Globaldata.board_size - 1) * gamemanager.box_size / 2, gamemanager.pos_init_y + (Globaldata.board_size - 1) * gamemanager.box_size / 2)
	return 5.0 / (1.0 + pos_candidate.distance_to(center))

# ===============🎮 EXECUTE MOVE==================
func make_bot_move(token_index: int, target_pos: Vector2) -> void:
	gamemanager.token_moved = true
	if bot_side == "tiger":
		gamemanager.selected_tiger = token_index
	else:
		gamemanager.selected_lion = token_index
	var tween = create_tween()
	if bot_side == "tiger"  and not Globaldata.lion_won:
		tween.tween_property(gamemanager.tiger[token_index], "position", target_pos, gamemanager.token_move_duration)
		gamemanager.tiger_move = false
		gamemanager.lion_move = true
	elif not Globaldata.tiger_won:
		tween.tween_property(gamemanager.lion[token_index], "position", target_pos, gamemanager.token_move_duration)
		gamemanager.lion_move = false
		gamemanager.tiger_move = true

	await get_tree().create_timer(0.25).timeout
	gamemanager.check_victory()
	await get_tree().create_timer(0.3).timeout
	gamemanager.create_btns_on_tokens()
	handle_bot_turn()  # chain next bot turn if required

func _ready():
	gamemanager=get_parent()
