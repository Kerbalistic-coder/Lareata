extends Node2D

var map = []

export var map_width = 640
export var map_height = 640
export var cave_tolerance = 0.15
var percentThroughMapgen = 0
var go = false
var m

signal mapgen_finished

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
		
		percentThroughMapgen = x
		
		if x % 5 == 4:
			yield()
			#$ProgressBarContainer/ProgressContainer/VBoxContainer/BarMargin/ProgressBar.value = percentThroughMapgen
#			VisualServer.force_draw()
			#get_tree().get_root().update_worlds()
			#propagate_notification(NOTIFICATION_DRAW)
		
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
	go = false
				
#func _process(delta):
#	$ProgressBarContainer/ProgressContainer/VBoxContainer/BarMargin/ProgressBar.value = percentThroughMapgen
#	get_tree().get_root().update_worlds()
#	if go == true:
#		m.resume()
#	print(percentThroughMapgen)

func _ready():
	$ProgressBarContainer.visible = false

func _on_MainMenu_start_game(world_seed):
	# Configure
	noiseLand.seed = world_seed
	noiseLand.octaves = 2
	noiseLand.period = 20.0
	noiseLand.persistence = 0.8
	
	noiseOre.seed = (noiseLand.get_noise_1d(2021) + 1) * 2000000000
	noiseOre.octaves = 3
	noiseOre.period = 7.0
	noiseOre.persistence = 0.8
	
	$ProgressBarContainer.visible = true
	$ProgressBarContainer/ProgressContainer/VBoxContainer/BarMargin/ProgressBar.max_value = map_width
	
	yield(get_tree().create_timer(0.1), "timeout")
	m = mapgen()
	go = true
	
	while go == true:
		$ProgressBarContainer/ProgressContainer/VBoxContainer/BarMargin/ProgressBar.value = percentThroughMapgen
		yield(get_tree().create_timer(0.03), "timeout")
		print(percentThroughMapgen)
		m = m.resume()
	
	for x in range(map_width):
		for y in range(map_height):
			$Map.set_cell(x, y, get_map(x, y))
			
	$ProgressBarContainer.visible = false
	emit_signal("mapgen_finished")
