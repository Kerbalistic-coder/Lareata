extends Node2D

var map = []
var background_map = []
var light_map = []
var light_sources = []

export var map_width = 640
export var map_height = 640
export var cave_tolerance = 0

export var player_x = 0
export var player_y = 0

var percentThroughMapgen = 0
var go = true
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
export var transparent_blocks = [
	blocks.AIR,
	blocks.NORMAL_TREE_TRUNK,
	blocks.TREE_LEAVES
]


var noiseLand = OpenSimplexNoise.new()
var noiseOre = OpenSimplexNoise.new()


func set_map(x, y, item):
	map[(x * map_height) + y] = item
	
func get_map(x, y):
	return map[(x * map_height) + y]
	
func set_background_map(x, y, item):
	background_map[(x * map_height) + y] = item
	
func get_background_map(x, y):
	return background_map[(x * map_height) + y]
	
func set_light_map(x, y, item):
	light_map[(x * map_height) + y] = item
	
func get_light_map(x, y):
	return light_map[(x * map_height) + y]
	
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
		background_map.append(null)
		
	var land_point = 30
	
	print("Carving landscape...")
	
	for x in range(map_width):
		var change = noiseLand.get_noise_1d(x) * 4
		land_point += change
		
		percentThroughMapgen = x
		
		if x % 5 == 4:
			yield()
		
		for y in range(map_height):
			var cave_value = noiseLand.get_noise_2d(x, y)
			
			if cave_value < cave_tolerance:
				if y < round(land_point):
					set_map(x, y, blocks.AIR)
					set_background_map(x, y, blocks.AIR)
				elif y == round(land_point):
					set_map(x, y, blocks.GRASS)
					set_background_map(x, y, blocks.GRASS)
				elif y < round(land_point) + (15 + noiseLand.get_noise_1d(x) * 4):
					set_map(x, y, blocks.DIRT)
					set_background_map(x, y, blocks.DIRT)
				else:
					place_ore(x, y)
					set_background_map(x, y, blocks.STONE)
			else:
				set_map(x, y, blocks.AIR)
				if y < round(land_point):
					set_background_map(x, y, blocks.AIR)
				elif y == round(land_point):
					set_background_map(x, y, blocks.GRASS)
				elif y < round(land_point) + (15 + noiseLand.get_noise_1d(x) * 4):
					set_background_map(x, y, blocks.DIRT)
				else:
					set_background_map(x, y, blocks.STONE)
	go = false
				
func _process(delta):
	if go == false:
		process_light($LightMap.world_to_map(Vector2(player_x - 512, player_y - 256)), $LightMap.world_to_map(Vector2(player_x + 512, player_y + 256)))

func process_light(upper_left_corner, lower_right_corner):
	# Init Stuff
	var x0 = upper_left_corner.x
	var y0 = upper_left_corner.y
	var x1 = lower_right_corner.x
	var y1 = lower_right_corner.y

	if len(light_map) == 0:
		for i in range(0, map_width * map_height):
			light_map.append(3)
		set_light_map(x0 + 1, y0 + 1, "light")

	# Lights
	for light in light_sources:
		if light[0] > x0 and light[0] < x1:
			if light[1] > y0 and light[1] < y1:
				set_light_map(light[0], light[1], "light")

	# Lighting
	for xrel in range(0, x1 - x0):
		for yrel in range(0, y1 - y0):
			if str(get_light_map(x0 + xrel, y0 + yrel)) != "light":
				var buddies = [3,3,3,3,3,3,3,3]
				var natural_glimmers = 0
				natural_glimmers = .2
				buddies[0] = get_light_map(x0 + xrel - 1, y0 + yrel - 1 + natural_glimmers)
				buddies[1] = get_light_map(x0 + xrel - 1, y0 + yrel)
				buddies[2] = get_light_map(x0 + xrel - 1, y0 + yrel + 1 + natural_glimmers)
				natural_glimmers = .1
				buddies[3] = get_light_map(x0 + xrel, y0 + yrel - 1 + natural_glimmers)
				buddies[4] = get_light_map(x0 + xrel, y0 + yrel + 1 + natural_glimmers)
				buddies[5] = get_light_map(x0 + xrel + 1, y0 + yrel - 1 + natural_glimmers)
				natural_glimmers = .5
				buddies[6] = get_light_map(x0 + xrel + 1, y0 + yrel + natural_glimmers)
				buddies[7] = get_light_map(x0 + xrel + 1, y0 + yrel +1 + natural_glimmers)
				
				var average
				
				average = buddies.min()
				if "light" in buddies:
					average = -3
				average = average
				var buddies_has_transparent = false
				if (get_map(x0 + xrel - 1, y0 + yrel) in transparent_blocks) or (get_map(x0 + xrel + 1, y0 + yrel) in transparent_blocks) or (get_map(x0 + xrel - 1, y0 + yrel - 1) in transparent_blocks) or (get_map(x0 + xrel, y0 + yrel + 1) in transparent_blocks):
					buddies_has_transparent = true
				if (not (get_map(x0 + xrel, y0 + yrel) in transparent_blocks)) and (average < 3) and (not buddies_has_transparent):
					average = average + 1
#				elif (not (get_background_map(x0 + xrel, y0 + yrel) in transparent_blocks)) and (average < 3) and (get_map(x0 + xrel, y0 + yrel) in transparent_blocks):
#					average = average + 0.5
				set_light_map(x0 + xrel, y0 + yrel, average)
				
				# Set Light Values
				# if average != get_light_map(x0 + xrel, y0 + yrel):
				$LightMap.set_cell(x0 + xrel, y0 + yrel, round(average))

func _ready():
	$ProgressBarContainer.visible = false

func _on_MainMenu_start_game(world_seed):
	print(int("light"))
	
	# Configure
	noiseLand.seed = world_seed
	noiseLand.octaves = 2
	noiseLand.period = 10.0
	noiseLand.persistence = 0.8
	
	noiseOre.seed = (noiseLand.get_noise_1d(2021) + 1) * 2000000000
	noiseOre.octaves = 3
	noiseOre.period = 3.5
	noiseOre.persistence = 0.8
	
	$ProgressBarContainer.visible = true
	$ProgressBarContainer/ProgressContainer/VBoxContainer/BarMargin/ProgressBar.max_value = map_width
	
	# Create "sun layer"
	for i in range(0, map_width):
		light_sources.append([i, 0])
	
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
			$BackgroundMap.set_cell(x, y, get_background_map(x, y))
			
	$ProgressBarContainer.visible = false
	emit_signal("mapgen_finished")

static func sum_array(array):
	var sum = 0.0
	for element in array:
		 sum += int(element)
	return sum


func _on_Player_mine(mousepos):
	var pos = $Map.world_to_map(mousepos)
	$Map.set_cell(pos.x, pos.y, blocks.AIR)
