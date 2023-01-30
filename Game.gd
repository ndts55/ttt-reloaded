extends Control

signal player_changed(texture)

# Board State
enum {Xb, Ob, Nb, Db}
# Field State
enum {Xs, Os, Ns}
# Player Turn
enum {Xp, Op}

const ANY_BOARD = -1

var board_data : Array = [
	[Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns],
	[Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns],
	[Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns],
	[Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns],
	[Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns],
	[Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns],
	[Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns],
	[Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns],
	[Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns, Ns],
]
var winners = [Nb, Nb, Nb, Nb, Nb, Nb, Nb, Nb, Nb]
var current_player = Xp
var playable_board = ANY_BOARD

var unpressed_texture = preload("res://assets/unpressed-tile.png")
var draw_texture = preload("res://assets/draw-tile.png")
var x_texture = preload("res://assets/player-x-tile.png")
var o_texture = preload("res://assets/player-o-tile.png")
var disabled_texture = preload("res://assets/disabled-board.png")

func _ready():
	emit_player_changed()
	draw_disabled()

func emit_player_changed() -> void:
	emit_signal("player_changed", player_texture())

func draw_disabled() -> void:
	for i in range(winners.size()):
		if winners[i] != Nb:
			continue
		var overlay = get_overlay(i)
		overlay.texture = disabled_texture
		overlay.visible = not (playable_board == ANY_BOARD or playable_board == i)

func player_texture():
	match current_player:
		Xp:
			return x_texture
		Op:
			return o_texture

func on_button_pressed(board: int, button: int) -> void:
	if not is_unpressed(board, button) or not is_set_allowed(board):
		return
	set_field(board, button)

func is_unpressed(board: int, button: int) -> bool:
	return board_data[board][button] == Ns

func is_set_allowed(board: int) -> bool:
	return winners[board] == Nb and (playable_board == ANY_BOARD or board == playable_board)

func set_field(board: int, button: int) -> void:
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
	get_button(board, button).texture_normal = texture
	board_data[board][button] = data
	check_finished_board(board)
	check_winner()
	playable_board = determine_playable_board(button)
	draw_disabled()
	current_player = next_player
	emit_player_changed()

func check_finished_board(board: int) -> void:
	var b = board_data[board]
	if check_draw(b):
		winners[board] = Db
		var overlay = get_overlay(board)
		overlay.texture = draw_texture
		overlay.visible = true
		get_buttons_grid(board).visible = false
		return
	var cpd = Xs if current_player == Xp else Os
	var tmp : Array = []
	tmp.resize(b.size())
	for i in range(b.size()):
		tmp[i] = b[i] == cpd
	if check_bool_array(tmp):
		winners[board] = cpd
		var overlay = get_overlay(board)
		overlay.texture = player_texture()
		overlay.visible = true
		get_buttons_grid(board).visible = false

func check_draw(arr: Array) -> bool:
	for b in arr:
		if b == Ns:
			return false
	return true

func check_winner() -> void:
	var cpd = Xs if current_player == Xp else Os
	var tmp : Array = []
	tmp.resize(winners.size())
	for i in range(winners.size()):
		tmp[i] = winners[i] == cpd
	if check_bool_array(tmp):
		print("Player %d won the game" % current_player)

func check_bool_array(arr: Array) -> bool:
	return check_diag(arr) or check_rows(arr) or check_cols(arr)

func check_rows(arr: Array) -> bool:
	for row in range(3):
		var idx = row * 3
		if arr[idx] and arr[idx + 1] and arr[idx + 2]:
			return true
	return false

func check_cols(arr: Array) -> bool:
	for col in range(3):
		if arr[col] and arr[col + 3] and arr[col + 6]:
			return true
	return false

func check_diag(arr: Array) -> bool:
	return arr[4] and ((arr[0] and arr[8]) or (arr[2] and arr[6]))

func determine_playable_board(button: int) -> int:
	return button if winners[button] == Nb else ANY_BOARD

func get_overlay(board: int):
	return get_node("Board%d/Overlay" % board)

func get_buttons_grid(board: int):
	return get_node("Board%d/Buttons" % board)

func get_button(board: int, button: int):
	return get_node("Board%d/Buttons/Button%d" % [board, button])
