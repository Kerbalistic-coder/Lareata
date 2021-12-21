extends Node2D

var map = []

export var map_width = 320
export var map_height = 650
export var cave_tolerance = 0.15

enum blocks {
	AIR,
	GRASS,
	DIRT,
	STONE
}


var noise = OpenSimplexNoise.new()


func set_map(x, y, item):
	map[(x * map_height) + y] = item
	
func get_map(x, y):
	return map[(x * map_height) + y]
	
func place_ore(x, y):
	set_map(x, y, blocks.STONE)
	
func mapgen():
	for i in range(map_width * map_height):
		map.append(null)
		
	var land_point = 30
	
	print("Carving landscape...")
	
	for x in range(map_width):
		var change = noise.get_noise_1d(x) * 4
		land_point += change
		
		if (x / map_width * 100) == 25:
			print("Putting dirt in stone...")
		if (x / map_width * 100) == 66:
			print("Placing ore...")
		
		for y in range(map_height):
			var cave_value = noise.get_noise_2d(x, y)
			
			if cave_value < cave_tolerance:
				if y < round(land_point):
					set_map(x, y, blocks.AIR)
				elif y == round(land_point):
					set_map(x, y, blocks.GRASS)
				elif y < round(land_point) + (15 + noise.get_noise_1d(x) * 4):
					set_map(x, y, blocks.DIRT)
				else:
					place_ore(x, y)
			else:
				set_map(x, y, blocks.AIR)

func _ready():
	# Configure
	noise.seed = randi()
	noise.octaves = 2
	noise.period = 20.0
	noise.persistence = 0.8
	
	mapgen()
	
	for x in range(map_width):
		for y in range(map_height):
			$Map.set_cell(x, y, get_map(x, y))
