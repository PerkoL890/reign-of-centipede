## Immutable gameplay configuration recovered from the supplied Flash game.
##
## This class deliberately contains no scene, UI, input, or game-loop code.
## Runtime code should treat returned dictionaries as per-session copies.
class_name GameData
extends RefCounted


# The source increments its root counter once per ENTER_FRAME at 30 fps.
const TICKS_PER_SECOND: int = 30
const WAVE_INTERVAL_TICKS: int = 900
const STARTING_WAVE: int = 1
const LAST_COMPLETED_WAVE: int = 65
const VICTORY_TICK: int = 58_500 # 32 minutes, 30 seconds at 30 Hz.

# The original checks loss before win. A controller should retain that ordering.
const STARTING_PLAYER_HEALTH: int = 150
const PLAYER_MAX_HEALTH: int = 150
const PLAYER_GRAVITY: float = 1.0
const PLAYER_HORIZONTAL_SPEED: float = 3.0
const PLAYER_JUMP_SPEED: float = 11.0
const PLAYER_FRICTION: float = 0.95
const PLAYER_FALL_RESET_Y: float = 700.0
const PLAYER_FALL_DAMAGE: int = 45
const PIPE_PULL_SPEED: float = 10.0

const CAMERA_DEAD_ZONE: Rect2 = Rect2(200.0, 150.0, 200.0, 150.0)
const BACKGROUND_PARALLAX_DIVISOR: float = 5.0
const SKY_PARALLAX_DIVISOR: float = 12.0

# MainTimeline fires at cursor.height / 8, rather than directly at its 15 / 22.5
# / 30 cursor-expansion values.  These are the source cursor's actual bounds
# with the recovered 9px center and corner bitmaps.
const STANDING_AIM_SPREAD_DEGREES: float = 5.727029
const MOVING_AIM_SPREAD_DEGREES: float = 7.602029
const JUMPING_AIM_SPREAD_DEGREES: float = 9.477029

# Small/orange chasing fliers need a lower screen-space travel rate than the
# larger island-targeting shooting fliers.  Keep this isolated to their
# movement mode so later-wave special enemies retain their own pacing.
const ORDINARY_FLYING_SPEED_SCALE: float = 0.60

const MAX_FRIENDLIES: int = 40
const MAX_DOCKS: int = 4
const MAX_ENEMIES_NOMINAL: int = 60
# Legacy off-by-one: eviction occurs only when length is already greater than 60.
const MAX_ENEMIES_SOURCE_COMPATIBLE: int = 61

const BALLOON_SPAWN_INTERVAL_TICKS: int = 400
const BALLOON_SPAWN_CHANCE: float = 0.60
const COIN_LIFETIME_TICKS: int = 600
const COIN_DESPAWN_Y: float = 300.0
const HEART_HEAL: int = 10
const HEART_SCORE: int = 5
const CRATE_HEALTH: int = 15
const CRATE_COIN_DROP_CHANCE: float = 0.80
const CRATE_HEARTS_REQUIRE_COIN_DROP: bool = true
const CRATE_MIN_COINS: int = 5
const CRATE_MAX_COINS: int = 26
const CRATE_MIN_HEARTS: int = 1
const CRATE_MAX_HEARTS: int = 4
const CRATE_SCORE: int = 30

# Frames 1-5 are playable map frames. Frame 6 is the original blank/reset frame.
const STAGE_COUNT: int = 5
const ALL_STAGES_DIRECTLY_SELECTABLE: bool = true
const STAGES: Dictionary = {
	1: {
		"id": 1,
		"map_frame": 1,
		"building_site_count": 12,
		"slot_count": 12,
		"starting_money": 70,
		"has_pipe3": false,
		"island_count": 4,
	},
	2: {
		"id": 2,
		"map_frame": 2,
		"building_site_count": 11,
		"slot_count": 11,
		"starting_money": 0,
		"has_pipe3": true,
		"island_count": 4,
	},
	3: {
		"id": 3,
		"map_frame": 3,
		"building_site_count": 9,
		"slot_count": 9,
		"starting_money": 0,
		"has_pipe3": false,
		"island_count": 4,
	},
	4: {
		"id": 4,
		"map_frame": 4,
		"building_site_count": 6,
		"slot_count": 6,
		"starting_money": 0,
		"has_pipe3": true,
		"island_count": 4,
	},
	5: {
		"id": 5,
		"map_frame": 5,
		"building_site_count": 9,
		"slot_count": 9,
		"starting_money": 0,
		"has_pipe3": true,
		"island_count": 4,
	},
}

const MAP_RESET_FRAME: int = 6


# s_rate is the original shootCounter modulus cadence, in simulation ticks.
# The starter pistol is equipped free despite retaining its menu price of 30.
const STARTER_WEAPON_ID: String = "pistol"
const WEAPON_ORDER: Array[String] = [
	"pistol",
	"desert_eagle",
	"mac10",
	"shotgun",
	"ump",
	"m16",
	"auto_shotgun",
	"p90",
	"aug",
	"flamer",
	"chaingun",
	"bazooka",
]
const WEAPONS: Dictionary = {
	"pistol": {
		"display_name": "Pistol",
		"power": 2,
		"s_rate": 8,
		"cost": 30,
		"amount": 1,
		"projectile_kind": "bullet",
	},
	"desert_eagle": {
		"display_name": "Desert Eagle",
		"power": 4,
		"s_rate": 8,
		"cost": 60,
		"amount": 1,
		"projectile_kind": "bullet",
	},
	"mac10": {
		"display_name": "Mac10",
		"power": 3,
		"s_rate": 4,
		"cost": 120,
		"amount": 1,
		"projectile_kind": "bullet",
	},
	"shotgun": {
		"display_name": "Shotgun",
		"power": 2,
		"s_rate": 11,
		"cost": 180,
		"amount": 7,
		"projectile_kind": "bullet",
	},
	"ump": {
		"display_name": "UMP",
		"power": 7,
		"s_rate": 4,
		"cost": 250,
		"amount": 1,
		"projectile_kind": "bullet",
	},
	"m16": {
		"display_name": "M16",
		"power": 11,
		"s_rate": 5,
		"cost": 360,
		"amount": 1,
		"projectile_kind": "bullet",
	},
	"auto_shotgun": {
		"display_name": "Auto Shotgun",
		"power": 4,
		"s_rate": 7,
		"cost": 450,
		"amount": 5,
		"projectile_kind": "bullet",
	},
	"p90": {
		"display_name": "P90",
		"power": 11,
		"s_rate": 3,
		"cost": 640,
		"amount": 1,
		"projectile_kind": "bullet",
	},
	"aug": {
		"display_name": "AUG",
		"power": 25,
		"s_rate": 5,
		"cost": 750,
		"amount": 1,
		"projectile_kind": "bullet",
	},
	"flamer": {
		"display_name": "Flamer",
		"power": 12,
		"s_rate": 6,
		"cost": 925,
		"amount": 1,
		"projectile_kind": "fireball",
		# Source-compatible: changed art/data only; no damage-over-time loop.
		"has_damage_over_time": false,
	},
	"chaingun": {
		"display_name": "Chaingun",
		# Each round hits hard, but Main.gd makes sustained fire wildly inaccurate
		# and physically difficult to control.
		"power": 22,
		"s_rate": 2,
		"cost": 1100,
		"amount": 1,
		"projectile_kind": "bullet",
	},
	"bazooka": {
		"display_name": "Bazooka",
		"power": 60,
		"s_rate": 7,
		"cost": 1250,
		"amount": 1,
		"projectile_kind": "missile",
		# Source-compatible: changed art/data only; no area-damage implementation.
		"has_area_damage": false,
	},
}

const BULLET_SPEED: float = 20.0
const BULLET_LIFETIME_TICKS: int = 25
# Keep this ordering in the collision implementation.
const BULLET_COLLISION_ORDER: Array[String] = [
	"enemy",
	"dock",
	"balloon",
	"non_floating_crate",
]


# Construction is restricted to pre-authored sites. Completing a building needs
# finished_health * 3 construction health; player building and repair actions
# are deliberately per-tick quantities from the original.
const BUILD_TOTAL_HEALTH_MULTIPLIER: int = 3
const PLAYER_BUILD_HEALTH_PER_TICK: int = 2
const PLAYER_REPAIR_HEALTH_PER_TICK: int = 1
const BUILDING_DESTROYED_STATE: String = "rubble"
const BUILDING_PURCHASE_ORDER: Array[String] = [
	"small_shack",
	"medium_shack",
	"carpenter_house",
	"hospital",
	"green_building",
	"tall_building",
]

const BUILDINGS: Dictionary = {
	"rubble": {
		"display_name": "Rubble",
		"cost": 1,
		"spawn_interval_ticks": 99_999,
		"finished_health": 20,
		"role": "fallback",
		"purchasable": false,
	},
	"small_shack": {
		"display_name": "Small Shack",
		"cost": 70,
		"spawn_interval_ticks": 630,
		"finished_health": 330,
		"role": "fighter",
		"friendly_kind": "yellow_man",
		"defender_weapon_id": "pistol",
	},
	"medium_shack": {
		"display_name": "Medium Shack",
		"cost": 140,
		"spawn_interval_ticks": 540,
		"finished_health": 425,
		"role": "fighter",
		"friendly_kind": "green_man",
		# Legacy mismatch: menu claims Mac10, actual defender receives Desert Eagle.
		"menu_weapon_label": "mac10",
		"defender_weapon_id": "desert_eagle",
	},
	"carpenter_house": {
		"display_name": "Carpenter House",
		"cost": 110,
		"spawn_interval_ticks": 650,
		"finished_health": 440,
		"role": "carpenter",
		"friendly_kind": "carpenter",
	},
	"hospital": {
		"display_name": "Hospital",
		"cost": 115,
		"spawn_interval_ticks": 660,
		"finished_health": 700,
		"role": "nurse",
		"friendly_kind": "nurse",
	},
	"green_building": {
		"display_name": "Green Building",
		"cost": 250,
		"spawn_interval_ticks": 750,
		"finished_health": 800,
		"role": "fighter",
		"friendly_kind": "old_man",
		"defender_weapon_id": "shotgun",
	},
	"tall_building": {
		"display_name": "Tall Building",
		"cost": 300,
		"spawn_interval_ticks": 800,
		"finished_health": 900,
		"role": "fighter",
		"friendly_kind": "red_man",
		"defender_weapon_id": "ump",
	},
}

const FRIENDLY_MOVE_SPEED: float = 1.5
const FRIENDLY_TOTAL_HEALTH: int = 10
const FRIENDLY_ATTACK_RATE_TICKS: int = 9
const FRIENDLY_RANGE: float = 350.0
const CARPENTER_BUILD_HEALTH: int = 7
const CARPENTER_BUILD_INTERVAL_TICKS: int = 9
const NURSE_HEART_INTERVAL_TICKS: int = 300
const NURSE_NPC_HEAL_INTERVAL_TICKS: int = 90
const NURSE_NPC_HEAL_RANGE: float = 115.0
const NURSE_NPC_HEAL_AMOUNT: float = 3.0
# Source-compatible: nurse creates a pickup; it does not cast a healing beam.
const NURSE_USES_HEART_PICKUP: bool = true


# unlock_tick records the cumulative random pool in the original timer bands.
# The stage does not use pre-authored wave lists.
const ENEMIES: Dictionary = {
	"small_green": {
		"display_name": "Small Green",
		"health": 9,
		"worth": 3,
		"contact_power": 3,
		"movement": "walk",
		"base_speed": 1.8,
		"unlock_tick": 0,
		"can_shoot": false,
	},
	"small_flying": {
		"display_name": "Small Flying",
		"health": 10,
		"worth": 3,
		"contact_power": 3,
		"movement": "flying",
		"base_speed": 1.7,
		"unlock_tick": 0,
		"can_shoot": false,
	},
	"snail": {
		"display_name": "Snail",
		"health": 20,
		"worth": 4,
		"contact_power": 3,
		"movement": "walk",
		"base_speed": 1.2,
		"unlock_tick": 1_800,
		"can_shoot": false,
	},
	"orange_flying": {
		"display_name": "Orange Flying",
		"health": 30,
		"worth": 7,
		"contact_power": 4,
		"movement": "flying",
		"base_speed": 1.9,
		"unlock_tick": 1_800,
		"can_shoot": false,
	},
	"ladybug": {
		"display_name": "Ladybug",
		"health": 50,
		"worth": 8,
		"contact_power": 5,
		"movement": "walk",
		"base_speed": 2.1,
		"unlock_tick": 7_200,
		"can_shoot": false,
	},
	"flying_big": {
		"display_name": "Flying Big",
		"health": 65,
		"worth": 9,
		"contact_power": 6,
		"movement": "flying_shoot",
		"base_speed": 2.0,
		"unlock_tick": 7_200,
		"can_shoot": true,
	},
	"praying_mantis": {
		"display_name": "Praying Mantis",
		"health": 70,
		"worth": 10,
		"contact_power": 6,
		"movement": "walk",
		"base_speed": 2.0,
		"unlock_tick": 7_200,
		"can_shoot": false,
	},
	"flying_very_big": {
		"display_name": "Flying Very Big",
		"health": 240,
		"worth": 11,
		"contact_power": 7,
		"movement": "flying_shoot",
		"base_speed": 2.1,
		"unlock_tick": 14_400,
		"can_shoot": true,
	},
	"flying_blue": {
		"display_name": "Flying Blue",
		"health": 540,
		"worth": 14,
		"contact_power": 14,
		"movement": "flying_shoot",
		"base_speed": 2.4,
		"unlock_tick": 14_400,
		"can_shoot": true,
	},
	"purple_centipede": {
		"display_name": "Purple Centipede",
		"health": 300,
		"worth": 14,
		"contact_power": 8,
		"movement": "walk",
		"base_speed": 2.2,
		"unlock_tick": 21_600,
		"can_shoot": false,
	},
	"blue_centipede": {
		"display_name": "Blue Centipede",
		"health": 500,
		"worth": 16,
		"contact_power": 9,
		"movement": "walk",
		"base_speed": 2.0,
		"unlock_tick": 21_600,
		"can_shoot": false,
	},
	"green_centipede": {
		"display_name": "Green Centipede",
		"health": 750,
		"worth": 17,
		"contact_power": 10,
		"movement": "walk",
		"base_speed": 1.9,
		"unlock_tick": 28_800,
		"can_shoot": false,
	},
	"flying_mech": {
		"display_name": "Flying Mech",
		"health": 2_000,
		"worth": 23,
		"contact_power": 14,
		"movement": "flying_shoot",
		"base_speed": 2.9,
		"unlock_tick": 37_800,
		"can_shoot": true,
	},
}

const ENEMY_SPEED_VARIANCE: float = 0.20
const ENEMY_TARGET_OBJECTS_CHANCE: float = 0.40
const ENEMY_TARGET_FRIENDLY_CHANCE: float = 0.80
const ENEMY_TARGET_BUILDING_CHANCE: float = 0.20
const ENEMY_TARGET_ATTACK_DAMAGE: int = 6
const ENEMY_CONTACT_INTERVAL_TICKS: int = 25
const ENEMY_TARGET_ATTACK_INTERVAL_TICKS: int = 25
const ENEMY_TARGET_ATTACK_RANGE: float = 30.0
const ENEMY_FALL_DESPAWN_Y: float = 300.0
const ENEMY_SHOOT_CHECK_INTERVAL_TICKS: int = 60

const LASER_SPEED: float = 9.0
const LASER_SIZE: Vector2 = Vector2(121.0, 49.0)
const LASER_LIFETIME_TICKS: int = 200
const LASER_BUILDING_DAMAGE_PER_TICK: int = 1
const LASER_FRIENDLY_DAMAGE_PER_TICK: int = 1
const LASER_PLAYER_DAMAGE: int = 1
const LASER_PLAYER_DAMAGE_INTERVAL_TICKS: int = 2


# A dock selects one of four islands and a random side. Failed placement retries
# up to 20 times before deleting both dock and portal.
const DOCK_PLACEMENT_ATTEMPTS: int = 20
const DOCKS: Dictionary = {
	"blue": {
		"display_name": "Blue Dock",
		"health": 90,
		"spawn_interval_ticks": 190,
		"worth": 25,
	},
	"purple": {
		"display_name": "Purple Dock",
		"health": 260,
		"spawn_interval_ticks": 145,
		"worth": 25,
	},
	"red": {
		"display_name": "Red Dock",
		"health": 450,
		"spawn_interval_ticks": 130,
		"worth": 25,
	},
	"green": {
		"display_name": "Green Dock",
		"health": 650,
		"spawn_interval_ticks": 155,
		"worth": 25,
	},
}

# Legacy reward discrepancy: an eliminated dock yields 100 score and displays
# "+75", while its internal worth is 25 and it drops no coin.
const DOCK_DESTROY_SCORE: int = 100
const DOCK_DESTROY_DISPLAY_VALUE: int = 75

# Exact handleEnemies cadence. Every dock event retains its base period and
# fires at the stage-dependent phase: tick % base_interval_ticks equals
# stage_id * stage_tick_reduction.
#
# dock_enemy_distribution defines the random enemy type generated by the newly
# created EnemyDock. It is not an additional ordinary enemy-spawn event.
const SPAWN_BANDS: Array[Dictionary] = [
	{
		"wave_min": 1,
		"wave_max": 11,
		"enemy_events": [
			{"enemy_id": "small_flying", "interval_ticks": 200, "spawn_kind": "player_relative"},
			{
				"enemy_id": "flying_big",
				"interval_ticks": 1350,
				"minimum_wave": 6,
				"spawn_kind": "fixed",
			},
		],
		"dock_event": {
			"dock_id": "blue",
			"base_interval_ticks": 1200,
			"stage_tick_reduction": 50,
			"dock_enemy_distribution": [
				{"enemy_id": "small_green", "weight": 1.0},
			],
		},
	},
	{
		"wave_min": 12,
		"wave_max": 17,
		"enemy_events": [
			{"enemy_id": "small_flying", "interval_ticks": 140, "spawn_kind": "player_relative"},
			{"enemy_id": "flying_big", "interval_ticks": 740, "spawn_kind": "fixed"},
		],
		"dock_event": {
			"dock_id": "purple",
			"base_interval_ticks": 1250,
			"stage_tick_reduction": 50,
			"dock_enemy_distribution": [
				{"enemy_id": "ladybug", "weight": 0.5},
				{"enemy_id": "snail", "weight": 0.5},
			],
		},
	},
	{
		"wave_min": 18,
		"wave_max": 25,
		"enemy_events": [
			{"enemy_id": "orange_flying", "interval_ticks": 120, "spawn_kind": "player_relative"},
			{"enemy_id": "flying_very_big", "interval_ticks": 550, "spawn_kind": "fixed"},
		],
		"dock_event": {
			"dock_id": "red",
			"base_interval_ticks": 950,
			"stage_tick_reduction": 50,
			"dock_enemy_distribution": [
				{"enemy_id": "ladybug", "weight": 0.35},
				{"enemy_id": "praying_mantis", "weight": 0.65},
			],
		},
	},
	{
		"wave_min": 26,
		"wave_max": 37,
		"enemy_events": [
			{"enemy_id": "orange_flying", "interval_ticks": 110, "spawn_kind": "player_relative"},
			{"enemy_id": "flying_blue", "interval_ticks": 620, "spawn_kind": "fixed"},
		],
		"dock_event": {
			"dock_id": "green",
			"base_interval_ticks": 980,
			"stage_tick_reduction": 50,
			"dock_enemy_distribution": [
				{"enemy_id": "purple_centipede", "weight": 0.5},
				{"enemy_id": "praying_mantis", "weight": 0.5},
			],
		},
	},
	{
		"wave_min": 38,
		"wave_max": 49,
		"enemy_events": [
			{"enemy_id": "orange_flying", "interval_ticks": 120, "spawn_kind": "player_relative"},
			{"enemy_id": "flying_blue", "interval_ticks": 660, "spawn_kind": "fixed"},
		],
		"dock_event": {
			"dock_id": "green",
			"base_interval_ticks": 1130,
			"stage_tick_reduction": 50,
			"dock_enemy_distribution": [
				{"enemy_id": "purple_centipede", "weight": 0.5},
				{"enemy_id": "blue_centipede", "weight": 0.5},
			],
		},
	},
	{
		"wave_min": 50,
		"enemy_events": [
			{"enemy_id": "orange_flying", "interval_ticks": 160, "spawn_kind": "player_relative"},
			{"enemy_id": "flying_mech", "interval_ticks": 3000, "spawn_kind": "fixed"},
		],
		"dock_event": {
			"dock_id": "green",
			"base_interval_ticks": 1300,
			"stage_tick_reduction": 50,
			"dock_enemy_distribution": [
				{"enemy_id": "blue_centipede", "weight": 0.5},
				{"enemy_id": "green_centipede", "weight": 0.5},
			],
		},
	},
]


# Session-only state: the source has no persistence, unlocks, checkpoints, or
# saved purchases. Its menu reset path also leaves counter and shootCounter
# intact; a controller can opt into that quirk explicitly.
const HAS_PERSISTENT_SAVE_DATA: bool = false
const MENU_RESET_PRESERVES_COUNTERS: bool = true

const SOURCE_COMPATIBILITY_NOTES: Dictionary = {
	"victory": "Win when wave is greater than 65; it is timer-based, not a boss.",
	"enemy_cap": "Evict only when the existing count is greater than 60.",
	"starter_pistol": "Equipped free even though the menu lists cost 30.",
	"medium_shack": "Menu says Mac10; spawned green defender uses Desert Eagle.",
	"nurse": "Creates hearts every 300 ticks rather than using its described beam.",
	"dock_reward": "Shows +75 and awards 100 score while internal worth is 25.",
	"flamer": "Projectile art only; no recovered damage-over-time loop.",
	"bazooka": "Projectile art only; no recovered area-damage loop.",
}


static func get_stage(stage_id: int) -> Dictionary:
	return _copy_entry(STAGES, stage_id)


static func get_weapon(weapon_id: String) -> Dictionary:
	return _copy_entry(WEAPONS, weapon_id)


static func get_building(building_id: String) -> Dictionary:
	return _copy_entry(BUILDINGS, building_id)


static func get_enemy(enemy_id: String) -> Dictionary:
	return _copy_entry(ENEMIES, enemy_id)


static func get_dock(dock_id: String) -> Dictionary:
	return _copy_entry(DOCKS, dock_id)


static func spawn_band_for_wave(wave: int) -> Dictionary:
	for raw_band in SPAWN_BANDS:
		var band: Dictionary = raw_band
		if wave < int(band["wave_min"]):
			continue
		if not band.has("wave_max") or wave <= int(band["wave_max"]):
			return band.duplicate(true)
	return {}


static func dock_creation_interval_for_stage(wave: int, stage_id: int) -> int:
	var band: Dictionary = spawn_band_for_wave(wave)
	var dock_event: Dictionary = band.get("dock_event", {})
	if dock_event.is_empty():
		return 0
	return int(dock_event["base_interval_ticks"])


# These methods expose the exact source cadence without placing spawning,
# random selection, or scene ownership in this data class. The bands are
# mutually exclusive by wave; do not accumulate their periodic events.
static func scheduled_enemy_events(wave: int, tick: int) -> Array[Dictionary]:
	var due_events: Array[Dictionary] = []
	if tick <= 0:
		return due_events
	var band: Dictionary = spawn_band_for_wave(wave)
	for raw_event in band.get("enemy_events", []):
		var event: Dictionary = raw_event
		var minimum_wave: int = int(event.get("minimum_wave", 1))
		var interval: int = int(event["interval_ticks"])
		if wave >= minimum_wave and tick % interval == 0:
			due_events.append(event.duplicate(true))
	return due_events


static func scheduled_dock_event(wave: int, tick: int, stage_id: int) -> Dictionary:
	if tick <= 0:
		return {}
	var band: Dictionary = spawn_band_for_wave(wave)
	var dock_event: Dictionary = band.get("dock_event", {})
	var interval: int = dock_creation_interval_for_stage(wave, stage_id)
	var phase: int = stage_id * int(dock_event.get("stage_tick_reduction", 0))
	if interval > 0 and tick % interval == phase:
		return dock_event.duplicate(true)
	return {}


static func eligible_enemy_ids(tick: int) -> Array[String]:
	# This reflects the high-level timing table in the reverse-engineering note.
	# Faithful spawn scheduling should instead use scheduled_enemy_events().
	var ids: Array[String] = []
	for raw_enemy_id in ENEMIES:
		var enemy: Dictionary = ENEMIES[raw_enemy_id]
		if tick >= int(enemy["unlock_tick"]):
			ids.append(str(raw_enemy_id))
	return ids


static func is_victory_wave(wave: int) -> bool:
	return wave > LAST_COMPLETED_WAVE


static func is_victory_tick(tick: int) -> bool:
	return tick >= VICTORY_TICK


static func should_evict_oldest_enemy(existing_enemy_count: int) -> bool:
	# Do not change this to >=: the Flash implementation permits 61 enemies.
	return existing_enemy_count > MAX_ENEMIES_NOMINAL


static func _copy_entry(table: Dictionary, key: Variant) -> Dictionary:
	var entry: Dictionary = table.get(key, {})
	return entry.duplicate(true)
