extends KinematicBody2D


export var GRAVITY = 25
const ACCELERATION = 10
const FRICTION = 20
export var SPEED = 200
var velocity = Vector2()
export var JUMPSPEED = 250

var playing = false

signal mine(mousepos)

func _physics_process(delta):
	if playing:
		$GraphicsTemp.visible = true
		
		velocity.y += GRAVITY * delta
		
		if Input.is_action_pressed("ui_move_left"):
			velocity.x = -SPEED
		elif Input.is_action_pressed("ui_move_right"):
			velocity.x =  SPEED
		else:
			velocity.x = 0
		if Input.is_action_just_pressed("ui_jump") and is_on_floor():
			velocity.y -= JUMPSPEED
			
		if Input.is_action_pressed("ui_use"):
			var mouse_pos = get_viewport().get_mouse_position()
			mouse_pos -= Vector2(400, 225)
			var mine_pos = mouse_pos + self.position
			emit_signal("mine", mine_pos)

		velocity = move_and_slide(velocity, Vector2(0, -1))
	else:
		$GraphicsTemp.visible = false
	
func _on_Mapgen_mapgen_finished():
	playing = true
