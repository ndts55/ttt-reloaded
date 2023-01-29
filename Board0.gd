extends VBoxContainer

enum {Xs, Os, Ns}
enum {Xp, Op}

const DIM = 3
var board_data : Array = [Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns]
var current_player = Xp
var is_winner = false

var unpressed_texture = preload("res://assets/unpressed-tile.png")
var x_texture = preload("res://assets/player-x-tile.png")
var o_texture = preload("res://assets/player-o-tile.png")

func on_button_pressed(idx: int) -> void:
	if not is_unpressed(idx):
		return
	set_field(idx)

func is_unpressed(idx: int) -> bool:
	return board_data[idx] == Ns

func set_field(idx: int) -> void:
	var texture
	var next_player
	var data
	match current_player:
		Xp:
			texture = x_texture
			next_player = Op
			data = Xs
		Op:
			texture = o_texture
			next_player = Xp
			data = Os
	
	var row = idx/DIM
	get_node("Row%d/Button%d" % [row, idx]).texture_normal = texture
	board_data[idx] = data
	if not check_winner():
		current_player = next_player
	else:
		is_winner = true
		print("Winner is %d" % current_player)

func check_winner() -> bool:
	return check_rows() or check_cols() or check_diags()

func check_rows() -> bool:
	for row in range(DIM):
		var idx = row * DIM
		if board_data[idx] != Ns and board_data[idx] == board_data[idx + 1] and board_data[idx + 1] == board_data[idx + 2]:
			return true
	return false

func check_cols() -> bool:
	for col in range(DIM):
		if board_data[col] != Ns and board_data[col] == board_data[col + DIM] and board_data[col + DIM] == board_data[col + 2*DIM]:
			return true
	return false

func check_diags() -> bool:
	var center = board_data[4]
	return center != Ns and ((board_data[0] == center and center == board_data[8]) or (board_data[2] == center and center == board_data[6]))
