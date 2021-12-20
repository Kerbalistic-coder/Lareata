extends Node2D

export var movement_speed = 10

func _physics_process(delta):
	var velocity = Vector2()
	
	if Input.is_action_pressed("ui_move_up"):
		velocity.y  -= movement_speed
	if Input.is_action_pressed("ui_move_down"):
		velocity.y += movement_speed
	if Input.is_action_pressed("ui_move_left"):
		velocity.x  -= movement_speed
	if Input.is_action_pressed("ui_move_right"):
		velocity.x += movement_speed
		
	position += velocity
