extends Control


func on_player_changed(texture):
	$UI/Statusbar/Player.texture = texture


func on_player_won(player_id):
	$UI/Statusbar/WinnerLabel.text = "Player %d won!" % (player_id + 1)
	$UI/Statusbar/RestartButton.visible = true

func on_restart_pressed():
	$UI/Statusbar/RestartButton.visible = false
	$UI/Statusbar/WinnerLabel.text = ""
	$Game.reset_state()
