extends Node2D

func _process(delta):
	var pos = $Player.position
	
	$Mapgen.player_x = pos.x
	$Mapgen.player_y = pos.y
	
	$Panel.rect_position = $Player.position - Vector2(400, 225)
