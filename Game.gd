extends Control

signal player_changed(texture)
signal player_won(player_id)

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
var is_winner = false
var playable_board = ANY_BOARD

var unpressed_texture = preload("res://assets/unpressed-tile.png")
var draw_texture = preload("res://assets/draw-tile.png")
var x_texture = preload("res://assets/player-x-tile.png")
var o_texture = preload("res://assets/player-o-tile.png")
var disabled_texture = preload("res://assets/disabled-board.png")

func reset_state() -> void:
	board_data = [
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
	winners = [Nb, Nb, Nb, Nb, Nb, Nb, Nb, Nb, Nb]
	current_player = Xp
	is_winner = false
	playable_board = ANY_BOARD
	# remove overlay textures and make them invisible
	# set correct textures on buttons and make sure they are visible
	for board_id in range(board_data.size()):
		for button_id in range(board_data[board_id].size()):
			_get_button(board_id, button_id).texture_normal = unpressed_texture
		_get_buttons_grid(board_id).visible = true
		var overlay = _get_overlay(board_id)
		overlay.texture = null
		overlay.visible = false
	_ready()

func _ready():
	_emit_player_changed()
	_draw_disabled()

func _emit_player_changed() -> void:
	emit_signal("player_changed", _player_texture())

func _draw_disabled() -> void:
	for i in range(winners.size()):
		if winners[i] != Nb:
			continue
		var overlay = _get_overlay(i)
		overlay.texture = disabled_texture
		overlay.visible = not (playable_board == ANY_BOARD or playable_board == i)

func _player_texture():
	match current_player:
		Xp:
			return x_texture
		Op:
			return o_texture

func on_button_pressed(board: int, button: int) -> void:
	if is_winner or not _is_unpressed(board, button) or not _is_set_allowed(board):
		return
	_set_field(board, button)

func _is_unpressed(board: int, button: int) -> bool:
	return board_data[board][button] == Ns

func _is_set_allowed(board: int) -> bool:
	return winners[board] == Nb and (playable_board == ANY_BOARD or board == playable_board)

func _set_field(board: int, button: int) -> void:
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
	_get_button(board, button).texture_normal = texture
	board_data[board][button] = data
	_check_finished_board(board)
	is_winner = _check_winner()
	playable_board = _determine_playable_board(button)
	_draw_disabled()
	if is_winner:
		emit_signal("player_won", current_player)
	else:
		current_player = next_player
		_emit_player_changed()

func _check_finished_board(board: int) -> void:
	var b = board_data[board]
	if _check_draw(b):
		winners[board] = Db
		var overlay = _get_overlay(board)
		overlay.texture = draw_texture
		overlay.visible = true
		_get_buttons_grid(board).visible = false
		return
	var cpd = Xs if current_player == Xp else Os
	var tmp : Array = []
	tmp.resize(b.size())
	for i in range(b.size()):
		tmp[i] = b[i] == cpd
	if _check_bool_array(tmp):
		winners[board] = cpd
		var overlay = _get_overlay(board)
		overlay.texture = _player_texture()
		overlay.visible = true
		_get_buttons_grid(board).visible = false

func _check_draw(arr: Array) -> bool:
	for b in arr:
		if b == Ns:
			return false
	return true

func _check_winner() -> bool:
	var cpd = Xs if current_player == Xp else Os
	var tmp : Array = []
	tmp.resize(winners.size())
	for i in range(winners.size()):
		tmp[i] = winners[i] == cpd
	return _check_bool_array(tmp)

func _check_bool_array(arr: Array) -> bool:
	return _check_diag(arr) or _check_rows(arr) or _check_cols(arr)

func _check_rows(arr: Array) -> bool:
	for row in range(3):
		var idx = row * 3
		if arr[idx] and arr[idx + 1] and arr[idx + 2]:
			return true
	return false

func _check_cols(arr: Array) -> bool:
	for col in range(3):
		if arr[col] and arr[col + 3] and arr[col + 6]:
			return true
	return false

func _check_diag(arr: Array) -> bool:
	return arr[4] and ((arr[0] and arr[8]) or (arr[2] and arr[6]))

func _determine_playable_board(button: int) -> int:
	return button if winners[button] == Nb else ANY_BOARD

func _get_overlay(board: int):
	return get_node("Board%d/Overlay" % board)

func _get_buttons_grid(board: int):
	return get_node("Board%d/Buttons" % board)

func _get_button(board: int, button: int):
	return get_node("Board%d/Buttons/Button%d" % [board, button])
