## Exact static stage placements recovered from the supplied Flash SWF.
##
## Authoritative values are source_twips: the PlaceObject2 MATRIX translateX/
## translateY values for DefineSprite_641 (container_44).  The exported
## 1350x713 map PNGs share a crop whose map pixel (0, 0) is source twips
## (-11110, -11110), so source_twips_to_map is the canonical conversion.
##
## This class intentionally contains data and coordinate helpers only.  It
## does not own collision or scene code.
class_name StageLayoutData
extends RefCounted


const TWIPS_PER_PIXEL: float = 20.0
const MAP_FRAME_ORIGIN: Vector2 = Vector2(555.5, 555.5)
const MAP_FRAME_SIZE: Vector2 = Vector2(1350.0, 713.0)

# The root timeline initially places c_mc at (5309, 5729) twips.  The source
# resets that camera/container position to the rounded (265, 286) after a fall.
const INITIAL_CONTAINER_STAGE_POSITION: Vector2 = Vector2(265.45, 286.45)
const FALL_RESET_CONTAINER_STAGE_POSITION: Vector2 = Vector2(265.0, 286.0)
const FALL_RESET_PLAYER_SOURCE_POSITION: Vector2 = Vector2(-66.0, 33.0)
const ENEMY_DOCK_INITIAL_SOURCE_POSITION: Vector2 = Vector2(-514.0, -181.0)

# Bounds are source display-object bounds in pixels, relative to the instance
# origin.  Flash applyGravity uses hitTestObject against these clips, then
# compares against the instance origin (not necessarily bounds.position).
const ISLAND_LOCAL_BOUNDS: Dictionary = {
	# DefineSprite 452 -> DefineShape 451
	452: Rect2(-246.95, 0.0, 493.0, 78.0),
	# DefineSprite 634 -> DefineShape 633
	634: Rect2(-116.5, -39.0, 233.0, 78.0),
	# DefineSprite 639 -> DefineShape 638
	639: Rect2(-320.5, -39.0, 641.0, 78.0),
}

# Pipe clip bounds from their visible pipe shapes.  The source checks a pipe's
# center and height for entry; helper functions expose both rendered bounds and
# the original center reference.
const PIPE_LOCAL_BOUNDS: Dictionary = {
	# DefineSprite 627 -> DefineShape 626
	627: Rect2(-10.5, -93.5, 21.0, 187.0),
	# DefineSprite 630 -> DefineShape 629
	630: Rect2(-10.5, -61.0, 21.0, 122.0),
}

# Each map frame contains one non-interactive vector decoration shape.  These
# shapes are the original tree groupings, not collision surfaces.  The source
# SVGs remain at original-assets/ffdec/shapes/{character_id}.svg.
const DECORATION_LOCAL_BOUNDS: Dictionary = {
	624: Rect2(-209.95, -212.3, 769.95, 291.3),
	631: Rect2(107.05, -312.3, 169.95, 392.3),
	635: Rect2(-48.0, -214.2, 680.0, 294.2),
	636: Rect2(-366.9, -375.95, 998.9, 453.65),
	640: Rect2(-419.75, -373.95, 953.0, 451.65),
}

const STAGES: Dictionary = {
	1: {
		"player_start_twips": Vector2(-1014, 1016),
		"islands": [
			{"name": "island1_mc", "character_id": 452, "source_twips": Vector2(-39, 1580)},
			{"name": "island2_mc", "character_id": 452, "source_twips": Vector2(10909, 1580)},
			{"name": "island3_mc", "character_id": 452, "source_twips": Vector2(-811, -3026)},
			{"name": "island4_mc", "character_id": 452, "source_twips": Vector2(7010, -6346)},
		],
		"pipes": [
			{"name": "pipe1_mc", "character_id": 627, "source_twips": Vector2(-90, -1150)},
			{"name": "pipe2_mc", "character_id": 630, "source_twips": Vector2(2850, -5126)},
		],
		"decorations": [
			{"depth": 12, "character_id": 624, "source_twips": Vector2(0, 0), "ffdec_svg": "original-assets/ffdec/shapes/624.svg"},
		],
		"building_sites": [
			{"depth": 40, "source_twips": Vector2(-2379, -3006)},
			{"depth": 49, "source_twips": Vector2(-4319, -3006)},
			{"depth": 58, "source_twips": Vector2(2061, 1600)},
			{"depth": 67, "source_twips": Vector2(4581, -6328)},
			{"depth": 76, "source_twips": Vector2(14321, 1600)},
			{"depth": 85, "source_twips": Vector2(-2239, 1600)},
			{"depth": 94, "source_twips": Vector2(12281, 1600)},
			{"depth": 103, "source_twips": Vector2(7781, 1600)},
			{"depth": 112, "source_twips": Vector2(1320, -3006)},
			{"depth": 121, "source_twips": Vector2(6601, -6328)},
			{"depth": 130, "source_twips": Vector2(8661, -6328)},
			{"depth": 139, "source_twips": Vector2(10861, -6328)},
		],
	},
	2: {
		"player_start_twips": Vector2(46, 943),
		"islands": [
			{"name": "island1_mc", "character_id": 452, "source_twips": Vector2(561, 1580)},
			{"name": "island2_mc", "character_id": 452, "source_twips": Vector2(570, -8228)},
			{"name": "island3_mc", "character_id": 452, "source_twips": Vector2(549, -1706)},
			{"name": "island4_mc", "character_id": 452, "source_twips": Vector2(570, -5026)},
		],
		"pipes": [
			{"name": "pipe2_mc", "character_id": 630, "source_twips": Vector2(-3530, -3806)},
			{"name": "pipe1_mc", "character_id": 630, "source_twips": Vector2(1629, -486)},
			{"name": "pipe3_mc", "character_id": 630, "source_twips": Vector2(-409, -7008)},
		],
		"decorations": [
			{"depth": 13, "character_id": 631, "source_twips": Vector2(0, 0), "ffdec_svg": "original-assets/ffdec/shapes/631.svg"},
		],
		"building_sites": [
			{"depth": 40, "source_twips": Vector2(3381, 1600)},
			{"depth": 49, "source_twips": Vector2(-2099, -5008)},
			{"depth": 58, "source_twips": Vector2(-3258, 1600)},
			{"depth": 67, "source_twips": Vector2(-2758, -8208)},
			{"depth": 76, "source_twips": Vector2(-1319, 1600)},
			{"depth": 85, "source_twips": Vector2(4181, -5008)},
			{"depth": 94, "source_twips": Vector2(141, -1686)},
			{"depth": 103, "source_twips": Vector2(-2099, -1686)},
			{"depth": 112, "source_twips": Vector2(4502, -8208)},
			{"depth": 121, "source_twips": Vector2(2562, -8208)},
			{"depth": 130, "source_twips": Vector2(822, -8208)},
		],
	},
	3: {
		"player_start_twips": Vector2(-2894, 863),
		"islands": [
			{"name": "island1_mc", "character_id": 634, "source_twips": Vector2(-2109, 2360)},
			{"name": "island2_mc", "character_id": 634, "source_twips": Vector2(4831, 2360)},
			{"name": "island3_mc", "character_id": 452, "source_twips": Vector2(8109, -3066)},
			{"name": "island4_mc", "character_id": 452, "source_twips": Vector2(-2710, -3064)},
		],
		"pipes": [
			{"name": "pipe1_mc", "character_id": 627, "source_twips": Vector2(-3489, -1176)},
			{"name": "pipe2_mc", "character_id": 627, "source_twips": Vector2(5570, -1176)},
		],
		"decorations": [
			{"depth": 18, "character_id": 635, "source_twips": Vector2(0, 0), "ffdec_svg": "original-assets/ffdec/shapes/635.svg"},
		],
		"building_sites": [
			{"depth": 40, "source_twips": Vector2(-6379, -3046)},
			{"depth": 49, "source_twips": Vector2(-2198, 1600)},
			{"depth": 58, "source_twips": Vector2(-2198, -3046)},
			{"depth": 67, "source_twips": Vector2(941, -3046)},
			{"depth": 76, "source_twips": Vector2(7401, -3046)},
			{"depth": 85, "source_twips": Vector2(4221, -3046)},
			{"depth": 94, "source_twips": Vector2(3482, 1600)},
			{"depth": 103, "source_twips": Vector2(-4699, -3046)},
			{"depth": 112, "source_twips": Vector2(9481, -3046)},
		],
	},
	4: {
		"player_start_twips": Vector2(-2474, -337),
		"islands": [
			{"name": "island1_mc", "character_id": 634, "source_twips": Vector2(-769, -5519)},
			{"name": "island2_mc", "character_id": 634, "source_twips": Vector2(2781, -819)},
			{"name": "island3_mc", "character_id": 452, "source_twips": Vector2(-6150, -2919)},
			{"name": "island4_mc", "character_id": 452, "source_twips": Vector2(-2710, 1536)},
		],
		"pipes": [
			{"name": "pipe1_mc", "character_id": 630, "source_twips": Vector2(-2330, -5079)},
			{"name": "pipe2_mc", "character_id": 627, "source_twips": Vector2(-3189, -1049)},
			{"name": "pipe3_mc", "character_id": 630, "source_twips": Vector2(1550, -379)},
		],
		"decorations": [
			{"depth": 21, "character_id": 636, "source_twips": Vector2(0, 0), "ffdec_svg": "original-assets/ffdec/shapes/636.svg"},
		],
		"building_sites": [
			{"depth": 40, "source_twips": Vector2(-860, -6279)},
			{"depth": 49, "source_twips": Vector2(-458, 1554)},
			{"depth": 58, "source_twips": Vector2(-7638, -2899)},
			{"depth": 67, "source_twips": Vector2(-9738, -2899)},
			{"depth": 76, "source_twips": Vector2(3142, -1594)},
			{"depth": 85, "source_twips": Vector2(-5199, -2899)},
		],
	},
	5: {
		"player_start_twips": Vector2(-2474, -337),
		"islands": [
			{"name": "island1_mc", "character_id": 639, "source_twips": Vector2(1190, 2316)},
			{"name": "island2_mc", "character_id": 634, "source_twips": Vector2(-6489, -5479)},
			{"name": "island3_mc", "character_id": 639, "source_twips": Vector2(1190, -2143)},
			{"name": "island4_mc", "character_id": 634, "source_twips": Vector2(8791, -5479)},
		],
		"pipes": [
			{"name": "pipe1_mc", "character_id": 630, "source_twips": Vector2(7160, -5039)},
			{"name": "pipe2_mc", "character_id": 627, "source_twips": Vector2(-3189, -1049)},
			{"name": "pipe3_mc", "character_id": 630, "source_twips": Vector2(-4760, -5039)},
		],
		"decorations": [
			{"depth": 24, "character_id": 640, "source_twips": Vector2(0, 0), "ffdec_svg": "original-assets/ffdec/shapes/640.svg"},
		],
		"building_sites": [
			{"depth": 40, "source_twips": Vector2(-798, 1554)},
			{"depth": 49, "source_twips": Vector2(3521, -2899)},
			{"depth": 58, "source_twips": Vector2(1421, -2899)},
			{"depth": 67, "source_twips": Vector2(-6888, -6254)},
			{"depth": 76, "source_twips": Vector2(5581, -2899)},
			{"depth": 85, "source_twips": Vector2(5062, 1554)},
			{"depth": 94, "source_twips": Vector2(-179, -2899)},
			{"depth": 103, "source_twips": Vector2(-2059, -2899)},
			{"depth": 112, "source_twips": Vector2(8572, -6254)},
		],
	},
}


static func source_twips_to_map(source_twips: Vector2) -> Vector2:
	return source_twips / TWIPS_PER_PIXEL + MAP_FRAME_ORIGIN


static func source_pixels_to_map(source_pixels: Vector2) -> Vector2:
	return source_pixels + MAP_FRAME_ORIGIN


static func map_to_source_twips(map_position: Vector2) -> Vector2:
	return (map_position - MAP_FRAME_ORIGIN) * TWIPS_PER_PIXEL


static func map_position(entry: Dictionary) -> Vector2:
	return source_twips_to_map(entry.get("source_twips", Vector2.ZERO))


static func local_island_bounds(character_id: int) -> Rect2:
	return ISLAND_LOCAL_BOUNDS.get(character_id, Rect2())


static func local_pipe_bounds(character_id: int) -> Rect2:
	return PIPE_LOCAL_BOUNDS.get(character_id, Rect2())


static func local_decoration_bounds(character_id: int) -> Rect2:
	return DECORATION_LOCAL_BOUNDS.get(character_id, Rect2())


static func island_bounds_in_map(island: Dictionary) -> Rect2:
	var bounds := local_island_bounds(int(island.get("character_id", 0)))
	return Rect2(map_position(island) + bounds.position, bounds.size)


static func pipe_bounds_in_map(pipe: Dictionary) -> Rect2:
	var bounds := local_pipe_bounds(int(pipe.get("character_id", 0)))
	return Rect2(map_position(pipe) + bounds.position, bounds.size)


static func decoration_bounds_in_map(decoration: Dictionary) -> Rect2:
	var bounds := local_decoration_bounds(int(decoration.get("character_id", 0)))
	return Rect2(map_position(decoration) + bounds.position, bounds.size)


static func pipe_endpoints_in_map(pipe: Dictionary) -> Dictionary:
	var bounds := pipe_bounds_in_map(pipe)
	return {
		"top": Vector2(bounds.get_center().x, bounds.position.y),
		"bottom": Vector2(bounds.get_center().x, bounds.end.y),
	}


static func island_dock_edge_points_in_map(island: Dictionary, dock_half_width: float) -> Dictionary:
	var bounds := island_bounds_in_map(island)
	return {
		"left": Vector2(bounds.position.x - dock_half_width, bounds.position.y),
		"right": Vector2(bounds.end.x + dock_half_width, bounds.position.y),
	}


static func fall_reset_player_in_map() -> Vector2:
	return source_pixels_to_map(FALL_RESET_PLAYER_SOURCE_POSITION)


static func enemy_dock_initial_position_in_map() -> Vector2:
	return source_pixels_to_map(ENEMY_DOCK_INITIAL_SOURCE_POSITION)


static func layout_for(stage_id: int) -> Dictionary:
	return STAGES.get(stage_id, {}).duplicate(true)


static func player_start_in_map(stage_id: int) -> Vector2:
	var layout := layout_for(stage_id)
	return source_twips_to_map(layout.get("player_start_twips", Vector2.ZERO))


static func building_sites_for(stage_id: int) -> Array:
	var layout := layout_for(stage_id)
	return layout.get("building_sites", []).duplicate(true)
