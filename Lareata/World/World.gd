extends Node2D

func _process(delta):
	var pos = $Player.position
	
	$Mapgen.player_x = pos.x
	$Mapgen.player_y = pos.y
