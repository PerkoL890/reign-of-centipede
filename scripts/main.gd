extends Node2D

const StageLayout = preload("res://scripts/stage_layout_data.gd")
const VIEW_SIZE := Vector2(650.0, 450.0)
# The Flash root never tiled a flattened 650x450 screenshot.  It painted an
# unbroken sky gradient, then two oversized transparent parallax clips.  These
# rectangles are the recovered source registrations at the opening camera.
const INITIAL_BACKGROUND_CAMERA := Vector2(290.05, 269.05)
const SKY_STARS_INITIAL_RECT := Rect2(-52.0, 15.15, 862.95, 331.40)
const DISTANT_ISLANDS_INITIAL_RECT := Rect2(-83.95, -35.05, 1254.95, 391.95)
# The recovered c_mc sprite is a 1350x713 export, but live objects may fall
# below that crop before the original reset condition fires.
const WORLD_SIZE := Vector2(1350.0, 1280.0)
const PLAYER_COLLISION_HALF_HEIGHT := 11.5
const PLAYER_DRAW_SIZE := Vector2(56.0, 45.0)
const PLAYER_BODY_DRAW_RECT := Rect2(-5.5, -12.5, 11.0, 24.0)
const PLAYER_WEAPON_PIVOT := Vector2(0.1, 2.75)
const PLAYER_WEAPON_DRAW_RECT := Rect2(-5.95, -6.8, 43.45, 14.25)
const MUZZLE_FLASH_DRAW_SIZE := Vector2(14.0, 10.0)
const PLAYER_HURT_FLASH_TICKS := 9
const SMOKE_INITIAL_SCALE := 0.30
const FRIENDLY_WEAPON_SCALE := 0.65
const WEAPON_FRAME_BY_ID := {
	"pistol": 1,
	"desert_eagle": 2,
	"mac10": 3,
	"shotgun": 4,
	"m16": 5,
	"ump": 6,
	"auto_shotgun": 7,
	"p90": 8,
	"aug": 9,
	"flamer": 10,
	"chaingun": 11,
	"bazooka": 12,
}
# These are the recovered source flash-child positions for weapon frames 1–12.
# The Flash game emits bullets from flash.x - 20, not the player wrapper's top.
const WEAPON_FLASH_POSITIONS := {
	1: Vector2(17.8, -0.95),
	2: Vector2(17.8, -0.95),
	3: Vector2(14.5, -1.8),
	4: Vector2(18.85, 0.15),
	5: Vector2(18.75, -1.0),
	6: Vector2(19.05, -0.7),
	7: Vector2(17.95, 0.7),
	8: Vector2(21.55, -0.15),
	9: Vector2(24.55, -1.25),
	10: Vector2(23.8, 0.8),
	11: Vector2(25.5, 0.6),
	12: Vector2(24.45, -0.7),
}
# DefineSprite 262 is the original Enemy wrapper. Its full-frame export keeps
# each body's authored offset/registration; the direct body exports below are
# used for physical dimensions and a fallback while assets are importing.
const ENEMY_WRAPPER_SIZE := Vector2(124.0, 170.0)
const ENEMY_WRAPPER_REGISTRATION := Vector2(61.5, 83.05)
const ENEMY_FRAME_BY_ID := {
	"praying_mantis": 1,
	"small_flying": 2,
	"flying_mech": 3,
	"ladybug": 4,
	"snail": 5,
	"orange_flying": 6,
	"green_centipede": 7,
	"blue_centipede": 8,
	"purple_centipede": 9,
	"flying_big": 10,
	"flying_very_big": 11,
	"small_green": 12,
	"flying_blue": 13,
}
const ENEMY_NATIVE_SIZES := {
	"small_green": Vector2(12.0, 13.0),
	"small_flying": Vector2(11.0, 13.0),
	"snail": Vector2(20.0, 16.0),
	"orange_flying": Vector2(15.0, 19.0),
	"ladybug": Vector2(40.0, 18.0),
	"praying_mantis": Vector2(71.0, 22.0),
	"flying_big": Vector2(37.0, 49.0),
	"flying_very_big": Vector2(50.0, 67.0),
	"flying_blue": Vector2(64.0, 86.0),
	"green_centipede": Vector2(69.0, 161.0),
	"blue_centipede": Vector2(66.0, 137.0),
	"purple_centipede": Vector2(62.0, 92.0),
	"flying_mech": Vector2(124.0, 167.0),
}
# Bottom extents from the original Enemy wrapper registration. Ground walkers
# sit with this visual foot point on a surface; using one generic 12px offset
# made small units float and submerged the tall centipedes after native-scale
# rendering was restored.
const ENEMY_FOOT_OFFSETS := {
	"small_green": 6.0,
	"snail": 8.0,
	"orange_flying": 9.5,
	"ladybug": 8.5,
	"praying_mantis": 10.5,
	"green_centipede": 83.0,
	"blue_centipede": 64.0,
	"purple_centipede": 42.0,
	"flying_big": 22.0,
	"flying_very_big": 30.0,
	"flying_blue": 40.0,
	"flying_mech": 83.0,
	"small_flying": 6.5,
}
const DOCK_RENDER_SIZE := Vector2(228.0, 49.0)
const DOCK_CANVAS_REGISTRATION := Vector2(114.0, 0.0)
const DOCK_HALF_WIDTHS := {"blue": 99.0, "purple": 109.0, "red": 111.0, "green": 114.0}
const DOCK_HEIGHTS := {"blue": 23.0, "purple": 29.0, "red": 42.0, "green": 49.0}
# EnemyDock.hitTestObject() in Flash includes its GiveHealthBar child, which
# extends a little below the painted dock body.  Keep this separate from the
# physical floor height above: a health bar is shootable but not walkable.
const DOCK_HIT_BOTTOMS := {"blue": 33.85, "purple": 39.55, "red": 51.90, "green": 58.55}
const MODE_MENU := "menu"
const MODE_STAGE_SELECT := "stage_select"
const MODE_GAME_MODE_SELECT := "game_mode_select"
const MODE_DIFFICULTY_SELECT := "difficulty_select"
const MODE_PLAY := "play"
const MODE_CREDITS := "credits"
const MODE_LOST := "lost"
const MODE_WON := "won"
const GAME_MODE_FAITHFUL := "faithful"
const GAME_MODE_CLASSIC_SURVIVAL := "classic_survival"
const GAME_MODE_RAPID_ASSAULT := "rapid_assault"
const GAME_MODE_SETTLEMENT_DEFENSE := "settlement_defense"
const GAME_MODE_SANDBOX := "sandbox"
const DIFFICULTY_EASY := "easy"
const DIFFICULTY_NORMAL := "normal"
const DIFFICULTY_HARD := "hard"
const DIFFICULTY_RULES := {
	DIFFICULTY_EASY: {"title": "EASY", "description": "More money, slower waves, weaker enemies.", "money_multiplier": 1.5, "wave_interval_multiplier": 1.2, "enemy_health_multiplier": 0.75, "enemy_speed_multiplier": 0.9, "spawn_multiplier": 1},
	DIFFICULTY_NORMAL: {"title": "NORMAL", "description": "The intended enhanced-mode challenge.", "money_multiplier": 1.0, "wave_interval_multiplier": 1.0, "enemy_health_multiplier": 1.0, "enemy_speed_multiplier": 1.0, "spawn_multiplier": 1},
	DIFFICULTY_HARD: {"title": "HARD", "description": "Fast tough enemies and extra spawns, with added loot.", "money_multiplier": 0.85, "wave_interval_multiplier": 0.78, "enemy_health_multiplier": 1.35, "enemy_speed_multiplier": 1.15, "spawn_multiplier": 2},
}
const GAME_MODE_RULES := {
	GAME_MODE_FAITHFUL: {"title": "FAITHFUL CAMPAIGN", "description": "The recovered original: survive all 65 waves.", "target_waves": 65, "wave_interval": 900, "starting_money": -1},
	GAME_MODE_CLASSIC_SURVIVAL: {"title": "CLASSIC SURVIVAL", "description": "Survive indefinitely. Score and wave are the goal.", "target_waves": 0, "wave_interval": 480, "starting_money": 100},
	GAME_MODE_RAPID_ASSAULT: {"title": "RAPID ASSAULT", "description": "A compact, high-pressure 15-wave combat run.", "target_waves": 15, "wave_interval": 420, "starting_money": 175},
	GAME_MODE_SETTLEMENT_DEFENSE: {"title": "SETTLEMENT DEFENSE", "description": "Protect the two starter buildings for 25 waves.", "target_waves": 25, "wave_interval": 600, "starting_money": 300},
	GAME_MODE_SANDBOX: {"title": "BUILDER'S SANDBOX", "description": "Build and experiment freely; no loss or final wave.", "target_waves": 0, "wave_interval": 900, "starting_money": 999999},
}

var mode := MODE_MENU
var paused := false
var stage_id := 1
var selected_stage_id := 1
var game_mode := GAME_MODE_FAITHFUL
var selected_game_mode := GAME_MODE_FAITHFUL
var difficulty := DIFFICULTY_NORMAL
var stage_elapsed_ticks := 0
var settlement_core_indices: Array[int] = []
var simulation_tick := 0
var shoot_counter := 0
var wave := 1
var money := 0
var score := 0
var camera_position := Vector2.ZERO
var player := {}
var buildings: Array = []
var friendlies: Array = []
var enemies: Array = []
var docks: Array = []
var bullets: Array = []
var lasers: Array = []
var coins: Array = []
var hearts: Array = []
var boxes: Array = []
var balloons: Array = []
var float_texts: Array = []
var smokes: Array = []
var small_clouds: Array = []
var big_clouds: Array = []
var cheats_available := false
var infinite_money_cheat := false
var instant_build_cheat := false
var fast_npc_spawn_cheat := false
var purchased_weapons := {"pistol": true}
var equipped_weapon := "pistol"
var selected_building := ""
var stage_texture: Texture2D
var player_texture: Texture2D
var enemy_texture: Texture2D
var friendly_texture: Texture2D
var carpenter_texture: Texture2D
var ui_layer: CanvasLayer
var hud_labels := {}
var status_label: Label
var hud_health_fill: ColorRect
var music_player: AudioStreamPlayer
var current_music_path := ""
var random := RandomNumberGenerator.new()
var texture_cache := {}
var sound_last_tick := {}
var pending_status := ""
var interface_font: Font
var hud_number_font: Font
var first_time_playing := true
var has_started_a_stage := false
var building_menu_site_index := -1
var jump_key_was_down := false
var tutorial_page := 0
var next_balloon_id := 1

func _ready() -> void:
	random.randomize()
	cheats_available = OS.get_cmdline_user_args().has("--cheats")
	# Keep the original Player components independent. The full Player export is
	# padded and loses the nested body/weapon registration points, while these
	# direct child exports let the body animate and the weapon track the mouse.
	player_texture = _load_texture("res://assets/original/player/body_standing.png")
	enemy_texture = _load_texture("res://assets/original/sprites/enemy_flying.png")
	friendly_texture = _load_texture("res://assets/original/sprites/friendly.png")
	carpenter_texture = _load_texture("res://assets/original/sprites/carpenter.png")
	var original_font := load("res://assets/original/fonts/visitor_tt1_brk.ttf")
	if original_font is Font:
		interface_font = original_font
	var original_hud_font := load("res://assets/original/fonts/bad_robot.ttf")
	if original_hud_font is Font:
		hud_number_font = original_hud_font
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.finished.connect(_restart_music_if_needed)
	_show_main_menu()
	if cheats_available:
		call_deferred("_show_cheat_menu")

func _physics_process(_delta: float) -> void:
	if mode != MODE_PLAY or paused:
		return
	_tick()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1 and cheats_available:
			_show_cheat_menu()
			return
		if event.keycode == KEY_ESCAPE and (mode == MODE_STAGE_SELECT or mode == MODE_CREDITS or mode == MODE_GAME_MODE_SELECT):
			_show_main_menu()
			return
		if event.keycode == KEY_ESCAPE and mode == MODE_DIFFICULTY_SELECT:
			_show_game_mode_select(selected_stage_id)
			return
		if mode != MODE_PLAY or paused:
			return
		if event.keycode == KEY_B:
			_open_build_menu_nearby()
		elif event.keycode == KEY_E:
			_show_weapon_menu()
		elif event.keycode == KEY_ESCAPE:
			_show_pause_menu()

func _show_main_menu() -> void:
	mode = MODE_MENU
	_play_music("res://assets/original/audio/menu.mp3")
	_clear_ui()
	if _add_original_main_menu_frame("menu_main.png"):
		# Exact visual frame plus invisible, native-positioned interaction zones.
		_add_source_menu_hotspot("PLAY", Rect2(50, 250, 235, 48), _show_stage_select, "Play")
		_add_source_menu_hotspot("CREDITS", Rect2(50, 294, 235, 48), _show_credits, "Credits")
	else:
		_add_full_screen_panel(Color("#071329"))
		_add_title("REIGN OF\nCENTIPEDE", Vector2(120, 57), Vector2(410, 90), 35, Color("#e7f7d2"))
		_add_label("A faithful 30 Hz recreation of the supplied Flash original", Vector2(116, 154), Vector2(430, 26), 13, Color("#a9c8bf"), HORIZONTAL_ALIGNMENT_CENTER)
		_add_button("PLAY", Vector2(235, 218), Vector2(180, 42), _show_stage_select)
		_add_button("CREDITS", Vector2(235, 270), Vector2(180, 34), _show_credits, 14)
		_add_label("A/D or arrows: move   W/Up: jump   Mouse: shoot\nS: build/repair   B: buildings   E: weapons", Vector2(120, 350), Vector2(410, 40), 12, Color("#c8d9c5"), HORIZONTAL_ALIGNMENT_CENTER)
	queue_redraw()

func _show_stage_select() -> void:
	mode = MODE_STAGE_SELECT
	_play_music("res://assets/original/audio/menu.mp3")
	_clear_ui()
	if _add_original_main_menu_frame("menu_stage_select.png"):
		var card_bounds := {
			1: Rect2(57, 136, 165, 115),
			2: Rect2(237, 136, 165, 115),
			3: Rect2(416, 136, 165, 115),
			4: Rect2(106, 278, 165, 115),
			5: Rect2(316, 278, 165, 115),
		}
		for number in range(1, 6):
			var button := _add_source_menu_hotspot("STAGE %d" % number, card_bounds[number], _show_game_mode_select.bind(number), "Stage %d" % number)
			button.tooltip_text = "Stage %d — %d fixed construction sites" % [number, int(GameData.get_stage(number).get("slot_count", 0))]
	else:
		_add_full_screen_panel(Color("#0b1c35"))
		_add_title("STAGE SELECT", Vector2(125, 38), Vector2(400, 44), 26, Color("#e7f7d2"))
		_add_label("All five stages are available in the original.", Vector2(115, 87), Vector2(420, 24), 13, Color("#a9c8bf"), HORIZONTAL_ALIGNMENT_CENTER)
		for number in range(1, 6):
			var row := (number - 1) / 3
			var column := (number - 1) % 3
			var button := _add_button("STAGE %d" % number, Vector2(115 + column * 145, 145 + row * 68), Vector2(130, 48), _show_game_mode_select.bind(number), 15)
			button.tooltip_text = "%d fixed construction sites" % int(GameData.get_stage(number).get("slot_count", 0))
		_add_button("BACK", Vector2(235, 350), Vector2(180, 34), _show_main_menu, 14)
	queue_redraw()

func _show_game_mode_select(number: int) -> void:
	selected_stage_id = number
	mode = MODE_GAME_MODE_SELECT
	_clear_ui()
	_add_full_screen_panel(Color("#08162b"))
	_add_title("STAGE %d — SELECT MODE" % number, Vector2(80, 24), Vector2(490, 36), 23, Color("#e7f7d2"))
	var modes := [GAME_MODE_FAITHFUL, GAME_MODE_CLASSIC_SURVIVAL, GAME_MODE_RAPID_ASSAULT, GAME_MODE_SETTLEMENT_DEFENSE, GAME_MODE_SANDBOX]
	for index in range(modes.size()):
		var mode_id: String = modes[index]
		var rules: Dictionary = GAME_MODE_RULES[mode_id]
		_add_button(str(rules.get("title", mode_id)), Vector2(120, 78 + index * 51), Vector2(410, 42), _show_difficulty_select.bind(number, mode_id), 14)
	_add_button("BACK", Vector2(235, 358), Vector2(180, 34), _show_stage_select, 14)
	queue_redraw()

func _show_difficulty_select(number: int, mode_id: String) -> void:
	selected_stage_id = number
	selected_game_mode = mode_id
	mode = MODE_DIFFICULTY_SELECT
	_clear_ui()
	_add_full_screen_panel(Color("#08162b"))
	var mode_rules: Dictionary = GAME_MODE_RULES[mode_id]
	_add_title("%s — DIFFICULTY" % mode_rules.get("title", mode_id), Vector2(65, 48), Vector2(520, 34), 21, Color("#e7f7d2"))
	for index in range([DIFFICULTY_EASY, DIFFICULTY_NORMAL, DIFFICULTY_HARD].size()):
		var difficulty_id: String = [DIFFICULTY_EASY, DIFFICULTY_NORMAL, DIFFICULTY_HARD][index]
		var rules: Dictionary = DIFFICULTY_RULES[difficulty_id]
		_add_button("%s\n%s" % [rules.get("title", difficulty_id), rules.get("description", "")], Vector2(85, 115 + index * 66), Vector2(480, 56), _start_stage.bind(number, mode_id, difficulty_id), 13)
	_add_button("BACK", Vector2(235, 340), Vector2(180, 34), _show_game_mode_select.bind(number), 14)
	queue_redraw()

func _show_credits() -> void:
	mode = MODE_CREDITS
	_clear_ui()
	if _add_original_main_menu_frame("menu_credits.png"):
		_add_source_menu_hotspot("BACK", Rect2(50, 358, 235, 48), _show_main_menu, "Back")
	else:
		_add_full_screen_panel(Color("#09172a"))
		_add_title("CREDITS", Vector2(160, 55), Vector2(330, 44), 28, Color("#e7f7d2"))
		_add_label("Original game assets and behaviour were recovered locally.\nModern recreation: Godot 4, fixed 30 Hz compatibility mode.\nNo original game files are modified.", Vector2(93, 140), Vector2(464, 90), 15, Color("#d4e8d0"), HORIZONTAL_ALIGNMENT_CENTER)
		_add_button("BACK", Vector2(235, 320), Vector2(180, 34), _show_main_menu, 14)
	queue_redraw()

func _show_tutorial() -> void:
	first_time_playing = false
	tutorial_page = 0
	_render_tutorial_page()

func _render_tutorial_page() -> void:
	if mode != MODE_PLAY:
		return
	# Keep the existing pause semantics for accessibility and deterministic tests,
	# but render the recovered Tutorial movie clip over the live stage/HUD instead
	# of replacing it with a new full-screen UI.
	paused = true
	_build_hud()
	var tutorial_texture := _load_texture("res://assets/original/ui/tutorial/tutorial_%02d.png" % (tutorial_page + 1))
	if tutorial_texture != null:
		var tutorial := TextureRect.new()
		tutorial.texture = tutorial_texture
		# Tutorial is placed at (325, 225), and FFDec's 660x409 direct crop
		# begins at local (-330, -190) in the original movie clip.
		tutorial.position = Vector2(-5, 35)
		tutorial.size = tutorial_texture.get_size()
		tutorial.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tutorial.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui_layer.add_child(tutorial)
		_add_tutorial_hotspot(Vector2(0, 382), Vector2(155, 48), _close_tutorial, "Skip tutorial")
		if tutorial_page != 5:
			_add_tutorial_hotspot(Vector2(500, 365), Vector2(150, 80), _advance_tutorial, "Next tutorial page")
	else:
		# Functional fallback if an editor is still importing the recovered frames.
		_add_label("Tutorial %d / 6" % (tutorial_page + 1), Vector2(140, 42), Vector2(370, 38), 24, Color("#e7f7d2"), HORIZONTAL_ALIGNMENT_CENTER)
		_add_button("SKIP", Vector2(125, 350), Vector2(140, 34), _close_tutorial, 14)
		_add_button("NEXT", Vector2(385, 350), Vector2(140, 34), _advance_tutorial, 14)

func _add_tutorial_hotspot(position: Vector2, dimensions: Vector2, callback: Callable, tooltip: String) -> void:
	var hotspot := Button.new()
	hotspot.position = position
	hotspot.size = dimensions
	hotspot.flat = true
	hotspot.focus_mode = Control.FOCUS_NONE
	hotspot.tooltip_text = tooltip
	hotspot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hotspot.pressed.connect(callback)
	ui_layer.add_child(hotspot)

func _advance_tutorial() -> void:
	tutorial_page += 1
	if tutorial_page >= 6:
		_close_tutorial()
	else:
		_render_tutorial_page()

func _close_tutorial() -> void:
	paused = false
	_build_hud()
	_set_status("Tutorial complete. Stage %d begins." % stage_id)

func _start_stage(number: int, selected_mode: String = GAME_MODE_FAITHFUL, selected_difficulty: String = DIFFICULTY_NORMAL) -> void:
	stage_id = number
	game_mode = selected_mode if GAME_MODE_RULES.has(selected_mode) else GAME_MODE_FAITHFUL
	difficulty = selected_difficulty if DIFFICULTY_RULES.has(selected_difficulty) else DIFFICULTY_NORMAL
	stage_elapsed_ticks = 0
	settlement_core_indices.clear()
	mode = MODE_PLAY
	paused = false
	if not has_started_a_stage:
		simulation_tick = 0
		shoot_counter = 0
		has_started_a_stage = true
	wave = 1
	var stage := GameData.get_stage(stage_id)
	var rules: Dictionary = GAME_MODE_RULES[game_mode]
	money = int(stage.get("starting_money", 0)) if int(rules.get("starting_money", -1)) < 0 else int(rules.get("starting_money", 0))
	if game_mode != GAME_MODE_SANDBOX:
		money = int(round(float(money) * float(DIFFICULTY_RULES[difficulty].get("money_multiplier", 1.0))))
	score = 0
	selected_building = ""
	building_menu_site_index = -1
	equipped_weapon = "pistol"
	purchased_weapons = {"pistol": true}
	buildings.clear()
	friendlies.clear()
	enemies.clear()
	docks.clear()
	bullets.clear()
	lasers.clear()
	coins.clear()
	hearts.clear()
	boxes.clear()
	balloons.clear()
	float_texts.clear()
	smokes.clear()
	small_clouds.clear()
	big_clouds.clear()
	_initialize_clouds()
	# The supplied map PNGs are convenient reference renders, but they bake in
	# a Player, pipes, rubble and health labels. Render the recovered individual
	# timeline instances instead so the simulation owns every dynamic object.
	player = {"pos": StageLayout.player_start_in_map(stage_id), "vel": Vector2.ZERO, "health": 150.0, "grounded": false, "facing": 1.0, "aim": Vector2.RIGHT, "muzzle_flash_ticks": 0, "hurt_flash_ticks": 0, "pipe_direction": 0, "pipe_index": -1}
	camera_position = StageLayout.MAP_FRAME_ORIGIN - StageLayout.INITIAL_CONTAINER_STAGE_POSITION
	stage_texture = null
	_create_build_sites(stage)
	if game_mode == GAME_MODE_SETTLEMENT_DEFENSE:
		_create_settlement_starters()
	_clear_ui()
	_build_hud()
	_play_music("res://assets/original/audio/game.mp3")
	_set_status("Stage %d — %s (%s)" % [stage_id, str(rules.get("description", "")), str(DIFFICULTY_RULES[difficulty].get("title", difficulty))])
	if first_time_playing and stage_id == 1 and game_mode == GAME_MODE_FAITHFUL:
		_show_tutorial()
	queue_redraw()

func _finish_stage(did_win: bool) -> void:
	mode = MODE_WON if did_win else MODE_LOST
	_stop_music()
	_clear_ui()
	var source_frame := "menu_win.png" if did_win else "menu_lose.png"
	if game_mode == GAME_MODE_FAITHFUL and _add_original_main_menu_frame(source_frame):
		if did_win:
			_add_source_menu_hotspot("STAGE SELECT", Rect2(75, 245, 400, 64), _show_stage_select, "Stage select")
		else:
			_add_source_menu_hotspot("TRY AGAIN", Rect2(75, 235, 400, 64), _start_stage.bind(stage_id), "Try stage %d again" % stage_id)
	else:
		_add_full_screen_panel(Color(0.02, 0.06, 0.12, 0.88))
		_add_title("STAGE COMPLETE" if did_win else "YOU WERE OVERWHELMED", Vector2(62, 105), Vector2(526, 52), 26, Color("#e7f7d2") if did_win else Color("#ffb0a0"))
		var rules: Dictionary = GAME_MODE_RULES[game_mode]
		var message := "Completed %s on Stage %d." % [rules.get("title", game_mode), stage_id] if did_win else "Your island settlement fell on wave %d." % wave
		_add_label(message, Vector2(100, 182), Vector2(450, 52), 15, Color("#d6e9d1"), HORIZONTAL_ALIGNMENT_CENTER)
		_add_label("Final score: %06d     Money: $%04d" % [score, money], Vector2(120, 258), Vector2(410, 25), 14, Color("#a9c8bf"), HORIZONTAL_ALIGNMENT_CENTER)
		_add_button("TRY AGAIN" if not did_win else "STAGE SELECT", Vector2(225, 325), Vector2(200, 36), _start_stage.bind(stage_id, game_mode, difficulty) if not did_win else _show_stage_select, 14)
	queue_redraw()

func _show_pause_menu() -> void:
	if mode != MODE_PLAY:
		return
	paused = true
	_clear_ui()
	_add_full_screen_panel(Color(0.02, 0.06, 0.12, 0.82))
	_add_title("PAUSED", Vector2(185, 105), Vector2(280, 44), 28, Color("#e7f7d2"))
	_add_button("RESUME", Vector2(235, 195), Vector2(180, 36), _resume_from_pause, 14)
	_add_button("STAGE SELECT", Vector2(235, 243), Vector2(180, 36), _show_stage_select, 14)

func _resume_from_pause() -> void:
	paused = false
	_build_hud()

func _build_hud() -> void:
	_clear_ui()
	# DefineSprite 661 is the original screen-space controls movie clip. It
	# contains the authored labels, frames, sound control, and weapons button;
	# only its five dynamic text fields are overlaid below.
	var controls_texture := _load_texture("res://assets/original/ui/controls_hud.png")
	if controls_texture != null:
		var controls := TextureRect.new()
		controls.texture = controls_texture
		# DefineSprite 661's flattened bounds begin at local (-321, -8), while
		# controls_mc is placed at (325, 11) on the root timeline.
		controls.position = Vector2(4, 3)
		controls.size = controls_texture.get_size()
		controls.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui_layer.add_child(controls)
		# Clear only the flattened default numbers, retaining the recovered frames
		# and labels behind their live source-format replacements.
		_add_hud_health_bar()
		_add_hud_mask(Vector2(111, 18), Vector2(66, 13))
		_add_hud_mask(Vector2(224, 18), Vector2(90, 13))
		_add_hud_mask(Vector2(374, 18), Vector2(40, 13))
		_add_hud_mask(Vector2(436, 18), Vector2(88, 13))
	else:
		# A readable fallback is retained only while the original HUD asset imports.
		_add_full_screen_panel(Color(0.03, 0.09, 0.16, 0.88))
	_add_hud_value("health", Vector2(67, 4), Vector2(150, 18), 10, HORIZONTAL_ALIGNMENT_CENTER, interface_font)
	_add_hud_value("soldiers", Vector2(111, 16), Vector2(66, 17), 14, HORIZONTAL_ALIGNMENT_CENTER, interface_font)
	_add_hud_value("money", Vector2(219, 10), Vector2(95, 27), 18, HORIZONTAL_ALIGNMENT_RIGHT, hud_number_font)
	_add_hud_value("wave", Vector2(371, 10), Vector2(44, 27), 18, HORIZONTAL_ALIGNMENT_RIGHT, hud_number_font)
	_add_hud_value("score", Vector2(432, 10), Vector2(95, 27), 18, HORIZONTAL_ALIGNMENT_RIGHT, hud_number_font)
	# The original artwork exposes a weapons button at the upper right. Keep the
	# source click target without replacing it with a modern-looking control.
	var weapons_button := Button.new()
	weapons_button.position = Vector2(535, 0)
	weapons_button.size = Vector2(105, 38)
	weapons_button.flat = true
	weapons_button.focus_mode = Control.FOCUS_NONE
	weapons_button.tooltip_text = "Weapons (E)"
	weapons_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	weapons_button.pressed.connect(_open_weapon_menu_from_hud)
	ui_layer.add_child(weapons_button)
	if cheats_available:
		_add_button("CHEATS", Vector2(555, 409), Vector2(82, 25), _show_cheat_menu, 10)
	_update_hud()

func _show_cheat_menu() -> void:
	if not cheats_available:
		return
	paused = true
	_clear_ui()
	_add_full_screen_panel(Color(0.02, 0.05, 0.10, 0.94))
	_add_title("CHEAT MENU", Vector2(145, 72), Vector2(360, 42), 28, Color("#f6df74"))
	_add_label("These options remain active until you close the game.", Vector2(92, 122), Vector2(466, 25), 13, Color("#c4d6cd"), HORIZONTAL_ALIGNMENT_CENTER)
	_add_cheat_toggle("INFINITE MONEY", "Never spend your current balance.", Vector2(155, 170), "infinite_money")
	_add_cheat_toggle("INSTANT BUILDING", "Finish a selected building immediately.", Vector2(155, 226), "instant_build")
	_add_cheat_toggle("FAST NPC SPAWNING", "Friendly buildings spawn five times faster.", Vector2(155, 282), "fast_npc_spawn")
	_add_button("CLOSE", Vector2(235, 352), Vector2(180, 38), _close_cheat_menu, 14)

func _add_cheat_toggle(title: String, detail: String, position: Vector2, cheat_id: String) -> void:
	var button := _add_button("%s: %s\n%s" % [title, "ON" if _cheat_enabled(cheat_id) else "OFF", detail], position, Vector2(340, 46), _toggle_cheat.bind(cheat_id), 12)
	button.tooltip_text = detail

func _cheat_enabled(cheat_id: String) -> bool:
	match cheat_id:
		"infinite_money": return infinite_money_cheat
		"instant_build": return instant_build_cheat
		"fast_npc_spawn": return fast_npc_spawn_cheat
	return false

func _toggle_cheat(cheat_id: String) -> void:
	match cheat_id:
		"infinite_money": infinite_money_cheat = not infinite_money_cheat
		"instant_build": instant_build_cheat = not instant_build_cheat
		"fast_npc_spawn": fast_npc_spawn_cheat = not fast_npc_spawn_cheat
	_show_cheat_menu()

func _close_cheat_menu() -> void:
	paused = false
	if mode == MODE_PLAY:
		_build_hud()
	else:
		_show_main_menu()

func _open_weapon_menu_from_hud() -> void:
	# Tutorial frame 6 points at this exact source button. In Flash that click
	# both dismisses the tutorial and opens WeaponMenu.
	if paused and tutorial_page == 5:
		_close_tutorial()
	_show_weapon_menu()

func _add_hud_mask(position: Vector2, dimensions: Vector2) -> void:
	var mask := ColorRect.new()
	mask.position = position
	mask.size = dimensions
	# The source backdrop beneath the controls at y=18 is #162238. Matching it
	# exactly hides the flattened default HUD values without leaving visible dark
	# rectangles over the restored root-timeline sky art.
	mask.color = Color("#162238")
	mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(mask)

func _add_hud_health_bar() -> void:
	var background := ColorRect.new()
	background.position = Vector2(67, 7)
	background.size = Vector2(150, 9)
	background.color = Color("#111111")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(background)
	hud_health_fill = ColorRect.new()
	hud_health_fill.position = Vector2(68, 8)
	hud_health_fill.size = Vector2(148, 7)
	hud_health_fill.color = Color("#c54224")
	hud_health_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(hud_health_fill)

func _add_hud_value(key: String, position: Vector2, dimensions: Vector2, font_size: int, alignment: HorizontalAlignment, font: Font) -> Label:
	var label := _add_label("", position, dimensions, font_size, Color.WHITE, alignment)
	if font != null:
		label.add_theme_font_override("font", font)
	# Flash applies a black GlowFilter to each changing HUD number.  A one-pixel
	# outline plus the shared shadow keeps the live Godot labels visually seated
	# in the recovered controls artwork instead of looking like clean overlay
	# text.
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	label.add_theme_constant_override("outline_size", 1)
	hud_labels[key] = label
	return label

func _open_build_menu_nearby() -> void:
	if mode != MODE_PLAY or paused:
		return
	var site_index := _nearest_build_site(player.get("pos", Vector2.ZERO), 35.0)
	if site_index < 0:
		_set_status("Stand beside a rubble site to open the building menu.")
		return
	var site: Dictionary = buildings[site_index]
	if site.get("state", "rubble") != "rubble" or bool(site.get("constructing", false)):
		_set_status("This site is already being built or occupied.")
		return
	building_menu_site_index = site_index
	_show_build_menu()

func _show_build_menu() -> void:
	if mode != MODE_PLAY or building_menu_site_index < 0:
		return
	paused = true
	_clear_ui()
	_add_full_screen_panel(Color(0.02, 0.08, 0.13, 0.94))
	_add_title("BUILDING MENU", Vector2(112, 30), Vector2(426, 35), 24, Color("#e7f7d2"))
	_add_label("Choose a blueprint for the selected rubble site. Hold S or Down to construct it.", Vector2(42, 73), Vector2(566, 28), 12, Color("#b8d4be"), HORIZONTAL_ALIGNMENT_CENTER)
	var ids: Array = GameData.BUILDING_PURCHASE_ORDER
	for index in range(ids.size()):
		var building_id: String = ids[index]
		var data: Dictionary = GameData.get_building(building_id)
		var row := index / 2
		var column := index % 2
		var caption := "%s  $%d\n%s" % [data.get("display_name", building_id), int(data.get("cost", 0)), data.get("role", "")]
		_add_button(caption, Vector2(60 + column * 270, 120 + row * 58), Vector2(250, 50), _select_building.bind(building_id), 11)
	_add_button("CLOSE", Vector2(235, 385), Vector2(180, 31), _close_building_menu, 13)

func _select_building(building_id: String) -> void:
	if building_menu_site_index < 0 or building_menu_site_index >= buildings.size():
		_close_building_menu()
		return
	var data: Dictionary = GameData.get_building(building_id)
	var cost := int(data.get("cost", 0))
	if not infinite_money_cheat and money < cost:
		_set_status("Not enough money for %s." % data.get("display_name", building_id))
		_show_build_menu()
		return
	var site: Dictionary = buildings[building_menu_site_index]
	if not infinite_money_cheat:
		money -= cost
	selected_building = building_id
	site["id"] = building_id
	site["constructing"] = true
	site["build_health"] = 0.0
	site["build_total"] = float(data.get("finished_health", 100)) * 3.0
	if instant_build_cheat:
		_complete_building(site)
	buildings[building_menu_site_index] = site
	building_menu_site_index = -1
	paused = false
	_set_status("Constructing %s." % data.get("display_name", building_id))
	_build_hud()

func _show_weapon_menu() -> void:
	if mode != MODE_PLAY:
		return
	paused = true
	_clear_ui()
	_add_full_screen_panel(Color(0.02, 0.08, 0.13, 0.94))
	_add_title("WEAPON MENU", Vector2(130, 28), Vector2(390, 35), 24, Color("#e7f7d2"))
	_add_label("The pistol is equipped free at the start, matching the original.", Vector2(80, 71), Vector2(490, 22), 12, Color("#b8d4be"), HORIZONTAL_ALIGNMENT_CENTER)
	var ids: Array = GameData.WEAPON_ORDER
	for index in range(ids.size()):
		var weapon_id: String = ids[index]
		var data: Dictionary = GameData.get_weapon(weapon_id)
		var row := index / 3
		var column := index % 3
		var owned := purchased_weapons.has(weapon_id)
		var caption := "%s\n%s" % [data.get("display_name", weapon_id), "EQUIPPED" if equipped_weapon == weapon_id else ("OWNED" if owned else "$%d" % int(data.get("cost", 0)))]
		_add_button(caption, Vector2(40 + column * 195, 110 + row * 57), Vector2(180, 49), _buy_or_equip_weapon.bind(weapon_id), 11)
	_add_button("CLOSE", Vector2(235, 387), Vector2(180, 31), _close_game_menu, 13)

func _buy_or_equip_weapon(weapon_id: String) -> void:
	var data: Dictionary = GameData.get_weapon(weapon_id)
	if purchased_weapons.has(weapon_id):
		equipped_weapon = weapon_id
		_set_status("%s equipped." % data.get("display_name", weapon_id))
	elif money >= int(data.get("cost", 0)):
		money -= int(data.get("cost", 0))
		purchased_weapons[weapon_id] = true
		equipped_weapon = weapon_id
		_set_status("%s purchased and equipped." % data.get("display_name", weapon_id))
	else:
		_set_status("Need $%d more for %s." % [int(data.get("cost", 0)) - money, data.get("display_name", weapon_id)])
		_show_weapon_menu()
		return
	_show_weapon_menu()

func _close_building_menu() -> void:
	building_menu_site_index = -1
	_close_game_menu()

func _close_game_menu() -> void:
	paused = false
	_build_hud()

func _clear_ui() -> void:
	if ui_layer == null:
		return
	for child in ui_layer.get_children():
		child.queue_free()
	hud_labels.clear()
	status_label = null
	hud_health_fill = null

func _add_full_screen_panel(color: Color) -> ColorRect:
	var panel := ColorRect.new()
	panel.color = color
	panel.position = Vector2.ZERO
	panel.size = VIEW_SIZE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(panel)
	return panel

func _add_original_main_menu_frame(filename: String) -> bool:
	var texture := _load_texture("res://assets/original/ui/%s" % filename)
	if texture == null:
		return false
	var frame := TextureRect.new()
	frame.texture = texture
	# DefineSprite 522 is instantiated at (325, 225). Its FFDec exports retain
	# a large transparent canvas spanning x=-653.9..701.05 and y=-247.95..274.95,
	# so this native offset maps the embedded 650x450 Flash composition back to
	# the viewport without resizing or centering it.
	frame.position = Vector2(-337, -31)
	frame.size = texture.get_size()
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(frame)
	return true

func _add_source_menu_hotspot(text: String, bounds: Rect2, callback: Callable, tooltip: String) -> Button:
	var button := Button.new()
	button.text = text
	button.position = bounds.position
	button.size = bounds.size
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = tooltip
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# The source texture already contains the authored button art. Retain real
	# Controls for accessibility/tests but make Godot's overlay fully invisible.
	var empty := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", empty)
	button.add_theme_stylebox_override("hover", empty)
	button.add_theme_stylebox_override("pressed", empty)
	button.add_theme_stylebox_override("disabled", empty)
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	button.pressed.connect(callback)
	ui_layer.add_child(button)
	return button

func _add_title(text: String, position: Vector2, dimensions: Vector2, font_size: int, color: Color) -> Label:
	return _add_label(text, position, dimensions, font_size, color, HORIZONTAL_ALIGNMENT_CENTER)

func _add_label(text: String, position: Vector2, dimensions: Vector2, font_size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = dimensions
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	if interface_font != null:
		label.add_theme_font_override("font", interface_font)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	ui_layer.add_child(label)
	return label

func _add_button(text: String, position: Vector2, dimensions: Vector2, callback: Callable, font_size: int = 16) -> Button:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = dimensions
	button.add_theme_font_size_override("font_size", font_size)
	if interface_font != null:
		button.add_theme_font_override("font", interface_font)
	button.add_theme_stylebox_override("normal", _panel_style(Color("#244d46"), Color("#93c36d"), 2))
	button.add_theme_stylebox_override("hover", _panel_style(Color("#356b58"), Color("#e7f7d2"), 2))
	button.add_theme_stylebox_override("pressed", _panel_style(Color("#193c38"), Color("#e7f7d2"), 2))
	button.pressed.connect(callback)
	ui_layer.add_child(button)
	return button

func _panel_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

func _tick() -> void:
	simulation_tick += 1
	stage_elapsed_ticks += 1
	shoot_counter += 1
	if infinite_money_cheat or game_mode == GAME_MODE_SANDBOX:
		money = 999999
	_update_player()
	# Flash handles its timer, balloons and the loss/win checks before it makes
	# this frame's ordinary enemy/dock spawn decisions.
	if _handle_misc():
		return
	_handle_spawns()
	_update_buildings()
	_update_friendlies()
	_update_enemies()
	_update_docks()
	_update_bullets()
	_update_lasers()
	_update_smoke()
	_update_clouds()
	_update_pickups()
	_update_float_texts()
	_update_boxes_and_balloons()
	_update_camera()
	_update_hud()
	queue_redraw()

func _handle_misc() -> bool:
	var balloon_clock := simulation_tick if game_mode == GAME_MODE_FAITHFUL else stage_elapsed_ticks
	var balloon_interval := GameData.BALLOON_SPAWN_INTERVAL_TICKS
	var balloon_chance := GameData.BALLOON_SPAWN_CHANCE
	if game_mode == GAME_MODE_RAPID_ASSAULT and difficulty == DIFFICULTY_HARD:
		balloon_interval = 150
		balloon_chance = 1.0
	if balloon_clock > 0 and balloon_clock % balloon_interval == 0 and random.randf() < balloon_chance:
		# Source c_mc coordinates: x=-200..700, y=300. Convert once to the
		# map coordinate system used by this recreation.
		_create_balloon(_source_pixels_to_map(Vector2(random.randf_range(-200.0, 700.0), 300.0)), true)
	var rules: Dictionary = GAME_MODE_RULES[game_mode]
	var wave_interval := int(round(float(rules.get("wave_interval", GameData.WAVE_INTERVAL_TICKS)) * float(DIFFICULTY_RULES[difficulty].get("wave_interval_multiplier", 1.0))))
	var wave_clock := simulation_tick if game_mode == GAME_MODE_FAITHFUL else stage_elapsed_ticks
	if game_mode != GAME_MODE_SANDBOX and wave_clock > 0 and wave_clock % wave_interval == 0:
		wave += 1
		if game_mode == GAME_MODE_CLASSIC_SURVIVAL:
			_spawn_survival_wave_reinforcements()
	# Loss deliberately wins this tie, as in MainTimeline.handleMisc().
	if game_mode != GAME_MODE_SANDBOX and float(player.get("health", 0.0)) <= 0.0:
		_finish_stage(false)
		return true
	if game_mode == GAME_MODE_SETTLEMENT_DEFENSE and _settlement_is_destroyed():
		_set_status("The settlement has fallen.")
		_finish_stage(false)
		return true
	var target_waves := _target_wave_count()
	if target_waves > 0 and wave > target_waves:
		_finish_stage(true)
		return true
	return false

func _target_wave_count() -> int:
	if game_mode == GAME_MODE_RAPID_ASSAULT and difficulty == DIFFICULTY_HARD:
		return 45
	return int(GAME_MODE_RULES[game_mode].get("target_waves", GameData.LAST_COMPLETED_WAVE))

func _update_player() -> void:
	if player.is_empty():
		return
	player["muzzle_flash_ticks"] = maxi(0, int(player.get("muzzle_flash_ticks", 0)) - 1)
	player["hurt_flash_ticks"] = maxi(0, int(player.get("hurt_flash_ticks", 0)) - 1)
	var velocity: Vector2 = player.get("vel", Vector2.ZERO)
	var moving := false
	var jump_key_down := Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var interaction_down := Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)
	var pipe_direction := int(player.get("pipe_direction", 0))
	if pipe_direction != 0:
		_update_player_pipe_travel(pipe_direction)
		_update_player_aim(player.get("pos", Vector2.ZERO))
		jump_key_was_down = jump_key_down
		return
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		velocity.x = -3.0
		moving = true
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		velocity.x = 3.0
		moving = true
	else:
		velocity.x = 0.0
	if jump_key_down and not jump_key_was_down and bool(player.get("grounded", false)):
		velocity.y = -11.0
		player["grounded"] = false
		_play_sound("jump")
	jump_key_was_down = jump_key_down
	velocity.y += 1.0
	var position: Vector2 = player.get("pos", Vector2.ZERO) + velocity
	var ground_y := _ground_y_at(position.x, position.y - velocity.y, PLAYER_COLLISION_HALF_HEIGHT, 5.5)
	if velocity.y >= 0.0 and is_finite(ground_y) and position.y >= ground_y:
		position.y = ground_y
		velocity.y = 0.0
		player["grounded"] = true
	else:
		player["grounded"] = false
	if interaction_down:
		_try_enter_pipe(position)
		if int(player.get("pipe_direction", 0)) != 0:
			player["pos"] = position
			player["vel"] = velocity
			_update_player_pipe_travel(int(player.get("pipe_direction", 0)))
			return
	if _map_to_source_pixels(position).y > GameData.PLAYER_FALL_RESET_Y:
		position = _source_pixels_to_map(Vector2(-66.0, 33.0))
		velocity = Vector2.ZERO
		camera_position = StageLayout.MAP_FRAME_ORIGIN - StageLayout.FALL_RESET_CONTAINER_STAGE_POSITION
		_damage_player(45.0)
		_create_balloon(position + Vector2(0, 70), false)
		_set_status("You fell from the island: -45 health.")
	player["pos"] = position
	player["vel"] = velocity
	# The source player turns toward the mouse, independently of keyboard
	# movement. This updates both the mirrored body and the weapon transform.
	_update_player_aim(position)
	if interaction_down:
		_build_or_repair()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not interaction_down:
		_try_fire_player(moving)

func _try_enter_pipe(position: Vector2) -> void:
	for index in range(_pipes_for_stage().size()):
		var pipe: Dictionary = _pipe_data(index)
		var endpoints: Dictionary = pipe.get("endpoints", {})
		var origin: Vector2 = pipe.get("origin", Vector2.ZERO)
		var top: Vector2 = endpoints.get("top", Vector2.ZERO)
		var bottom: Vector2 = endpoints.get("bottom", Vector2.ZERO)
		if absf(position.x - origin.x) < 7.0 and absf(position.y - bottom.y) < 40.0 and position.y > bottom.y:
			player["pipe_direction"] = -1
			player["pipe_index"] = index
			_play_sound("pipe")
			return
		if absf(position.x - origin.x) < 7.0 and absf(position.y - top.y) < 40.0 and position.y < top.y:
			player["pipe_direction"] = 1
			player["pipe_index"] = index
			_play_sound("pipe")
			return

func _update_player_pipe_travel(direction: int) -> void:
	var pipe_index := int(player.get("pipe_index", -1))
	var pipe := _pipe_data(pipe_index)
	if pipe.is_empty():
		player["pipe_direction"] = 0
		return
	var endpoints: Dictionary = pipe.get("endpoints", {})
	var position: Vector2 = player.get("pos", Vector2.ZERO)
	var origin: Vector2 = pipe.get("origin", position)
	position.x = origin.x
	position.y += float(direction) * GameData.PIPE_PULL_SPEED
	var top: Vector2 = endpoints.get("top", position)
	var bottom: Vector2 = endpoints.get("bottom", position)
	if direction < 0 and position.y < top.y:
		player["pipe_direction"] = 0
		player["pipe_index"] = -1
	elif direction > 0 and position.y > bottom.y:
		player["pipe_direction"] = 0
		player["pipe_index"] = -1
	player["pos"] = position
	player["vel"] = Vector2(0.0, float(direction) * GameData.PIPE_PULL_SPEED)

func _try_fire_player(moving: bool) -> void:
	var weapon: Dictionary = GameData.get_weapon(equipped_weapon)
	var rate := int(weapon.get("s_rate", 8))
	if rate <= 0 or shoot_counter % rate != 0:
		return
	var aim: Vector2 = player.get("aim", Vector2(float(player.get("facing", 1.0)), 0.0))
	if aim.length_squared() < 0.01:
		aim = Vector2(float(player.get("facing", 1.0)), 0.0)
	var pose := _player_weapon_pose(aim)
	var position: Vector2 = pose.get("muzzle_position", player.get("pos", Vector2.ZERO))
	var spread := _player_bullet_spread_degrees(moving, not bool(player.get("grounded", false)))
	for pellet in range(int(weapon.get("amount", 1))):
		var direction := aim.rotated(deg_to_rad(random.randf_range(-spread, spread)))
		_create_bullet(position, direction * 20.0, int(weapon.get("power", 2)), "player")
	shoot_counter = 0
	player["muzzle_flash_ticks"] = 4
	_play_sound(_weapon_sound(equipped_weapon))

func _player_bullet_spread_degrees(moving: bool, airborne: bool) -> float:
	if airborne:
		return GameData.JUMPING_AIM_SPREAD_DEGREES
	if moving:
		return GameData.MOVING_AIM_SPREAD_DEGREES
	return GameData.STANDING_AIM_SPREAD_DEGREES

func _update_player_aim(position: Vector2) -> void:
	var mouse_world := get_viewport().get_mouse_position() + camera_position
	var aim := mouse_world - position
	if aim.length_squared() < 0.01:
		return
	aim = aim.normalized()
	player["aim"] = aim
	player["facing"] = 1.0 if aim.x >= 0.0 else -1.0

func _player_weapon_pose(aim_override: Vector2 = Vector2.ZERO) -> Dictionary:
	var position: Vector2 = player.get("pos", Vector2.ZERO)
	var facing := float(player.get("facing", 1.0))
	var aim: Vector2 = aim_override
	if aim.length_squared() < 0.01:
		aim = player.get("aim", Vector2(facing, 0.0))
	if aim.length_squared() < 0.01:
		aim = Vector2(facing, 0.0)
	aim = aim.normalized()
	var frame := int(WEAPON_FRAME_BY_ID.get(equipped_weapon, 1))
	var flash_position: Vector2 = WEAPON_FLASH_POSITIONS.get(frame, WEAPON_FLASH_POSITIONS[1])
	var rotation := aim.angle() if facing > 0.0 else aim.angle() + PI
	var pivot := position + PLAYER_WEAPON_PIVOT
	# Flash applies horizontal mirroring before its weapon rotation. Mirror local
	# x first, then rotate it to reproduce the nested DisplayObject transform.
	var flash_world := pivot + Vector2(flash_position.x * facing, flash_position.y).rotated(rotation)
	var muzzle_local := flash_position - Vector2(20.0, 0.0)
	var muzzle_world := pivot + Vector2(muzzle_local.x * facing, muzzle_local.y).rotated(rotation)
	return {
		"frame": frame,
		"facing": facing,
		"rotation": rotation,
		"pivot": pivot,
		"flash_position": flash_position,
		"flash_world": flash_world,
		"muzzle_position": muzzle_world,
	}

func _friendly_weapon_pose(friendly: Dictionary) -> Dictionary:
	var position: Vector2 = friendly.get("pos", Vector2.ZERO)
	var facing := float(friendly.get("facing", 1.0))
	var aim: Vector2 = friendly.get("aim", Vector2(facing, 0.0))
	if aim.length_squared() < 0.01:
		aim = Vector2(facing, 0.0)
	aim = aim.normalized()
	var frame := int(WEAPON_FRAME_BY_ID.get(str(friendly.get("weapon", "pistol")), 1))
	var rotation := aim.angle() if facing > 0.0 else aim.angle() + PI
	var pivot := position + Vector2(0.0, -13.0)
	var flash_position: Vector2 = WEAPON_FLASH_POSITIONS.get(frame, WEAPON_FLASH_POSITIONS[1]) * FRIENDLY_WEAPON_SCALE
	var muzzle_local := flash_position - Vector2(20.0 * FRIENDLY_WEAPON_SCALE, 0.0)
	var muzzle_world := pivot + Vector2(muzzle_local.x * facing, muzzle_local.y).rotated(rotation)
	return {"frame": frame, "facing": facing, "rotation": rotation, "pivot": pivot, "flash_position": flash_position, "muzzle_position": muzzle_world}

func _draw_friendly_weapon(friendly: Dictionary, visual_position: Vector2) -> void:
	var pose := _friendly_weapon_pose(friendly)
	var texture := _load_texture("res://assets/original/player/weapon_%02d.png" % int(pose.get("frame", 1)))
	if texture == null:
		return
	var pivot: Vector2 = pose.get("pivot", visual_position + Vector2(0.0, -11.0))
	# Keep the visual bob aligned with the friendly body while bullets retain the
	# simulation's native hand origin.
	pivot.y += visual_position.y - friendly.get("pos", visual_position).y
	draw_set_transform(pivot - camera_position, float(pose.get("rotation", 0.0)), Vector2(float(pose.get("facing", 1.0)) * FRIENDLY_WEAPON_SCALE, FRIENDLY_WEAPON_SCALE))
	draw_texture_rect(texture, PLAYER_WEAPON_DRAW_RECT, false)
	var flash_ticks := int(friendly.get("muzzle_flash_ticks", 0))
	var flash_texture := _load_texture("res://assets/original/player/muzzle_flash.png")
	if flash_texture != null and flash_ticks > 0:
		var flash_position: Vector2 = pose.get("flash_position", Vector2.ZERO)
		draw_texture_rect(flash_texture, Rect2(flash_position - Vector2(2.0, 5.0), MUZZLE_FLASH_DRAW_SIZE), false, Color(1.0, 1.0, 1.0, 1.0 if flash_ticks >= 3 else 0.5))
	draw_set_transform(-camera_position)

func _build_or_repair() -> void:
	var player_position: Vector2 = player.get("pos", Vector2.ZERO)
	var site_index := _nearest_build_site(player_position, 35.0)
	if site_index < 0:
		return
	var site: Dictionary = buildings[site_index]
	if site.get("state", "rubble") == "rubble":
		if not bool(site.get("constructing", false)):
			_open_build_menu_nearby()
			return
		site["build_health"] = float(site.get("build_total", 0.0)) if instant_build_cheat else float(site.get("build_health", 0.0)) + 2.0
		if float(site.get("build_health", 0.0)) >= float(site.get("build_total", 1.0)):
			_complete_building(site)
		buildings[site_index] = site
	elif site.get("state") == "complete":
		var building_data: Dictionary = GameData.get_building(str(site.get("id", "")))
		site["health"] = minf(float(building_data.get("finished_health", 1)), float(site.get("health", 0.0)) + 1.0)
		buildings[site_index] = site

func _complete_building(site: Dictionary) -> void:
	var data: Dictionary = GameData.get_building(str(site.get("id", "")))
	site["state"] = "complete"
	site["constructing"] = false
	site["health"] = float(data.get("finished_health", 1))
	# Building.setBuildingProperties seeds the spawn cadence from random 0..99.
	site["spawn_counter"] = random.randi_range(0, 99)
	_set_status("%s complete." % data.get("display_name", site.get("id", "building")))
	_play_sound("box")

func _update_camera() -> void:
	var position: Vector2 = player.get("pos", Vector2.ZERO)
	var velocity: Vector2 = player.get("vel", Vector2.ZERO)
	var camera_x := camera_position.x
	var camera_y := camera_position.y
	var screen_position := position - camera_position
	# MainTimeline moves c_mc by the current velocity only while the player is
	# travelling outward through its 200..400 / 150..300 dead zone. Snapping to
	# the boundary changes the opening camera composition by dozens of pixels.
	if (screen_position.x < 200.0 and velocity.x < 0.0) or (screen_position.x > 400.0 and velocity.x > 0.0):
		camera_x += velocity.x
	if (screen_position.y < 150.0 and velocity.y < 0.0) or (screen_position.y > 300.0 and velocity.y > 0.0):
		camera_y += velocity.y
	camera_position = Vector2(maxf(0.0, camera_x), maxf(0.0, camera_y))

func _ground_y_at(world_x: float, previous_y: float, half_height: float = 12.0, half_width: float = 0.0) -> float:
	var best := INF
	for surface in _ground_surfaces():
		if world_x + half_width >= surface.position.x and world_x - half_width <= surface.end.x and previous_y <= surface.position.y + half_height + 6.0:
			best = minf(best, surface.position.y - half_height)
	return best

func _ground_surfaces() -> Array:
	var surfaces := _platforms_for_stage()
	# Flash applyGravity checks the four authored island clips *and every
	# EnemyDock* as possible ground. Docks are therefore real temporary
	# platforms: omitting them stranded their ground spawns and let the player
	# fall straight through them.
	for dock in docks:
		# A dock with no health is already destroyed for collision purposes, even
		# though the later dock-update pass removes its visual object. This lets
		# anything standing on it begin falling on the very next physics tick.
		if float(dock.get("health", 0.0)) <= 0.0:
			continue
		var dock_id := str(dock.get("id", "blue"))
		var position: Vector2 = dock.get("pos", Vector2.ZERO)
		surfaces.append(Rect2(position.x - _dock_half_width(dock_id), position.y, _dock_half_width(dock_id) * 2.0, _dock_height(dock_id)))
	return surfaces

func _create_build_sites(stage: Dictionary) -> void:
	var count := int(stage.get("building_site_count", stage.get("slot_count", 0)))
	var positions := _build_site_positions()
	for index in range(count):
		var position: Vector2 = positions[index % positions.size()]
		buildings.append({
			"pos": position,
			"state": "rubble",
			"id": "",
			"health": 20.0,
			"constructing": false,
			"build_health": 0.0,
			"build_total": 0.0,
			"spawn_counter": 0,
			"effect_counter": random.randi_range(0, 99),
		})
		_create_smoke(position + Vector2(random.randf_range(-12.0, 12.0), random.randf_range(-32.0, -16.0)))

func _create_settlement_starters() -> void:
	var starter_ids := ["small_shack", "carpenter_house"]
	for index in range(mini(starter_ids.size(), buildings.size())):
		var site: Dictionary = buildings[index]
		site["id"] = starter_ids[index]
		_complete_building(site)
		buildings[index] = site
		settlement_core_indices.append(index)

func _settlement_is_destroyed() -> bool:
	if settlement_core_indices.is_empty():
		return false
	for index in settlement_core_indices:
		if index >= 0 and index < buildings.size() and buildings[index].get("state", "rubble") == "complete":
			return false
	return true

func _build_site_positions() -> Array:
	var positions: Array = []
	for site in StageLayout.building_sites_for(stage_id):
		positions.append(StageLayout.map_position(site))
	return positions

func _platforms_for_stage() -> Array:
	var platforms: Array = []
	var layout := StageLayout.layout_for(stage_id)
	for island in layout.get("islands", []):
		platforms.append(StageLayout.island_bounds_in_map(island))
	return platforms

func _pipes_for_stage() -> Array:
	var pipes: Array = []
	var layout := StageLayout.layout_for(stage_id)
	for pipe in layout.get("pipes", []):
		pipes.append(StageLayout.pipe_bounds_in_map(pipe))
	return pipes

func _pipe_data(index: int) -> Dictionary:
	var layout := StageLayout.layout_for(stage_id)
	var pipes: Array = layout.get("pipes", [])
	if index < 0 or index >= pipes.size():
		return {}
	var pipe: Dictionary = pipes[index]
	return {
		"origin": StageLayout.map_position(pipe),
		"bounds": StageLayout.pipe_bounds_in_map(pipe),
		"endpoints": StageLayout.pipe_endpoints_in_map(pipe),
	}

func _source_pixels_to_map(position: Vector2) -> Vector2:
	return StageLayout.source_twips_to_map(position * StageLayout.TWIPS_PER_PIXEL)

func _map_to_source_pixels(position: Vector2) -> Vector2:
	return StageLayout.map_to_source_twips(position) / StageLayout.TWIPS_PER_PIXEL

func _nearest_build_site(position: Vector2, maximum_distance: float) -> int:
	var best_index := -1
	var best_distance := maximum_distance
	for index in range(buildings.size()):
		var distance := position.distance_to(buildings[index].get("pos", Vector2.ZERO))
		if distance <= best_distance:
			best_index = index
			best_distance = distance
	return best_index

func _update_buildings() -> void:
	for index in range(buildings.size()):
		var site: Dictionary = buildings[index]
		site["effect_counter"] = int(site.get("effect_counter", 0)) + 1
		if site.get("state", "rubble") == "rubble" and int(site.get("effect_counter", 0)) % 24 == 0:
			_create_smoke(site.get("pos", Vector2.ZERO) + Vector2(random.randf_range(-18.0, 18.0), random.randf_range(-35.0, -16.0)))
		if site.get("state", "rubble") != "complete":
			buildings[index] = site
			continue
		if float(site.get("health", 0.0)) <= 0.0:
			_destroy_building(site)
			buildings[index] = site
			continue
		var data: Dictionary = GameData.get_building(str(site.get("id", "")))
		site["spawn_counter"] = int(site.get("spawn_counter", 0)) + 1
		var spawn_interval := int(data.get("spawn_interval_ticks", 99_999))
		if fast_npc_spawn_cheat:
			spawn_interval = maxi(10, spawn_interval / 5)
		if int(site.get("spawn_counter", 0)) % spawn_interval == 0 and friendlies.size() < GameData.MAX_FRIENDLIES:
			_create_friendly(site.get("pos", Vector2.ZERO) + Vector2(15, -5), data)
		buildings[index] = site

func _destroy_building(site: Dictionary) -> void:
	site["state"] = "rubble"
	site["id"] = ""
	site["health"] = 20.0
	site["constructing"] = false
	site["build_health"] = 0.0
	site["build_total"] = 0.0
	site["spawn_counter"] = 0
	_set_status("A building was destroyed and returned to rubble.")
	_play_sound("explosion")

func _create_friendly(position: Vector2, building_data: Dictionary) -> void:
	var home_surface := _friendly_home_surface(position)
	if home_surface.has_area():
		# A defender belongs to the grass platform carrying its building, rather
		# than to the global nearest-ground query.  This prevents several towers
		# from visually collapsing their defenders onto one shared island.
		position.x = clampf(position.x, home_surface.position.x + 6.0, home_surface.end.x - 6.0)
		position.y = home_surface.position.y
	friendlies.append({
		"pos": position,
		"home_pos": position,
		"home_surface": home_surface,
		"health": float(GameData.FRIENDLY_TOTAL_HEALTH),
		"counter": 0,
		"role": str(building_data.get("role", "fighter")),
		"kind": str(building_data.get("friendly_kind", "old_man")),
		"weapon": str(building_data.get("defender_weapon_id", "pistol")),
		"move_dir": -1.0 if random.randf() < 0.5 else 1.0,
		"move_counter": 0,
		"facing": 1.0,
		"aim": Vector2.RIGHT,
		"has_target": false,
		"muzzle_flash_ticks": 0,
	})

func _update_friendlies() -> void:
	for index in range(friendlies.size() - 1, -1, -1):
		var friendly: Dictionary = friendlies[index]
		if float(friendly.get("health", 0.0)) <= 0.0:
			friendlies.remove_at(index)
			continue
		friendly["counter"] = int(friendly.get("counter", 0)) + 1
		friendly["move_counter"] = int(friendly.get("move_counter", 0)) + 1
		friendly["muzzle_flash_ticks"] = maxi(0, int(friendly.get("muzzle_flash_ticks", 0)) - 1)
		friendly["has_target"] = false
		var role := str(friendly.get("role", "fighter"))
		if role == "fighter":
			_update_fighter(friendly)
			_wander_friendly(friendly)
		elif role == "carpenter":
			_update_carpenter(friendly)
		elif role == "nurse":
			_wander_friendly(friendly)
			if int(friendly.get("counter", 0)) % GameData.NURSE_HEART_INTERVAL_TICKS == 0:
				_create_heart(friendly.get("pos", Vector2.ZERO))
		friendlies[index] = friendly

func _update_fighter(friendly: Dictionary) -> void:
	var enemy_index := _nearest_enemy_index(friendly.get("pos", Vector2.ZERO), GameData.FRIENDLY_RANGE)
	if enemy_index < 0:
		return
	var enemy: Dictionary = enemies[enemy_index]
	var position: Vector2 = friendly.get("pos", Vector2.ZERO)
	var target: Vector2 = enemy.get("pos", Vector2.ZERO)
	var aim := (target - position).normalized()
	if aim.length_squared() > 0.01:
		friendly["aim"] = aim
		friendly["facing"] = 1.0 if aim.x >= 0.0 else -1.0
		friendly["has_target"] = true
	var weapon: Dictionary = GameData.get_weapon(str(friendly.get("weapon", "pistol")))
	if int(friendly.get("counter", 0)) % int(weapon.get("s_rate", 8)) == 0:
		var weapon_pose := _friendly_weapon_pose(friendly)
		_create_bullet(weapon_pose.get("muzzle_position", position + Vector2(0, -12)), aim * GameData.BULLET_SPEED, int(weapon.get("power", 2)), "friendly", str(friendly.get("weapon", "pistol")))
		friendly["muzzle_flash_ticks"] = 4

func _update_carpenter(friendly: Dictionary) -> void:
	var target_index := -1
	var target_distance := INF
	var position: Vector2 = friendly.get("pos", Vector2.ZERO)
	for index in range(buildings.size()):
		var site: Dictionary = buildings[index]
		if bool(site.get("constructing", false)) and float(site.get("build_health", 0.0)) < float(site.get("build_total", 0.0)):
			var distance := position.distance_to(site.get("pos", Vector2.ZERO))
			if distance < target_distance:
				target_distance = distance
				target_index = index
	if target_index < 0:
		_wander_friendly(friendly)
		return
	var target: Dictionary = buildings[target_index]
	if target_distance > 30.0:
		var direction := signf(target.get("pos", Vector2.ZERO).x - position.x)
		position.x += direction * GameData.FRIENDLY_MOVE_SPEED
		if direction != 0.0:
			friendly["facing"] = direction
			friendly["aim"] = Vector2(direction, 0.0)
		var ground_y := _ground_y_at(position.x, position.y, 0.0)
		if is_finite(ground_y):
			position.y = ground_y
		friendly["pos"] = position
	elif int(friendly.get("counter", 0)) % GameData.CARPENTER_BUILD_INTERVAL_TICKS == 0:
		target["build_health"] = float(target.get("build_health", 0.0)) + GameData.CARPENTER_BUILD_HEALTH
		if float(target.get("build_health", 0.0)) >= float(target.get("build_total", 1.0)):
			_complete_building(target)
		buildings[target_index] = target

func _wander_friendly(friendly: Dictionary) -> void:
	var position: Vector2 = friendly.get("pos", Vector2.ZERO)
	var direction := float(friendly.get("move_dir", 1.0))
	var home_surface: Rect2 = friendly.get("home_surface", Rect2())
	if int(friendly.get("move_counter", 0)) > 30 and random.randf() < 0.004:
		direction *= -1.0
		friendly["move_counter"] = 0
	var next_x := position.x + direction * GameData.FRIENDLY_MOVE_SPEED
	if home_surface.has_area() and (next_x < home_surface.position.x + 5.0 or next_x > home_surface.end.x - 5.0):
		direction *= -1.0
		next_x = position.x + direction * GameData.FRIENDLY_MOVE_SPEED
	var next_ground := _ground_y_at(next_x, position.y - 4.0, 0.0)
	if not is_finite(next_ground) or next_ground > position.y + 25.0:
		direction *= -1.0
		next_x = position.x + direction * GameData.FRIENDLY_MOVE_SPEED
		next_ground = _ground_y_at(next_x, position.y - 4.0, 0.0)
	if not is_finite(next_ground):
		next_x = position.x
		next_ground = position.y
	friendly["move_dir"] = direction
	friendly["pos"] = Vector2(next_x, home_surface.position.y if home_surface.has_area() else next_ground)
	if not bool(friendly.get("has_target", false)):
		friendly["facing"] = direction
		friendly["aim"] = Vector2(direction, 0.0)

func _friendly_home_surface(position: Vector2) -> Rect2:
	var best_surface := Rect2()
	var best_distance := INF
	for surface in _ground_surfaces():
		if position.x < surface.position.x or position.x > surface.end.x:
			continue
		var distance := absf(position.y - surface.position.y)
		if distance < best_distance:
			best_distance = distance
			best_surface = surface
	return best_surface

func _handle_spawns() -> void:
	var spawn_tick := simulation_tick if game_mode == GAME_MODE_FAITHFUL else stage_elapsed_ticks
	if game_mode == GAME_MODE_RAPID_ASSAULT:
		spawn_tick *= 2
	var spawn_wave := _rapid_assault_source_wave() if game_mode == GAME_MODE_RAPID_ASSAULT else wave
	var difficulty_rules: Dictionary = DIFFICULTY_RULES[difficulty]
	for event in GameData.scheduled_enemy_events(spawn_wave, spawn_tick):
		for spawn_index in range(int(difficulty_rules.get("spawn_multiplier", 1))):
			var spawn_position: Vector2
			if str(event.get("spawn_kind", "player_relative")) == "fixed":
				spawn_position = _source_pixels_to_map(Vector2(-540.0, -410.0)) + Vector2(spawn_index * 28.0, 0.0)
			else:
				spawn_position = player.get("pos", Vector2.ZERO) + Vector2(random.randf_range(-500.0, 500.0), random.randf_range(-400.0, -100.0))
			_create_enemy(str(event.get("enemy_id", "small_flying")), spawn_position)
	if game_mode == GAME_MODE_CLASSIC_SURVIVAL:
		_spawn_survival_pressure(spawn_tick)
	var dock_event: Dictionary = GameData.scheduled_dock_event(spawn_wave, spawn_tick, stage_id)
	if not dock_event.is_empty() and docks.size() < GameData.MAX_DOCKS:
		_create_dock(str(dock_event.get("dock_id", "blue")), _choose_dock_enemy(dock_event))

func _rapid_assault_source_wave() -> int:
	# Preserve a readable escalation: early flyers through roughly wave 8, then
	# mid-tier enemies, with the campaign's strongest roster saved for the end.
	# Hard uses the same curve across its longer 45-wave endurance run.
	var progress := float(wave) / float(maxi(_target_wave_count(), 1))
	if progress <= 0.54:
		return maxi(1, int(round(1.0 + progress / 0.54 * 10.0)))
	if progress <= 0.67:
		return int(round(12.0 + (progress - 0.54) / 0.13 * 5.0))
	if progress <= 0.80:
		return int(round(18.0 + (progress - 0.67) / 0.13 * 7.0))
	if progress <= 0.90:
		return int(round(26.0 + (progress - 0.80) / 0.10 * 11.0))
	if progress <= 0.97:
		return int(round(38.0 + (progress - 0.90) / 0.07 * 11.0))
	return mini(GameData.LAST_COMPLETED_WAVE, 50 + int((progress - 0.97) / 0.03 * 15.0))

func _spawn_survival_pressure(spawn_tick: int) -> void:
	# After the original's last authored band, survival keeps escalating rather
	# than silently becoming a static wave-50 loop.
	if wave <= GameData.LAST_COMPLETED_WAVE:
		return
	var interval := maxi(30, 120 - (wave - GameData.LAST_COMPLETED_WAVE) * 5)
	if spawn_tick > 0 and spawn_tick % interval == 0:
		var count := mini(6, 1 + int((wave - GameData.LAST_COMPLETED_WAVE) / 12))
		for index in range(count):
			var enemy_id := "flying_mech" if (wave + index) % 5 == 0 else "orange_flying"
			_create_enemy(enemy_id, _survival_spawn_position(index))

func _spawn_survival_wave_reinforcements() -> void:
	var count := mini(8, 1 + int((wave - 1) / 4))
	for index in range(count):
		var enemy_id := "small_flying" if wave < 12 else ("orange_flying" if wave < 30 else "flying_big")
		_create_enemy(enemy_id, _survival_spawn_position(index))

func _survival_spawn_position(index: int) -> Vector2:
	var horizontal_sign := -1.0 if index % 2 == 0 else 1.0
	return player.get("pos", Vector2.ZERO) + Vector2(horizontal_sign * random.randf_range(160.0, 460.0), random.randf_range(-320.0, -100.0))

func _choose_dock_enemy(event: Dictionary) -> String:
	var distribution: Array = event.get("dock_enemy_distribution", [])
	var choice := random.randf()
	var cumulative := 0.0
	for entry in distribution:
		cumulative += float(entry.get("weight", 0.0))
		if choice <= cumulative:
			return str(entry.get("enemy_id", "small_green"))
	return str(distribution.back().get("enemy_id", "small_green")) if not distribution.is_empty() else "small_green"

func _create_enemy(enemy_id: String, position: Vector2) -> void:
	if enemies.size() > GameData.MAX_ENEMIES_NOMINAL:
		enemies.remove_at(0)
	var data: Dictionary = GameData.get_enemy(enemy_id)
	if data.is_empty():
		return
	var difficulty_rules: Dictionary = DIFFICULTY_RULES[difficulty]
	var speed := (float(data.get("base_speed", 1.8)) + random.randf() * GameData.ENEMY_SPEED_VARIANCE) * float(difficulty_rules.get("enemy_speed_multiplier", 1.0))
	enemies.append({
		"id": enemy_id,
		"pos": position,
		"health": float(data.get("health", 9)) * float(difficulty_rules.get("enemy_health_multiplier", 1.0)),
		"counter": 0,
		"speed": speed,
		"movement": str(data.get("movement", "walk")),
		"can_shoot": bool(data.get("can_shoot", false)),
		"targets_objects": random.randf() > 0.6,
		"target_group": "friendly" if random.randf() > 0.2 else "building",
		"move_dir": -1.0 if str(data.get("movement", "")) == "flying_shoot" else (-1.0 if random.randf() < 0.5 else 1.0),
		"default_dir": -1.0 if random.randf() < 0.5 else 1.0,
		"move_counter": 0,
		"walk": true,
		"closest_object_distance": INF,
		"shoot_target": -1,
		"has_shot": false,
		"fall_velocity": 0.0,
	})

func _update_enemies() -> void:
	for index in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[index]
		if float(enemy.get("health", 0.0)) <= 0.0:
			_kill_enemy(index)
			continue
		enemy["counter"] = int(enemy.get("counter", 0)) + 1
		enemy["move_counter"] = int(enemy.get("move_counter", 0)) + 1
		if int(enemy.get("counter", 0)) > 300 and random.randi_range(1, 7000) == 1:
			enemy["targets_objects"] = true
		var movement := str(enemy.get("movement", "walk"))
		if movement == "walk":
			_move_walking_enemy(enemy)
		elif movement == "flying":
			_move_flying_enemy(enemy)
		else:
			_move_shooting_enemy(enemy)
		var position: Vector2 = enemy.get("pos", Vector2.ZERO)
		if position.distance_to(player.get("pos", Vector2.ZERO)) < 20.0 and int(enemy.get("counter", 0)) % GameData.ENEMY_CONTACT_INTERVAL_TICKS == 0:
			var data: Dictionary = GameData.get_enemy(str(enemy.get("id", "")))
			_damage_player(float(data.get("contact_power", 3)))
		_enemy_attack_objects(enemy, position)
		if _map_to_source_pixels(position).y > GameData.ENEMY_FALL_DESPAWN_Y:
			enemies.remove_at(index)
			continue
		enemies[index] = enemy

func _move_walking_enemy(enemy: Dictionary) -> void:
	var position: Vector2 = enemy.get("pos", Vector2.ZERO)
	var foot_offset := _enemy_foot_offset(str(enemy.get("id", "small_green")))
	# After a close target-object attack the Flash enemy leaves `walk` false for
	# one frame, clears its target, then resumes its normal scan on the next.
	if not bool(enemy.get("walk", true)):
		enemy["walk"] = true
		return
	var direction := float(enemy.get("move_dir", 1.0))
	if bool(enemy.get("targets_objects", false)):
		var target := _enemy_target(enemy)
		if target.get("kind", "") != "none" and absf(target.get("pos", position).y - position.y) < 30.0:
			direction = signf(target.get("pos", position).x - position.x)
			enemy["closest_object_distance"] = position.distance_to(target.get("pos", position))
		else:
			enemy["closest_object_distance"] = INF
	elif int(enemy.get("move_counter", 0)) > 30 and random.randi_range(1, 460) == 1:
		direction *= -1.0
		enemy["move_counter"] = 0
	var next_x := position.x + direction * float(enemy.get("speed", 1.0))
	var next_ground := _ground_y_at(next_x, position.y - 4.0, foot_offset)
	if not is_finite(next_ground) or next_ground > position.y + 25.0:
		direction *= -1.0
		next_x = position.x + direction * float(enemy.get("speed", 1.0))
		next_ground = _ground_y_at(next_x, position.y - 4.0, foot_offset)
	if not is_finite(next_ground):
		# The original applies gravity to walking enemies after edge steering.
		# If their dock is destroyed (or they step off every island), do not pin
		# them in the air: retain horizontal momentum and fall until a lower
		# surface catches them or the source-compatible despawn threshold does.
		var fall_velocity := float(enemy.get("fall_velocity", 0.0)) + GameData.PLAYER_GRAVITY
		enemy["fall_velocity"] = fall_velocity
		enemy["move_dir"] = float(enemy.get("default_dir", direction))
		enemy["pos"] = Vector2(next_x, position.y + fall_velocity)
		return
	enemy["move_dir"] = direction
	enemy["fall_velocity"] = 0.0
	enemy["pos"] = Vector2(next_x, next_ground)

func _move_flying_enemy(enemy: Dictionary) -> void:
	var position: Vector2 = enemy.get("pos", Vector2.ZERO)
	var target := _enemy_target(enemy)
	var target_position: Vector2 = target.get("pos", player.get("pos", Vector2.ZERO))
	if bool(enemy.get("targets_objects", false)) and target.get("kind", "") != "none":
		target_position += Vector2(random.randf_range(-60.0, 60.0), random.randf_range(-87.0, 87.0))
	position += (target_position - position).normalized() * float(enemy.get("speed", 1.0)) * GameData.ORDINARY_FLYING_SPEED_SCALE
	enemy["move_dir"] = signf(target_position.x - position.x)
	enemy["pos"] = position

func _move_shooting_enemy(enemy: Dictionary) -> void:
	var layout := StageLayout.layout_for(stage_id)
	var islands: Array = layout.get("islands", [])
	if islands.is_empty():
		return
	var counter := int(enemy.get("counter", 0))
	if int(enemy.get("shoot_target", -1)) < 0 or counter % 460 == 0:
		enemy["shoot_target"] = random.randi_range(0, islands.size() - 1)
		enemy["has_shot"] = false
	var island: Dictionary = islands[int(enemy.get("shoot_target", 0))]
	var island_bounds := StageLayout.island_bounds_in_map(island)
	var enemy_height := _enemy_render_size(str(enemy.get("id", "small_flying"))).y
	# MainTimeline targets the selected island's right edge and its instance
	# origin (rather than bounds.top) minus one third of the enemy height.
	var target := Vector2(island_bounds.end.x, StageLayout.map_position(island).y - enemy_height / 3.0)
	var position: Vector2 = enemy.get("pos", Vector2.ZERO)
	if not bool(enemy.get("has_shot", false)):
		position += (target - position).normalized() * float(enemy.get("speed", 1.0))
	if counter % GameData.ENEMY_SHOOT_CHECK_INTERVAL_TICKS == 0 and absf(position.x - target.x) < 70.0 and absf(position.y - target.y) < 50.0:
		_create_laser(position, Vector2.LEFT)
		enemy["has_shot"] = true
	enemy["move_dir"] = -1.0
	enemy["pos"] = position

func _enemy_target(enemy: Dictionary) -> Dictionary:
	if not bool(enemy.get("targets_objects", false)):
		return {"kind": "none", "index": -1}
	if str(enemy.get("target_group", "friendly")) == "friendly":
		var friendly_index := _nearest_friendly_index(enemy.get("pos", Vector2.ZERO))
		if friendly_index >= 0:
			return {"pos": friendlies[friendly_index].get("pos", Vector2.ZERO), "kind": "friendly", "index": friendly_index}
	else:
		var building_index := _nearest_complete_building_index(enemy.get("pos", Vector2.ZERO))
		if building_index >= 0:
			return {"pos": buildings[building_index].get("pos", Vector2.ZERO), "kind": "building", "index": building_index}
	return {"kind": "none", "index": -1}

func _enemy_attack_objects(enemy: Dictionary, position: Vector2) -> void:
	if int(enemy.get("counter", 0)) % GameData.ENEMY_TARGET_ATTACK_INTERVAL_TICKS != 0:
		return
	var data: Dictionary = GameData.get_enemy(str(enemy.get("id", "")))
	for index in range(friendlies.size()):
		var friendly: Dictionary = friendlies[index]
		if position.distance_to(friendly.get("pos", Vector2.ZERO)) < 24.0:
			friendly["health"] = float(friendly.get("health", 0.0)) - float(data.get("contact_power", 3))
			friendlies[index] = friendly
	if not bool(enemy.get("targets_objects", false)) or str(enemy.get("movement", "")) == "flying_shoot":
		return
	var target := _enemy_target(enemy)
	if target.get("kind", "") == "none" or position.distance_to(target.get("pos", position)) >= GameData.ENEMY_TARGET_ATTACK_RANGE:
		enemy["walk"] = true
		return
	var target_index := int(target.get("index", -1))
	if target.get("kind", "") == "friendly" and target_index >= 0 and target_index < friendlies.size():
		var target_friendly: Dictionary = friendlies[target_index]
		target_friendly["health"] = float(target_friendly.get("health", 0.0)) - GameData.ENEMY_TARGET_ATTACK_DAMAGE
		friendlies[target_index] = target_friendly
	elif target.get("kind", "") == "building" and target_index >= 0 and target_index < buildings.size():
		var building: Dictionary = buildings[target_index]
		building["health"] = float(building.get("health", 0.0)) - GameData.ENEMY_TARGET_ATTACK_DAMAGE
		buildings[target_index] = building
		_create_smoke(building.get("pos", Vector2.ZERO) + Vector2(random.randf_range(-15.0, 15.0), random.randf_range(-35.0, -12.0)))
	enemy["walk"] = false

func _create_smoke(position: Vector2) -> void:
	smokes.append({
		"pos": position,
		"scale": SMOKE_INITIAL_SCALE,
		"alpha": 1.0,
		"speed_x": random.randf_range(-0.5, 0.5),
		"fade_speed": random.randf_range(2.0, 6.0) / 500.0,
		"scale_speed": random.randf_range(1.0, 5.0) / 1100.0,
	})

func _update_smoke() -> void:
	for index in range(smokes.size() - 1, -1, -1):
		var smoke: Dictionary = smokes[index]
		smoke["pos"] = smoke.get("pos", Vector2.ZERO) + Vector2(float(smoke.get("speed_x", 0.0)), -2.0)
		smoke["scale"] = float(smoke.get("scale", SMOKE_INITIAL_SCALE)) + float(smoke.get("scale_speed", 0.0))
		smoke["alpha"] = float(smoke.get("alpha", 1.0)) - float(smoke.get("fade_speed", 0.01))
		if float(smoke.get("alpha", 0.0)) <= 0.0:
			smokes.remove_at(index)
		else:
			smokes[index] = smoke

func _initialize_clouds() -> void:
	if not small_clouds.is_empty() or not big_clouds.is_empty():
		return
	for index in range(9):
		var direction := -1.0 if index % 2 == 0 else 1.0
		small_clouds.append({"pos": Vector2(random.randf_range(-80.0, 640.0), random.randf_range(25.0, 410.0)), "frame": random.randi_range(1, 3), "speed": (0.24 + float(index) / 18.0) * direction, "direction": direction})
	for index in range(8):
		var direction := -1.0 if index % 2 == 0 else 1.0
		big_clouds.append({"pos": Vector2(random.randf_range(-80.0, 620.0), random.randf_range(30.0, 385.0)), "frame": random.randi_range(1, 3), "speed": (0.32 + float(index) / 11.0) * direction, "direction": direction})

func _update_clouds() -> void:
	for clouds in [small_clouds, big_clouds]:
		for cloud in clouds:
			var position: Vector2 = cloud.get("pos", Vector2.ZERO)
			position.x += float(cloud.get("speed", -0.1))
			var direction := float(cloud.get("direction", -1.0))
			if direction < 0.0 and position.x < -230.0:
				position.x = 720.0
			elif direction > 0.0 and position.x > 720.0:
				position.x = -230.0
			cloud["pos"] = position

func _kill_enemy(index: int) -> void:
	var enemy: Dictionary = enemies[index]
	var data: Dictionary = GameData.get_enemy(str(enemy.get("id", "")))
	var position: Vector2 = enemy.get("pos", Vector2.ZERO)
	for count in range(int(data.get("worth", 1))):
		_create_coin(position + Vector2(random.randf_range(-8.0, 8.0), random.randf_range(-8.0, 8.0)))
	score += int(data.get("worth", 1)) * 4
	enemies.remove_at(index)
	_play_sound("explosion")

func _create_dock(dock_id: String, enemy_id: String) -> void:
	var layout := StageLayout.layout_for(stage_id)
	var islands: Array = layout.get("islands", [])
	if islands.is_empty():
		return
	var island_index := -1
	# MainTimeline retries its randomly selected island up to twenty times when
	# another dock already owns it, and simply abandons the dock if all retries
	# fail. Preserve that occupancy model rather than allowing overlap.
	for _attempt in range(GameData.DOCK_PLACEMENT_ATTEMPTS + 1):
		var candidate := random.randi_range(0, islands.size() - 1)
		var occupied := false
		for existing in docks:
			if int(existing.get("island_index", -1)) == candidate:
				occupied = true
				break
		if not occupied:
			island_index = candidate
			break
	if island_index < 0:
		return
	var data: Dictionary = GameData.get_dock(dock_id)
	docks.append({
		"id": dock_id,
		"enemy_id": enemy_id,
		"pos": StageLayout.enemy_dock_initial_position_in_map(),
		"health": float(data.get("health", 90)),
		"counter": 0,
		"spawn_interval": int(data.get("spawn_interval_ticks", 190)),
		"island_index": island_index,
		"dock_side": "left" if random.randf() > 0.5 else "right",
		"is_docked": false,
		"float_counter": 0,
	})

func _update_docks() -> void:
	for index in range(docks.size() - 1, -1, -1):
		var dock: Dictionary = docks[index]
		if float(dock.get("health", 0.0)) <= 0.0:
			score += GameData.DOCK_DESTROY_SCORE
			_set_status("Dock destroyed: +%d" % GameData.DOCK_DESTROY_DISPLAY_VALUE)
			docks.remove_at(index)
			_play_sound("explosion")
			continue
		dock["counter"] = int(dock.get("counter", 0)) + 1
		var layout := StageLayout.layout_for(stage_id)
		var islands: Array = layout.get("islands", [])
		var island_index := int(dock.get("island_index", -1))
		if island_index < 0 or island_index >= islands.size():
			docks.remove_at(index)
			continue
		var island: Dictionary = islands[island_index]
		var edge_points := StageLayout.island_dock_edge_points_in_map(island, _dock_half_width(str(dock.get("id", "blue"))))
		var side := str(dock.get("dock_side", "left"))
		var dock_point: Vector2 = edge_points.get(side, edge_points.get("left", Vector2.ZERO))
		var position: Vector2 = dock.get("pos", Vector2.ZERO)
		if not bool(dock.get("is_docked", false)):
			if absf(position.x - dock_point.x) > 3.0:
				position += (dock_point - position).normalized() * 2.0
			else:
				# Godot's terrain support test is exact. Leaving the source's visual
				# approach tolerance here leaves a 1–3px gap, causing dock spawns to
				# turn around forever instead of stepping onto the island.
				position = dock_point
				dock["is_docked"] = true
				dock["float_counter"] = 0
		else:
			dock["float_counter"] = int(dock.get("float_counter", 0)) + 1
			var float_counter := int(dock.get("float_counter", 0))
			if float_counter < 60:
				position.y -= 0.4
			elif float_counter < 120:
				position.y += 0.4
			else:
				dock["float_counter"] = 0
		dock["pos"] = position
		if bool(dock.get("is_docked", false)) and int(dock.get("counter", 0)) % int(dock.get("spawn_interval", 190)) == 0:
			var count_before := enemies.size()
			_create_enemy(str(dock.get("enemy_id", "small_green")), position)
			if enemies.size() > count_before:
				var spawned: Dictionary = enemies[enemies.size() - 1]
				var departure_direction := 1.0 if side == "left" else -1.0
				# Flash sets defaultDir after dock creation; start moveDir on that
				# inward course too so a new ground unit immediately crosses from
				# its temporary dock floor onto the selected island.
				spawned["default_dir"] = departure_direction
				spawned["move_dir"] = departure_direction
				enemies[enemies.size() - 1] = spawned
		docks[index] = dock

func _create_bullet(position: Vector2, velocity: Vector2, damage: int, owner: String, weapon_id: String = "") -> void:
	var source_weapon := equipped_weapon if weapon_id.is_empty() else weapon_id
	bullets.append({"pos": position, "vel": velocity, "damage": damage, "owner": owner, "counter": 0, "kind": GameData.get_weapon(source_weapon).get("projectile_kind", "bullet")})

func _update_bullets() -> void:
	for index in range(bullets.size() - 1, -1, -1):
		var bullet: Dictionary = bullets[index]
		bullet["counter"] = int(bullet.get("counter", 0)) + 1
		bullet["pos"] = bullet.get("pos", Vector2.ZERO) + bullet.get("vel", Vector2.ZERO)
		# Original onBullet moves, tests targets (including EnemyDock), then
		# expires the projectile.  Testing first retains a valid final-frame hit.
		if _bullet_hit(bullet) or int(bullet.get("counter", 0)) > GameData.BULLET_LIFETIME_TICKS:
			bullets.remove_at(index)
		else:
			bullets[index] = bullet

func _bullet_hit(bullet: Dictionary) -> bool:
	var position: Vector2 = bullet.get("pos", Vector2.ZERO)
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		if position.distance_to(enemy.get("pos", Vector2.ZERO)) < 19.0:
			enemy["health"] = float(enemy.get("health", 0.0)) - int(bullet.get("damage", 1))
			enemies[index] = enemy
			score += 1
			_play_sound("squish")
			return true
	for index in range(docks.size()):
		var dock: Dictionary = docks[index]
		if _bullet_hits_dock(bullet, dock):
			dock["health"] = float(dock.get("health", 0.0)) - int(bullet.get("damage", 1))
			docks[index] = dock
			_play_sound("ricochet_1" if random.randf() > 0.5 else "ricochet_2")
			return true
	for index in range(balloons.size()):
		var balloon: Dictionary = balloons[index]
		if position.distance_to(balloon.get("pos", Vector2.ZERO)) < 20.0:
			_release_balloon_box(int(balloon.get("id", -1)))
			score += 50
			balloons.remove_at(index)
			_play_sound("pop")
			return true
	for index in range(boxes.size()):
		var box: Dictionary = boxes[index]
		if not bool(box.get("floating", false)) and position.distance_to(box.get("pos", Vector2.ZERO)) < 18.0:
			box["health"] = float(box.get("health", 0.0)) - int(bullet.get("damage", 1))
			boxes[index] = box
			score += 1
			return true
	return false

func _dock_hit_bounds(dock: Dictionary) -> Rect2:
	# EnemyDock's registration is its top-centre.  Unlike terrain, the original
	# bullet loop calls hitTestObject() on the whole dock clip, whose visible
	# bounds differ per colour (blue 198x23 through green 228x49) and include
	# the small health-bar child below the body.
	var dock_id := str(dock.get("id", "blue"))
	var position: Vector2 = dock.get("pos", Vector2.ZERO)
	var half_width := _dock_half_width(dock_id)
	var hit_bottom := float(DOCK_HIT_BOTTOMS.get(dock_id, _dock_height(dock_id)))
	return Rect2(position.x - half_width, position.y, half_width * 2.0, hit_bottom)

func _bullet_hits_dock(bullet: Dictionary, dock: Dictionary) -> bool:
	# The exported source bullet is an 8x8 visual.  Check that full body against
	# the source dock bounds, then sweep from its previous 30 Hz position so a
	# fast shot cannot tunnel through a floating/moving dock between ticks.
	var position: Vector2 = bullet.get("pos", Vector2.ZERO)
	var velocity: Vector2 = bullet.get("vel", Vector2.ZERO)
	var dock_bounds := _dock_hit_bounds(dock).grow(4.0)
	return _segment_intersects_rect(position - velocity, position, dock_bounds)

func _segment_intersects_rect(from: Vector2, to: Vector2, bounds: Rect2) -> bool:
	# Slab intersection in 0..1 segment space.  This avoids relying on a
	# physics node for the intentionally lightweight, data-driven projectile
	# list and works for horizontal, vertical, and diagonal shots.
	if bounds.has_point(from) or bounds.has_point(to):
		return true
	var direction := to - from
	var entry := 0.0
	var exit := 1.0
	for axis in range(2):
		var origin := from.x if axis == 0 else from.y
		var delta := direction.x if axis == 0 else direction.y
		var minimum := bounds.position.x if axis == 0 else bounds.position.y
		var maximum := bounds.end.x if axis == 0 else bounds.end.y
		if absf(delta) < 0.00001:
			if origin < minimum or origin > maximum:
				return false
			continue
		var first := (minimum - origin) / delta
		var second := (maximum - origin) / delta
		entry = maxf(entry, minf(first, second))
		exit = minf(exit, maxf(first, second))
		if entry > exit:
			return false
	return true

func _create_laser(position: Vector2, direction: Vector2) -> void:
	if direction.length_squared() < 0.01:
		direction = Vector2.LEFT
	lasers.append({"pos": position, "vel": direction.normalized() * GameData.LASER_SPEED, "counter": 0})
	_play_sound("lazer")

func _laser_hit_bounds(laser: Dictionary) -> Rect2:
	# Flash anchors LazerData at the firing enemy's x and y - height / 2. Its
	# scaleX is -1, so the 121px slab extends left from that anchor rather than
	# behaving like a small projectile centred on it.
	var position: Vector2 = laser.get("pos", Vector2.ZERO)
	var velocity: Vector2 = laser.get("vel", Vector2.LEFT)
	var size := GameData.LASER_SIZE
	var left := position.x - size.x if velocity.x < 0.0 else position.x
	return Rect2(Vector2(left, position.y - size.y * 0.5), size)

func _player_hit_bounds() -> Rect2:
	var position: Vector2 = player.get("pos", Vector2.ZERO)
	return Rect2(position - Vector2(5.5, PLAYER_COLLISION_HALF_HEIGHT), Vector2(11.0, PLAYER_COLLISION_HALF_HEIGHT * 2.0))

func _damage_player(amount: float) -> void:
	if amount <= 0.0 or player.is_empty():
		return
	player["health"] = maxf(0.0, float(player.get("health", 0.0)) - amount)
	# TintObject starts at red and fades back to normal over 0.3 seconds.
	if int(player.get("hurt_flash_ticks", 0)) <= 0:
		player["hurt_flash_ticks"] = PLAYER_HURT_FLASH_TICKS

func _friendly_hit_bounds(friendly: Dictionary) -> Rect2:
	var position: Vector2 = friendly.get("pos", Vector2.ZERO)
	return Rect2(position - Vector2(13.0, 24.0), Vector2(26.0, 24.0))

func _building_hit_bounds(building: Dictionary) -> Rect2:
	var position: Vector2 = building.get("pos", Vector2.ZERO)
	return Rect2(position - Vector2(31.0, 48.0), Vector2(62.0, 48.0))

func _update_lasers() -> void:
	for index in range(lasers.size() - 1, -1, -1):
		var laser: Dictionary = lasers[index]
		laser["counter"] = int(laser.get("counter", 0)) + 1
		laser["pos"] = laser.get("pos", Vector2.ZERO) + laser.get("vel", Vector2.ZERO)
		var bounds := _laser_hit_bounds(laser)
		for building_index in range(buildings.size()):
			var building: Dictionary = buildings[building_index]
			if building.get("state", "rubble") == "complete" and bounds.intersects(_building_hit_bounds(building)):
				building["health"] = float(building.get("health", 0.0)) - GameData.LASER_BUILDING_DAMAGE_PER_TICK
				buildings[building_index] = building
		for friendly_index in range(friendlies.size()):
			var friendly: Dictionary = friendlies[friendly_index]
			if bounds.intersects(_friendly_hit_bounds(friendly)):
				friendly["health"] = float(friendly.get("health", 0.0)) - GameData.LASER_FRIENDLY_DAMAGE_PER_TICK
				friendlies[friendly_index] = friendly
		if int(laser.get("counter", 0)) % GameData.LASER_PLAYER_DAMAGE_INTERVAL_TICKS == 0 and bounds.intersects(_player_hit_bounds()):
			_damage_player(GameData.LASER_PLAYER_DAMAGE)
		if int(laser.get("counter", 0)) > GameData.LASER_LIFETIME_TICKS:
			lasers.remove_at(index)
		else:
			lasers[index] = laser

func _create_coin(position: Vector2) -> void:
	coins.append({
		"pos": position,
		"vel": Vector2(random.randf_range(0.0, 6.0) * (-1.0 if random.randf() < 0.5 else 1.0), -random.randf_range(5.0, 15.0)),
		"counter": 0,
	})

func _create_heart(position: Vector2) -> void:
	hearts.append({
		"pos": position,
		"vel": Vector2(random.randf_range(0.0, 6.0) * (-1.0 if random.randf() < 0.5 else 1.0), -random.randf_range(5.0, 15.0)),
		"counter": 0,
	})

func _create_box(position: Vector2, floating: bool = false, balloon_id: int = -1) -> void:
	boxes.append({
		"pos": position,
		"vel": Vector2.ZERO,
		"health": float(GameData.CRATE_HEALTH),
		"counter": 0,
		"floating": floating,
		"balloon_id": balloon_id,
	})

func _create_balloon(anchor: Vector2, with_box: bool) -> void:
	var balloon_id := next_balloon_id
	next_balloon_id += 1
	# Balloon is a Bitmap whose source placement is bottom-centred at anchor.
	# Keep its centre in runtime data so the existing generic renderer matches
	# Flash's x=anchor-width/2, y=anchor-height placement.
	var balloon_position := anchor + Vector2(0.0, -23.0)
	balloons.append({"id": balloon_id, "pos": balloon_position, "counter": 0})
	if with_box:
		_create_box(balloon_position + Vector2(-0.5, 35.0), true, balloon_id)

func _release_balloon_box(balloon_id: int) -> void:
	for index in range(boxes.size()):
		var box: Dictionary = boxes[index]
		if int(box.get("balloon_id", -1)) == balloon_id:
			box["floating"] = false
			box["balloon_id"] = -1
			boxes[index] = box
			return

func _update_pickups() -> void:
	for index in range(coins.size() - 1, -1, -1):
		var coin: Dictionary = coins[index]
		coin["counter"] = int(coin.get("counter", 0)) + 1
		var velocity: Vector2 = coin.get("vel", Vector2.ZERO)
		velocity.y += GameData.PLAYER_GRAVITY
		velocity.x *= GameData.PLAYER_FRICTION
		var position: Vector2 = coin.get("pos", Vector2.ZERO) + velocity
		var ground_y := _ground_y_at(position.x, position.y - velocity.y)
		if is_finite(ground_y) and position.y >= ground_y:
			position.y = ground_y
			velocity.y = 0.0
		coin["pos"] = position
		coin["vel"] = velocity
		if position.distance_to(player.get("pos", Vector2.ZERO)) < 20.0:
			money += 1
			score += 2
			# Flash onCoin gives money feedback as a small $1 bitmap that rises and
			# fades at the collected coin's post-gravity position.
			_create_float_text("$1", position, true)
			coins.remove_at(index)
			_play_sound("coin")
		elif _map_to_source_pixels(position).y > GameData.COIN_DESPAWN_Y or int(coin.get("counter", 0)) > GameData.COIN_LIFETIME_TICKS:
			coins.remove_at(index)
		else:
			coins[index] = coin
	for index in range(hearts.size() - 1, -1, -1):
		var heart: Dictionary = hearts[index]
		heart["counter"] = int(heart.get("counter", 0)) + 1
		var heart_velocity: Vector2 = heart.get("vel", Vector2.ZERO)
		heart_velocity.y += GameData.PLAYER_GRAVITY
		heart_velocity.x *= GameData.PLAYER_FRICTION
		var heart_position: Vector2 = heart.get("pos", Vector2.ZERO) + heart_velocity
		var heart_ground := _ground_y_at(heart_position.x, heart_position.y - heart_velocity.y)
		if is_finite(heart_ground) and heart_position.y >= heart_ground:
			heart_position.y = heart_ground
			heart_velocity = Vector2.ZERO
		heart["pos"] = heart_position
		heart["vel"] = heart_velocity
		if heart_position.distance_to(player.get("pos", Vector2.ZERO)) < 21.0:
			player["health"] = minf(float(GameData.PLAYER_MAX_HEALTH), float(player.get("health", 0.0)) + GameData.HEART_HEAL)
			score += GameData.HEART_SCORE
			hearts.remove_at(index)
			_play_sound("pickup")
		elif _map_to_source_pixels(heart_position).y > GameData.COIN_DESPAWN_Y or int(heart.get("counter", 0)) > GameData.COIN_LIFETIME_TICKS:
			hearts.remove_at(index)
		else:
			hearts[index] = heart

func _create_float_text(text: String, position: Vector2, money_text: bool = false) -> void:
	float_texts.append({
		"text": text,
		"pos": position,
		"alpha": 1.0,
		"money_text": money_text,
	})

func _update_float_texts() -> void:
	for index in range(float_texts.size() - 1, -1, -1):
		var float_text: Dictionary = float_texts[index]
		float_text["alpha"] = float(float_text.get("alpha", 1.0)) - 0.03
		float_text["pos"] = float_text.get("pos", Vector2.ZERO) + Vector2(0.0, -1.8)
		if float(float_text.get("alpha", 0.0)) <= 0.0:
			float_texts.remove_at(index)
		else:
			float_texts[index] = float_text

func _update_boxes_and_balloons() -> void:
	for index in range(boxes.size() - 1, -1, -1):
		var box: Dictionary = boxes[index]
		box["counter"] = int(box.get("counter", 0)) + 1
		if float(box.get("health", 0.0)) <= 0.0:
			var position: Vector2 = box.get("pos", Vector2.ZERO)
			if random.randf() < GameData.CRATE_COIN_DROP_CHANCE:
				for coin_index in range(random.randi_range(GameData.CRATE_MIN_COINS, GameData.CRATE_MAX_COINS)):
					_create_coin(position)
				for heart_index in range(random.randi_range(GameData.CRATE_MIN_HEARTS, GameData.CRATE_MAX_HEARTS)):
					_create_heart(position)
			score += GameData.CRATE_SCORE
			boxes.remove_at(index)
			_play_sound("box")
			continue
		if bool(box.get("floating", false)):
			var carrier := _find_balloon(int(box.get("balloon_id", -1)))
			if not carrier.is_empty():
				box["pos"] = carrier.get("pos", Vector2.ZERO) + Vector2(-0.5, 35.0)
				boxes[index] = box
				continue
			box["floating"] = false
			box["balloon_id"] = -1
		var velocity: Vector2 = box.get("vel", Vector2.ZERO)
		velocity.y += GameData.PLAYER_GRAVITY
		var position: Vector2 = box.get("pos", Vector2.ZERO) + velocity
		var ground_y := _ground_y_at(position.x, position.y - velocity.y)
		if is_finite(ground_y) and position.y >= ground_y:
			position.y = ground_y
			velocity.y = 0.0
		box["pos"] = position
		box["vel"] = velocity
		if _map_to_source_pixels(position).y > GameData.COIN_DESPAWN_Y:
			boxes.remove_at(index)
		else:
			boxes[index] = box
	for index in range(balloons.size() - 1, -1, -1):
		var balloon: Dictionary = balloons[index]
		balloon["counter"] = int(balloon.get("counter", 0)) + 1
		var balloon_position: Vector2 = balloon.get("pos", Vector2.ZERO)
		balloon_position.y -= 1.0
		balloon["pos"] = balloon_position
		if _map_to_source_pixels(balloon_position).y < -652.0:
			balloons.remove_at(index)
		else:
			balloons[index] = balloon

func _find_balloon(balloon_id: int) -> Dictionary:
	for balloon in balloons:
		if int(balloon.get("id", -1)) == balloon_id:
			return balloon
	return {}

func _nearest_enemy_index(position: Vector2, maximum_distance: float = INF) -> int:
	var closest := -1
	var closest_distance := maximum_distance
	for index in range(enemies.size()):
		var distance := position.distance_to(enemies[index].get("pos", Vector2.ZERO))
		if distance <= closest_distance:
			closest = index
			closest_distance = distance
	return closest

func _nearest_friendly_index(position: Vector2) -> int:
	var closest := -1
	var closest_distance := INF
	for index in range(friendlies.size()):
		var distance := position.distance_to(friendlies[index].get("pos", Vector2.ZERO))
		if distance < closest_distance:
			closest = index
			closest_distance = distance
	return closest

func _nearest_complete_building_index(position: Vector2) -> int:
	var closest := -1
	var closest_distance := INF
	for index in range(buildings.size()):
		var building: Dictionary = buildings[index]
		if building.get("state", "rubble") != "complete":
			continue
		var distance := position.distance_to(building.get("pos", Vector2.ZERO))
		if distance < closest_distance:
			closest = index
			closest_distance = distance
	return closest

func _draw() -> void:
	if mode != MODE_PLAY:
		return
	# Frame 2 of the original root timeline is the authored night-sky backdrop:
	# moon, stars, clouds, and distant island silhouettes.  It lives in screen
	# space behind c_mc, so draw the unmodified export before applying the world
	# camera transform.  Keeping the world at its recovered 1:1 scale is
	# important: this restores the missing atmosphere without distorting islands,
	# docks, or collision geometry.
	_draw_screen_backdrop()
	draw_set_transform(-camera_position)
	_draw_stage_backdrop()
	_draw_pipes()
	_draw_buildings()
	_draw_docks()
	_draw_balloons()
	_draw_boxes()
	_draw_smoke()
	_draw_pickups()
	_draw_lasers()
	_draw_bullets()
	_draw_friendlies()
	_draw_enemies()
	_draw_player()
	_draw_float_texts()
	draw_set_transform(Vector2.ZERO)
	_draw_aim_cursor()

func _draw_screen_backdrop() -> void:
	# Shape 2 in the original is a single vertical 1x409 sky gradient stretched
	# across the full stage.  It remains visible wherever the transparent
	# parallax art does not cover the viewport, so no repeated background tile
	# can leave a hard join at the screen border.
	var gradient_texture := _load_texture("res://assets/original/stage/sky_gradient.png")
	if gradient_texture != null:
		draw_texture_rect(gradient_texture, Rect2(Vector2(0.0, -4.0), Vector2(VIEW_SIZE.x, 464.0)), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color("#1f304e"))

	var sky_texture := _load_texture("res://assets/original/stage/sky_stars.png")
	var distant_texture := _load_texture("res://assets/original/stage/distant_islands.png")
	if sky_texture != null and distant_texture != null:
		# MainTimeline.controlPlayer moves background_mc at 1/5 camera speed and
		# skyStuff_mc at 1/12.  The oversized source clips cover the viewport
		# naturally; they are never repeated or stretched.
		var layer_rects := _background_layer_rects()
		draw_texture_rect(sky_texture, layer_rects.get("sky", SKY_STARS_INITIAL_RECT), false)
		draw_texture_rect(distant_texture, layer_rects.get("distant", DISTANT_ISLANDS_INITIAL_RECT), false)
	else:
		# Keep the previously restored root frame as an editor-import fallback, but
		# omit its one-pixel FFDec crop artifacts at either horizontal edge.
		var fallback_texture := _load_texture("res://assets/original/stage/background.png")
		if fallback_texture != null:
			var safe_rect := Rect2(1.0, 0.0, VIEW_SIZE.x - 2.0, VIEW_SIZE.y)
			draw_texture_rect_region(fallback_texture, safe_rect, safe_rect, Color.WHITE)
	_draw_clouds()

func _draw_clouds() -> void:
	for cloud in small_clouds:
		var texture := _load_texture("res://assets/original/stage/small_cloud_%d.png" % int(cloud.get("frame", 1)))
		var position: Vector2 = cloud.get("pos", Vector2.ZERO)
		if texture != null:
			draw_texture_rect(texture, Rect2(position, texture.get_size() * 1.25), false, Color(1.0, 1.0, 1.0, 1.0))
		_draw_cloud_puff(position, 0.32)
	for cloud in big_clouds:
		var texture := _load_texture("res://assets/original/stage/big_cloud_%d.png" % int(cloud.get("frame", 1)))
		var position: Vector2 = cloud.get("pos", Vector2.ZERO)
		if texture != null:
			draw_texture_rect(texture, Rect2(position, texture.get_size() * 1.45), false, Color(1.0, 1.0, 1.0, 1.0))
		_draw_cloud_puff(position, 0.60)

func _draw_cloud_puff(position: Vector2, scale: float) -> void:
	var color := Color(0.89, 0.96, 0.92, 0.9)
	draw_circle(position + Vector2(18.0, 15.0) * scale, 15.0 * scale, color)
	draw_circle(position + Vector2(40.0, 9.0) * scale, 21.0 * scale, color)
	draw_circle(position + Vector2(65.0, 16.0) * scale, 17.0 * scale, color)
	draw_rect(Rect2(position + Vector2(15.0, 15.0) * scale, Vector2(55.0, 15.0) * scale), color)

func _background_layer_rects() -> Dictionary:
	var camera_delta := camera_position - INITIAL_BACKGROUND_CAMERA
	var sky_rect := SKY_STARS_INITIAL_RECT
	sky_rect.position -= camera_delta / 12.0
	var distant_rect := DISTANT_ISLANDS_INITIAL_RECT
	distant_rect.position -= camera_delta / 5.0
	return {"sky": sky_rect, "distant": distant_rect}

func _draw_stage_backdrop() -> void:
	var layout := StageLayout.layout_for(stage_id)
	for island in layout.get("islands", []):
		var character_id := int(island.get("character_id", 0))
		var bounds := StageLayout.island_bounds_in_map(island)
		var texture := _load_texture("res://assets/original/stage/island_%d.png" % character_id)
		if texture != null:
			draw_texture_rect(texture, bounds, false)
		else:
			draw_rect(bounds, Color("#315c3b"))
			draw_line(bounds.position, Vector2(bounds.end.x, bounds.position.y), Color("#8bd05d"), 2.0)
	for decoration in layout.get("decorations", []):
		var decoration_id := int(decoration.get("character_id", 0))
		# FFDec's source SVGs retain embedded bitmap-pattern fills that Godot's
		# SVG importer omits. These lossless local PNG renders are generated from
		# those same source shapes and preserve the original SVG alongside them.
		var decoration_texture := _load_texture("res://assets/original/stage/tree_%d.png" % decoration_id)
		if decoration_texture != null:
			draw_texture_rect(decoration_texture, StageLayout.decoration_bounds_in_map(decoration), false)

func _draw_fallback_stage() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#102746"))
	for platform in _platforms_for_stage():
		draw_rect(platform, Color("#315c3b"))
		draw_line(platform.position, Vector2(platform.end.x, platform.position.y), Color("#8bd05d"), 2.0)

func _draw_pipes() -> void:
	var layout := StageLayout.layout_for(stage_id)
	for pipe in layout.get("pipes", []):
		var character_id := int(pipe.get("character_id", 0))
		var bounds := StageLayout.pipe_bounds_in_map(pipe)
		var texture := _load_texture("res://assets/original/stage/pipe_%d.png" % character_id)
		if texture != null:
			draw_texture_rect(texture, bounds, false)
		else:
			draw_rect(bounds, Color(0.12, 0.5, 0.63, 0.72))
			draw_rect(bounds, Color("#a6f4e1"), false, 1.0)

func _draw_buildings() -> void:
	for index in range(buildings.size()):
		var site: Dictionary = buildings[index]
		var position: Vector2 = site.get("pos", Vector2.ZERO)
		var state := str(site.get("state", "rubble"))
		var art_id := str(site.get("id", "rubble")) if state == "complete" else "rubble"
		var texture := _load_texture("res://assets/original/buildings/%s.png" % art_id)
		var rect := Rect2(position - Vector2(31, 48), Vector2(62, 48))
		if texture != null:
			draw_texture_rect(texture, rect, false, Color(1, 1, 1, 0.7 if bool(site.get("constructing", false)) else 1.0))
		else:
			draw_rect(rect, Color("#7b8357") if state == "complete" else Color("#8b8a83"))
		if bool(site.get("constructing", false)):
			var completion := float(site.get("build_health", 0.0)) / maxf(float(site.get("build_total", 1.0)), 1.0)
			_draw_health_bar(position + Vector2(-25, -58), 50.0, completion, Color("#d4ee77"))
		elif state == "complete":
			var data: Dictionary = GameData.get_building(art_id)
			_draw_health_bar(position + Vector2(-25, -58), 50.0, float(site.get("health", 0.0)) / maxf(float(data.get("finished_health", 1.0)), 1.0), Color("#89e8a6"))
		if selected_building != "" and state == "rubble" and player.get("pos", Vector2.ZERO).distance_to(position) < 40.0:
			draw_arc(position, 26.0, 0.0, TAU, 24, Color("#f3f8c8"), 1.5)

func _draw_docks() -> void:
	for dock in docks:
		var dock_id := str(dock.get("id", "blue"))
		var texture := _load_texture("res://assets/original/sprites/dock_%s.png" % dock_id)
		var position: Vector2 = dock.get("pos", Vector2.ZERO)
		if texture != null:
			draw_texture_rect(texture, Rect2(position - DOCK_CANVAS_REGISTRATION, DOCK_RENDER_SIZE), false)
		else:
			draw_rect(Rect2(position - DOCK_CANVAS_REGISTRATION, DOCK_RENDER_SIZE), Color("#5f90d4"))
		var portal_frame := 1 + int(dock.get("counter", 0)) % 5
		var portal_texture := _load_texture("res://assets/original/sprites/teleporter_%02d.png" % portal_frame)
		if portal_texture != null:
			draw_texture_rect(portal_texture, Rect2(position - Vector2(12.5, 23.5), Vector2(25.0, 47.0)), false)
		var data: Dictionary = GameData.get_dock(dock_id)
		_draw_health_bar(position + Vector2(-15, _dock_height(dock_id) + 15.0), 30.0, float(dock.get("health", 0.0)) / maxf(float(data.get("health", 1.0)), 1.0), Color("#8ee2f7"))

func _dock_half_width(dock_id: String) -> float:
	return float(DOCK_HALF_WIDTHS.get(dock_id, 114.0))

func _dock_height(dock_id: String) -> float:
	return float(DOCK_HEIGHTS.get(dock_id, 49.0))

func _draw_player() -> void:
	var position: Vector2 = player.get("pos", Vector2.ZERO)
	var direction := float(player.get("facing", 1.0))
	var hurt_amount := float(player.get("hurt_flash_ticks", 0)) / float(PLAYER_HURT_FLASH_TICKS)
	var player_tint := Color.WHITE.lerp(Color("#ff1d1d"), hurt_amount)
	var body_texture := _player_body_texture()
	if body_texture != null:
		# DefineSprite 566's registration is at the body centre; the transparent
		# export is 11x24 with its source origin at (5.5, 12.5).
		draw_set_transform(position - camera_position, 0.0, Vector2(direction, 1.0))
		draw_texture_rect(body_texture, PLAYER_BODY_DRAW_RECT, false, player_tint)
		draw_set_transform(-camera_position)
	else:
		draw_circle(position + Vector2(0, -10), 9.0, Color("#f8e7b0"))
		draw_rect(Rect2(position + Vector2(-6, -10), Vector2(12, 18)), Color("#ff8d43"))

	var weapon_pose := _player_weapon_pose()
	var weapon_frame := int(weapon_pose.get("frame", 1))
	var weapon_texture := _load_texture("res://assets/original/player/weapon_%02d.png" % weapon_frame)
	if weapon_texture != null:
		var weapon_pivot: Vector2 = weapon_pose.get("pivot", position + PLAYER_WEAPON_PIVOT)
		var weapon_rotation := float(weapon_pose.get("rotation", 0.0))
		var weapon_facing := float(weapon_pose.get("facing", direction))
		draw_set_transform(weapon_pivot - camera_position, weapon_rotation, Vector2(weapon_facing, 1.0))
		# DefineSprite 338 stays a distinct child of Player and rotates around its
		# own recovered registration point rather than being a static body overlay.
		draw_texture_rect(weapon_texture, PLAYER_WEAPON_DRAW_RECT, false, player_tint)
		var flash_ticks := int(player.get("muzzle_flash_ticks", 0))
		var flash_texture := _load_texture("res://assets/original/player/muzzle_flash.png")
		if flash_texture != null and flash_ticks > 0:
			var flash_position: Vector2 = weapon_pose.get("flash_position", Vector2.ZERO)
			var flash_alpha := 1.0 if flash_ticks >= 3 else float(flash_ticks) * 0.5
			var flash_rect := Rect2(flash_position - Vector2(2.0, 5.0), MUZZLE_FLASH_DRAW_SIZE)
			draw_texture_rect(flash_texture, flash_rect, false, Color(1.0, 1.0, 1.0, flash_alpha))
		draw_set_transform(-camera_position)
	if interface_font != null:
		draw_string(interface_font, position + Vector2(-10.0, -20.0), "YOU", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 8, Color("#eefad7"))
	_draw_health_bar(position + Vector2(-17, -PLAYER_COLLISION_HALF_HEIGHT - 10), 34.0, float(player.get("health", 0.0)) / GameData.PLAYER_MAX_HEALTH, Color("#8eea8f"))

func _player_body_texture() -> Texture2D:
	var path := "res://assets/original/player/body_standing.png"
	var velocity: Vector2 = player.get("vel", Vector2.ZERO)
	if bool(player.get("grounded", false)) and absf(velocity.x) > 0.01:
		var walk_frame := 1 + (int(simulation_tick / 4) % 3)
		path = "res://assets/original/player/body_walk_%02d.png" % walk_frame
	var texture := _load_texture(path)
	if texture != null:
		return texture
	return player_texture

func _draw_enemies() -> void:
	for enemy in enemies:
		var position: Vector2 = enemy.get("pos", Vector2.ZERO) + _enemy_animation_offset(enemy)
		var enemy_id := str(enemy.get("id", "small_flying"))
		var size := _enemy_render_size(enemy_id)
		var wrapper_texture := _load_texture(_enemy_wrapper_texture_path(enemy_id))
		if wrapper_texture != null:
			# Do not squash the parent frames. DefineSprite 262's shared canvas
			# preserves per-enemy nested offsets and is drawn at native 1:1 scale.
			draw_set_transform(position - camera_position, 0.0, Vector2(float(enemy.get("move_dir", 1.0)), 1.0))
			draw_texture_rect(wrapper_texture, Rect2(-ENEMY_WRAPPER_REGISTRATION, ENEMY_WRAPPER_SIZE), false)
			draw_set_transform(-camera_position)
		else:
			var texture := _load_texture(_enemy_texture_path(enemy_id))
			if texture != null:
				draw_texture_rect(texture, Rect2(position - size * 0.5, size), false)
			else:
				draw_circle(position, 12.0, Color("#cc6d77"))
		var data: Dictionary = GameData.get_enemy(enemy_id)
		var body_top := _enemy_foot_offset(enemy_id) - size.y
		# GiveHealthBar.to(enemy, 20, 4, ...) is a constant 20px source bar,
		# located just above each native body rather than stretched to its width.
		_draw_health_bar(position + Vector2(-10.0, body_top - 6.0), 20.0, float(enemy.get("health", 0.0)) / maxf(float(data.get("health", 1.0)), 1.0), Color("#e5a4a4"))

func _enemy_animation_offset(enemy: Dictionary) -> Vector2:
	var counter := float(enemy.get("counter", 0))
	if str(enemy.get("movement", "walk")) != "walk":
		return Vector2(0.0, sin(counter * 0.24) * 1.5)
	if bool(enemy.get("walk", true)):
		return Vector2(0.0, absf(sin(counter * 0.78)) * -1.0)
	return Vector2.ZERO

func _draw_friendlies() -> void:
	for friendly in friendlies:
		var kind := str(friendly.get("kind", "old_man"))
		var path := "res://assets/original/sprites/%s.png" % _friendly_art_name(kind)
		var texture := _load_texture(path)
		var walking := absf(float(friendly.get("move_dir", 0.0))) > 0.0 and int(friendly.get("move_counter", 0)) > 0
		var bob := -absf(sin(float(friendly.get("counter", 0)) * 0.78)) if walking else 0.0
		var position: Vector2 = friendly.get("pos", Vector2.ZERO) + Vector2(0.0, bob)
		if texture != null:
			draw_set_transform(position - camera_position, 0.0, Vector2(float(friendly.get("facing", 1.0)), 1.0))
			draw_texture_rect(texture, Rect2(-Vector2(13, 24), Vector2(26, 24)), false)
			draw_set_transform(-camera_position)
		else:
			draw_circle(position, 8.0, Color("#ffe5a2"))
		_draw_health_bar(position + Vector2(-10, -31), 20.0, float(friendly.get("health", 0.0)) / GameData.FRIENDLY_TOTAL_HEALTH, Color("#8eea8f"))
		if str(friendly.get("role", "fighter")) == "fighter":
			_draw_friendly_weapon(friendly, position)

func _draw_smoke() -> void:
	# The recovered Smoke bitmap has inconsistent alpha data across importers.
	# Draw the source-style rising dust directly for every rubble pile as well,
	# so the construction-site plume is always present in the live world.
	for index in range(buildings.size()):
		var building: Dictionary = buildings[index]
		if building.get("state", "rubble") != "rubble":
			continue
		_draw_rubble_dust(building.get("pos", Vector2.ZERO), index)
	var texture := _load_texture("res://assets/original/effects/smoke.png")
	if texture == null:
		return
	for smoke in smokes:
		var position: Vector2 = smoke.get("pos", Vector2.ZERO)
		var scale := float(smoke.get("scale", SMOKE_INITIAL_SCALE))
		draw_set_transform(position - camera_position, 0.0, Vector2(scale, scale))
		draw_texture(texture, Vector2.ZERO, Color(0.82, 0.94, 0.82, float(smoke.get("alpha", 1.0))))
		draw_set_transform(-camera_position)

func _draw_rubble_dust(origin: Vector2, seed: int) -> void:
	for puff_index in range(3):
		var phase := fmod(float(simulation_tick + seed * 17 + puff_index * 13), 54.0) / 54.0
		var x_offset := sin((phase + float(puff_index) * 0.31) * TAU) * (4.0 + phase * 7.0)
		var position := origin + Vector2(x_offset, -8.0 - phase * 34.0)
		var radius := 3.0 + phase * 4.5
		var alpha := 0.78 * (1.0 - phase)
		draw_circle(position, radius, Color(0.79, 0.86, 0.76, alpha))
		draw_circle(position + Vector2(-radius * 0.55, radius * 0.2), radius * 0.63, Color(0.89, 0.92, 0.84, alpha * 0.75))

func _draw_bullets() -> void:
	for bullet in bullets:
		var kind := str(bullet.get("kind", "bullet"))
		var path := "res://assets/original/pickups/%s.png" % ("bullet" if kind == "bullet" else kind)
		var texture := _load_texture(path)
		var position: Vector2 = bullet.get("pos", Vector2.ZERO)
		if texture != null:
			if kind == "missile":
				var velocity: Vector2 = bullet.get("vel", Vector2.RIGHT)
				var rotation := velocity.angle() if velocity.length_squared() > 0.01 else 0.0
				# MissileData is a 12x5 horizontal source bitmap. Rotate its native
				# centre around the live projectile direction instead of forcing it
				# into the 8x8 bullet rect.
				draw_set_transform(position - camera_position, rotation)
				draw_texture_rect(texture, Rect2(-6.0, -2.5, 12.0, 5.0), false)
				draw_set_transform(-camera_position)
			else:
				draw_texture_rect(texture, Rect2(position - Vector2(4, 4), Vector2(8, 8)), false)
		else:
			draw_circle(position, 3.0, Color("#fff2a6"))

func _draw_lasers() -> void:
	for laser in lasers:
		var position: Vector2 = laser.get("pos", Vector2.ZERO)
		var velocity: Vector2 = laser.get("vel", Vector2.LEFT)
		var texture := _load_texture("res://assets/original/pickups/lazer.png")
		if texture != null:
			var facing := -1.0 if velocity.x < 0.0 else 1.0
			draw_set_transform(position - camera_position, 0.0, Vector2(facing, 1.0))
			draw_texture_rect(texture, Rect2(Vector2(0.0, -GameData.LASER_SIZE.y * 0.5), GameData.LASER_SIZE), false)
			draw_set_transform(-camera_position)
		else:
			draw_rect(_laser_hit_bounds(laser), Color("#7effff"))

func _draw_pickups() -> void:
	for coin in coins:
		_draw_pickup_texture("coin_1", coin.get("pos", Vector2.ZERO), Vector2(6, 6), Color("#ffd94f"))
	for heart in hearts:
		_draw_pickup_texture("heart", heart.get("pos", Vector2.ZERO), Vector2(9, 7), Color("#fa6884"))

func _draw_float_texts() -> void:
	if interface_font == null:
		return
	for float_text in float_texts:
		var position: Vector2 = float_text.get("pos", Vector2.ZERO)
		var alpha := float(float_text.get("alpha", 1.0))
		var money_text := bool(float_text.get("money_text", false))
		var color := Color("#bcfecf") if money_text else Color("#bce4fe")
		var shadow := Color("#042048") if money_text else Color("#00263e")
		# Source FloatText is an embedded 10px font with a tiny glow, converted
		# to a Bitmap then moved in world space. Draw the same visual hierarchy.
		draw_string(interface_font, position + Vector2(1.0, 9.0), str(float_text.get("text", "")), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color(shadow, alpha * 0.75))
		draw_string(interface_font, position + Vector2(0.0, 8.0), str(float_text.get("text", "")), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color(color, alpha))

func _draw_boxes() -> void:
	for box in boxes:
		_draw_pickup_texture("box", box.get("pos", Vector2.ZERO), Vector2(24, 24), Color("#b98143"))

func _draw_balloons() -> void:
	for balloon in balloons:
		_draw_pickup_texture("balloon", balloon.get("pos", Vector2.ZERO), Vector2(17, 46), Color("#f4c76c"))

func _draw_pickup_texture(asset_id: String, position: Vector2, dimensions: Vector2, fallback: Color) -> void:
	var texture := _load_texture("res://assets/original/pickups/%s.png" % asset_id)
	if texture != null:
		draw_texture_rect(texture, Rect2(position - dimensions * 0.5, dimensions), false)
	else:
		draw_circle(position, dimensions.x * 0.5, fallback)

func _draw_health_bar(position: Vector2, width: float, fraction: float, color: Color) -> void:
	draw_rect(Rect2(position, Vector2(width, 4)), Color(0.03, 0.06, 0.08, 0.85))
	draw_rect(Rect2(position + Vector2(1, 1), Vector2(maxf(0.0, width - 2.0) * clampf(fraction, 0.0, 1.0), 2)), color)

func _draw_aim_cursor() -> void:
	if mode != MODE_PLAY:
		return
	var point := get_viewport().get_mouse_position()
	draw_circle(point, 5.0, Color("#d9ffe3"), false, 1.0)
	draw_line(point - Vector2(8, 0), point - Vector2(3, 0), Color("#d9ffe3"), 1.0)
	draw_line(point + Vector2(3, 0), point + Vector2(8, 0), Color("#d9ffe3"), 1.0)
	draw_line(point - Vector2(0, 8), point - Vector2(0, 3), Color("#d9ffe3"), 1.0)
	draw_line(point + Vector2(0, 3), point + Vector2(0, 8), Color("#d9ffe3"), 1.0)

func _enemy_texture_path(enemy_id: String) -> String:
	var files := {
		"small_green": "enemy_small_green",
		"small_flying": "enemy_flying",
		"snail": "enemy_snail",
		"orange_flying": "enemy_orange_flying",
		"ladybug": "enemy_ladybug",
		"flying_big": "enemy_flying_big",
		"praying_mantis": "enemy_praying_mantis",
		"flying_very_big": "enemy_flying_very_big",
		"flying_blue": "enemy_flying_blue",
		"purple_centipede": "enemy_purple",
		"blue_centipede": "enemy_blue",
		"green_centipede": "enemy_green",
		"flying_mech": "enemy_flying_mech",
	}
	return "res://assets/original/sprites/%s.png" % files.get(enemy_id, "enemy_flying")

func _enemy_wrapper_texture_path(enemy_id: String) -> String:
	var frame := int(ENEMY_FRAME_BY_ID.get(enemy_id, 2))
	return "res://assets/original/enemies/enemy_%02d.png" % frame

func _enemy_render_size(enemy_id: String) -> Vector2:
	return ENEMY_NATIVE_SIZES.get(enemy_id, Vector2(11.0, 13.0))

func _enemy_foot_offset(enemy_id: String) -> float:
	return float(ENEMY_FOOT_OFFSETS.get(enemy_id, 6.0))

func _friendly_art_name(kind: String) -> String:
	var files := {
		"yellow_man": "friendly_yellow",
		"green_man": "friendly_green",
		"old_man": "friendly",
		"red_man": "friendly_red",
		"nurse": "friendly_nurse",
		"carpenter": "carpenter",
	}
	return str(files.get(kind, "friendly"))

func _load_texture(path: String) -> Texture2D:
	if texture_cache.has(path):
		return texture_cache[path]
	if not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	if resource is Texture2D:
		texture_cache[path] = resource
		return resource
	return null

func _update_hud() -> void:
	if hud_labels.is_empty():
		return
	if hud_labels.has("health"):
		var health := int(ceil(float(player.get("health", 0.0))))
		hud_labels["health"].text = "%d/%d" % [health, GameData.PLAYER_MAX_HEALTH]
		hud_labels["soldiers"].text = "%d/%d" % [friendlies.size(), GameData.MAX_FRIENDLIES]
		hud_labels["money"].text = "$%d" % money
		hud_labels["wave"].text = str(wave)
		hud_labels["score"].text = str(score)
		if hud_health_fill != null:
			hud_health_fill.size.x = 148.0 * clampf(float(health) / float(GameData.PLAYER_MAX_HEALTH), 0.0, 1.0)
	if status_label != null:
		status_label.text = pending_status

func _set_status(message: String) -> void:
	pending_status = message
	if status_label != null:
		status_label.text = message

func _weapon_sound(weapon_id: String) -> String:
	var sounds := {
		"pistol": "pistol",
		"desert_eagle": "desert_eagle",
		"mac10": "mac10",
		"shotgun": "shotgun",
		"ump": "ump",
		"m16": "m16",
		"auto_shotgun": "shotgun",
		"p90": "mac10",
		"aug": "m16",
		"flamer": "fireball",
		"chaingun": "mac10",
		"bazooka": "rocket",
	}
	return str(sounds.get(weapon_id, "pistol"))

func _play_sound(sound_id: String) -> void:
	# Headless verification has no audio device/clock to finish one-shot players;
	# skipping playback there keeps test teardown deterministic without changing
	# the desktop game's audio behaviour.
	if DisplayServer.get_name() == "headless":
		return
	var path := "res://assets/original/audio/%s.mp3" % sound_id
	if not ResourceLoader.exists(path):
		return
	var effect := AudioStreamPlayer.new()
	effect.stream = load(path)
	effect.volume_db = -8.0
	add_child(effect)
	effect.finished.connect(effect.queue_free)
	effect.play()

func _play_sound_once(sound_id: String, interval_ticks: int) -> void:
	var last := int(sound_last_tick.get(sound_id, -interval_ticks))
	if simulation_tick - last >= interval_ticks:
		sound_last_tick[sound_id] = simulation_tick
		_play_sound(sound_id)

func _play_music(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	if not ResourceLoader.exists(path):
		return
	music_player.stop()
	current_music_path = path
	var music_stream: AudioStream = load(path)
	_configure_music_stream(music_stream)
	music_player.stream = music_stream
	music_player.volume_db = -12.0
	music_player.play()

func _configure_music_stream(stream: AudioStream) -> void:
	# SoundManager.musicChange() calls Sound.play(0, int.MAX_VALUE) in the
	# original. Imported MP3 resources default to one-shot, so set the runtime
	# stream explicitly instead of relying on editor import metadata.
	if stream is AudioStreamMP3:
		stream.loop = true

func _stop_music() -> void:
	current_music_path = ""
	if music_player != null:
		music_player.stop()

func _restart_music_if_needed() -> void:
	if current_music_path != "" and music_player != null and not music_player.playing:
		# Guard the imported-MP3 loop flag as well: if a platform ignores the
		# stream loop property, the original menu/game music still repeats.
		music_player.play()
