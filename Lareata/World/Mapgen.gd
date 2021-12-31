extends Node2D

var map = []

export var map_width = 320
export var map_height = 650
export var cave_tolerance = 0.15

enum blocks {
	AIR,
	GRASS,
	DIRT,
	STONE,
	COPPER_ORE,
	NORMAL_TREE_TRUNK,
	TREE_LEAVES
}

export var ores = [
	blocks.DIRT,
	blocks.COPPER_ORE
]
export var ore_tolerance = [
	-0.1,
	0.3
]


var noiseLand = OpenSimplexNoise.new()
var noiseOre = OpenSimplexNoise.new()


func set_map(x, y, item):
	map[(x * map_height) + y] = item
	
func get_map(x, y):
	return map[(x * map_height) + y]
	
func place_ore(x, y):
	for ore in range(0, len(ores)):
		var ore_tol = noiseOre.get_noise_2d(x + ore, y + ore)
		if ore_tol > ore_tolerance[ore]:
			set_map(x, y, ores[ore])
		else:
			set_map(x, y, blocks.STONE)
	
func mapgen():
	for i in range(map_width * map_height):
		map.append(null)
		
	var land_point = 30
	
	print("Carving landscape...")
	
	for x in range(map_width):
		var change = noiseLand.get_noise_1d(x) * 4
		land_point += change
		
		if (x / map_width * 100) == 25:
			print("Putting dirt in stone...")
		if (x / map_width * 100) == 66:
			print("Placing ore...")
		
		for y in range(map_height):
			var cave_value = noiseLand.get_noise_2d(x, y)
			
			if cave_value < cave_tolerance:
				if y < round(land_point):
					set_map(x, y, blocks.AIR)
				elif y == round(land_point):
					set_map(x, y, blocks.GRASS)
				elif y < round(land_point) + (15 + noiseLand.get_noise_1d(x) * 4):
					set_map(x, y, blocks.DIRT)
				else:
					place_ore(x, y)
			else:
				set_map(x, y, blocks.AIR)

func _ready():
	# Configure
	noiseLand.seed = randi()
	noiseLand.octaves = 2
	noiseLand.period = 20.0
	noiseLand.persistence = 0.8
	
	noiseOre.seed = (noiseLand.get_noise_1d(2021) + 1) * 2000000000
	noiseOre.octaves = 3
	noiseOre.period = 7.0
	noiseOre.persistence = 0.8
	
	mapgen()
	
	for x in range(map_width):
		for y in range(map_height):
			$Map.set_cell(x, y, get_map(x, y))
