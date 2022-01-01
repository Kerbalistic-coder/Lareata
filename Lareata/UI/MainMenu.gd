extends Control


signal start_game(world_seed)

func _ready():
	$UI/VBoxContainer/NewGameUIMargin/NewGameUI/SeedSelect.value = randi()

func _on_NewGame_pressed():
	self.visible = false
	yield(get_tree().create_timer(0.1), "timeout")
	emit_signal("start_game", $UI/VBoxContainer/NewGameUIMargin/NewGameUI/SeedSelect.value)
