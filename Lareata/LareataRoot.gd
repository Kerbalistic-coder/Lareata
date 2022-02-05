extends Node2D

class_name LareataRoot

# Load stuff
var BasePlayer = load("BasePlayer.gd")

# Variables
var root_player = BasePlayer.new() # Ignore if this doesn't exist
var world_map = []
var light_map = [] 
var map_width setget set_map_width, get_map_width
var map_height setget set_map_height, get_map_height
var map_generated = false;


# Signals
signal start_mapgen(map_width, map_height)


# Functions

# Setters/Getters
func set_map_width(width):
	if !map_generated:
		map_width = width
		
func get_map_width():
	return map_width
	
func set_map_height(height):
	if !map_generated:
		map_height = height
		
func get_map_height():
	return map_height

# Map Access
func get_map(x, y):
	return world_map[(x * map_height) + y]
	
func get_mapV(pos):
	return world_map[(pos.x * map_height) + pos.y]
	
func set_map(x, y, tile):
	world_map[(x * map_height) + y] = tile
	
func set_mapV(pos, tile):
	world_map[(pos.x * map_height) + pos.y] = tile
	
func get_light_map(x, y):
	return light_map[(x * map_height) + y]
	
func get_light_mapV(pos):
	return light_map[(pos.x * map_height) + pos.y]
	
func set_light_map(x, y, tile):
	light_map[(x * map_height) + y] = tile
	
func set_light_mapV(pos, tile):
	light_map[(pos.x * map_height) + pos.y] = tile
	
func __mapgen_finished_sig(map):
	if len(map) == map_width * map_height:
		world_map = map
		
func get_controls(delta):
	var up_vel = 0
	var right_vel = 0
	var jumping = Input.is_action_pressed("ui_accept")
	
	if !root_player.is_on_floor():
		jumping = 0
	
	if Input.is_action_pressed("ui_up"):
		up_vel -= 1
	if Input.is_action_pressed("ui_down"):
		up_vel += 1
	if Input.is_action_pressed("ui_left"):
		right_vel -= 1
	if Input.is_action_pressed("ui_right"):
		right_vel += 1
		
	root_player.move(up_vel, right_vel, jumping, delta)

func _physics_process(delta):
	get_controls(delta)
	root_player.reset_variables()
	root_player.regenerate_life()
