extends SceneTree

const StageLayout = preload("res://scripts/stage_layout_data.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/Main.tscn")
	var game: Node2D = scene.instantiate()
	root.add_child(game)
	await process_frame

	# First-stage setup follows the source's special $70/tutorial path.
	game._start_stage(1)
	_expect(game.mode == game.MODE_PLAY, "Stage 1 should enter play mode.")
	_expect(game.money == 70, "Stage 1 should start with the source-compatible $70.")
	_expect(game.paused, "The first Stage 1 launch should show the tutorial.")
	_expect(not game.first_time_playing, "Opening the tutorial should consume the one-time tutorial flag.")
	game._close_tutorial()
	_expect(not game.paused, "Closing the tutorial should resume the stage.")

	# Stage geometry comes from the source timeline's twip placements rather than
	# the baked reference-map PNG. These values pin the conversion, player start,
	# rubble anchors, and collision ground to the recovered StageLayout data.
	var stage_one_start := Vector2(504.8, 606.3)
	_expect_vector_close(StageLayout.player_start_in_map(1), stage_one_start, "Stage 1 player start should use the recovered source position.")
	_expect_vector_close(game.player.get("pos", Vector2.ZERO), stage_one_start, "The live Stage 1 player should start at the recovered map position.")
	var stage_one_layout := StageLayout.layout_for(1)
	var stage_one_island: Dictionary = stage_one_layout.get("islands", [])[0]
	var stage_one_ground := StageLayout.island_bounds_in_map(stage_one_island)
	_expect_vector_close(stage_one_ground.position, Vector2(306.6, 634.5), "Stage 1 island one should retain its source-derived ground origin.")
	_expect_vector_close(stage_one_ground.end, Vector2(799.6, 712.5), "Stage 1 island one should retain its recovered source bounds.")
	_expect(absf(game._ground_y_at(stage_one_start.x, stage_one_start.y, 11.5) - 623.0) < 0.01, "Stage 1 player start should resolve against its recovered island ground.")
	_expect(game.buildings.size() == 12, "Stage 1 should instantiate all 12 recovered rubble anchors.")
	_expect_vector_close(game.buildings[0].get("pos", Vector2.ZERO), Vector2(436.55, 405.2), "Stage 1's first rubble anchor should use its source matrix position.")
	_expect_vector_close(game.buildings[11].get("pos", Vector2.ZERO), Vector2(1098.55, 239.1), "Stage 1's final rubble anchor should use its source matrix position.")
	# Each building's defender is anchored to the platform under that exact site;
	# it must not be rehomed to the same global island as another building.
	game.friendlies.clear()
	game._create_friendly(game.buildings[0].get("pos", Vector2.ZERO), GameData.get_building("small_shack"))
	game._create_friendly(game.buildings[2].get("pos", Vector2.ZERO), GameData.get_building("small_shack"))
	_expect(game.friendlies.size() == 2, "Two separate building sites should create two defenders.")
	if game.friendlies.size() == 2:
		var first_home: Rect2 = game.friendlies[0].get("home_surface", Rect2())
		var second_home: Rect2 = game.friendlies[1].get("home_surface", Rect2())
		_expect(first_home.position != second_home.position, "Defenders from different Stage 1 platforms must retain distinct home surfaces.")
	game.friendlies.clear()

	# The root sky uses a source gradient plus two oversized transparent layers,
	# not a repeated 650px screenshot.  Pin their registrations/parallax rates
	# so no later backdrop change reintroduces a visible tile seam.
	_expect(game._load_texture("res://assets/original/stage/sky_gradient.png") != null, "The original one-pixel vertical sky gradient should be available.")
	_expect(game._load_texture("res://assets/original/stage/sky_stars.png") != null, "The original oversized moon-and-stars parallax layer should be available.")
	_expect(game._load_texture("res://assets/original/stage/distant_islands.png") != null, "The original oversized distant-islands parallax layer should be available.")
	var opening_background_layers: Dictionary = game._background_layer_rects()
	var opening_sky_rect: Rect2 = opening_background_layers.get("sky", Rect2())
	var opening_distant_rect: Rect2 = opening_background_layers.get("distant", Rect2())
	_expect_vector_close(opening_sky_rect.position, game.SKY_STARS_INITIAL_RECT.position, "Moon/stars layer should retain its recovered opening registration.")
	_expect_vector_close(opening_distant_rect.position, game.DISTANT_ISLANDS_INITIAL_RECT.position, "Distant-islands layer should retain its recovered opening registration.")
	game.camera_position = game.INITIAL_BACKGROUND_CAMERA + Vector2(120.0, 60.0)
	var scrolled_background_layers: Dictionary = game._background_layer_rects()
	var scrolled_sky_rect: Rect2 = scrolled_background_layers.get("sky", Rect2())
	var scrolled_distant_rect: Rect2 = scrolled_background_layers.get("distant", Rect2())
	_expect_vector_close(scrolled_sky_rect.position, opening_sky_rect.position - Vector2(10.0, 5.0), "Moon/stars layer should scroll at the source one-twelfth camera speed.")
	_expect_vector_close(scrolled_distant_rect.position, opening_distant_rect.position - Vector2(24.0, 12.0), "Distant-islands layer should scroll at the source one-fifth camera speed.")
	game.camera_position = game.INITIAL_BACKGROUND_CAMERA

	for stage_number in range(1, 6):
		if stage_number > 1:
			game._start_stage(stage_number)
		var expected_sites: int = int(GameData.get_stage(stage_number).get("building_site_count", 0))
		var expected_money := 70 if stage_number == 1 else 0
		_expect(game.buildings.size() == expected_sites, "Stage %d should create %d fixed sites." % [stage_number, expected_sites])
		_expect(game.money == expected_money, "Stage %d should start with $%d." % [stage_number, expected_money])
		_expect(not game.paused, "Only the initial Stage 1 launch should show the tutorial.")

	# Upgrade modes share the recovered maps but have distinct objectives/rules.
	game._start_stage(1, game.GAME_MODE_RAPID_ASSAULT)
	_expect(game.game_mode == game.GAME_MODE_RAPID_ASSAULT and game.money == 250, "Rapid Assault should use its own starting resources.")
	game.stage_elapsed_ticks = 419
	game._handle_misc()
	_expect(game.wave == 1, "Rapid Assault should not advance before its compact wave interval.")
	game.stage_elapsed_ticks = 420
	game._handle_misc()
	_expect(game.wave == 2, "Rapid Assault should advance at its compact wave interval.")
	game._start_stage(1, game.GAME_MODE_CLASSIC_SURVIVAL)
	game.wave = GameData.LAST_COMPLETED_WAVE + 1
	game.stage_elapsed_ticks = 1
	_expect(not game._handle_misc(), "Classic Survival should not win after the faithful campaign wave limit.")
	game._start_stage(1, game.GAME_MODE_CLASSIC_SURVIVAL)
	game.stage_elapsed_ticks = 480
	game._handle_misc()
	_expect(game.wave == 2 and game.enemies.size() >= 1, "Classic Survival should use rapid waves and add reinforcement enemies.")
	game._start_stage(1, game.GAME_MODE_SETTLEMENT_DEFENSE)
	_expect(game.settlement_core_indices.size() == 2, "Settlement Defense should create two protected starter buildings.")
	_expect(not game._settlement_is_destroyed(), "An intact settlement should not be considered defeated.")
	game._start_stage(1, game.GAME_MODE_SANDBOX)
	game.player["health"] = 0.0
	_expect(not game._handle_misc(), "Sandbox should not end when the player health reaches zero.")

	# Player uses separate source child symbols for body, weapon and flash. The
	# recovered source emits a pistol bullet from weapon.flash.x - 20, which is
	# around the body centre rather than the old hard-coded point above the head.
	game._start_stage(1)
	game.player["pos"] = Vector2(500.0, 600.0)
	game.player["aim"] = Vector2.RIGHT
	game.player["facing"] = 1.0
	game.equipped_weapon = "pistol"
	var pistol_pose: Dictionary = game._player_weapon_pose(Vector2.RIGHT)
	var pistol_muzzle: Vector2 = pistol_pose.get("muzzle_position", Vector2.ZERO)
	_expect(absf(pistol_muzzle.y - 600.0) < game.PLAYER_COLLISION_HALF_HEIGHT, "The source-derived pistol muzzle should be within the player body height, not above the head.")
	_expect(int(pistol_pose.get("frame", 0)) == 1, "Pistol should use original weapon frame 1.")
	game.equipped_weapon = "m16"
	_expect(int(game._player_weapon_pose(Vector2.RIGHT).get("frame", 0)) == 5, "M16 should use original weapon frame 5.")
	game.equipped_weapon = "ump"
	_expect(int(game._player_weapon_pose(Vector2.RIGHT).get("frame", 0)) == 6, "UMP should use original weapon frame 6.")
	_expect(game._load_texture("res://assets/original/player/weapon_01.png") != null, "The original direct pistol artwork should be available for the rotating player weapon layer.")
	_expect(absf(game._player_bullet_spread_degrees(false, false) - GameData.STANDING_AIM_SPREAD_DEGREES) < 0.000001, "Standing shots should use the source cursor-height spread, not the raw cursor expansion.")
	_expect(absf(game._player_bullet_spread_degrees(true, false) - GameData.MOVING_AIM_SPREAD_DEGREES) < 0.000001, "Moving shots should use the source cursor-height spread.")
	_expect(absf(game._player_bullet_spread_degrees(true, true) - GameData.JUMPING_AIM_SPREAD_DEGREES) < 0.000001, "Airborne shots should use the source cursor-height spread.")
	var game_music: AudioStream = load("res://assets/original/audio/game.mp3")
	game._configure_music_stream(game_music)
	var looping_music := game_music as AudioStreamMP3
	_expect(looping_music != null and looping_music.loop, "Game music should be explicitly looped like the original Sound.play(..., int.MAX_VALUE).")

	game._show_stage_select()
	var stage_two_button: Button
	for child in game.ui_layer.get_children():
		if child is Button and child.text == "STAGE 2":
			stage_two_button = child
	_expect(stage_two_button != null, "Stage Select should expose a Stage 2 button.")
	if stage_two_button != null:
		stage_two_button.pressed.emit()
		_expect(game.selected_stage_id == 2 and game.mode == game.MODE_GAME_MODE_SELECT, "Stage Select should open mode selection for its matching stage.")
		var faithful_mode_button: Button
		for child in game.ui_layer.get_children():
			if child is Button and child.text.begins_with("FAITHFUL CAMPAIGN"):
				faithful_mode_button = child
		_expect(faithful_mode_button != null, "Mode Select should expose Faithful Campaign.")
		if faithful_mode_button != null:
			faithful_mode_button.pressed.emit()
		_expect(game.stage_id == 2 and game.mode == game.MODE_PLAY and game.game_mode == game.GAME_MODE_FAITHFUL, "Faithful Campaign should start the selected stage.")
		_expect(game.money == 0, "Selecting Stage 2 should not carry Stage 1's starting money.")

	# The original's menu reset did not reset the global simulation/shoot counters.
	game.simulation_tick = 37
	game.shoot_counter = 4
	game._start_stage(3)
	_expect(game.simulation_tick == 37 and game.shoot_counter == 4, "Later stage starts should preserve source-compatible counters.")

	# Pipe entry is directional: stand below a bottom endpoint to travel up, or
	# above a top endpoint to travel down. The traveller remains horizontally
	# locked to the recovered pipe origin until it clears the opposite endpoint.
	game._start_stage(1)
	var stage_one_pipe: Dictionary = game._pipe_data(0)
	var pipe_origin: Vector2 = stage_one_pipe.get("origin", Vector2.ZERO)
	var pipe_endpoints: Dictionary = stage_one_pipe.get("endpoints", {})
	var pipe_top: Vector2 = pipe_endpoints.get("top", Vector2.ZERO)
	var pipe_bottom: Vector2 = pipe_endpoints.get("bottom", Vector2.ZERO)
	_expect_vector_close(pipe_origin, Vector2(551.0, 498.0), "Stage 1 pipe one should use its recovered source origin.")
	_expect_vector_close(pipe_top, Vector2(551.0, 404.5), "Stage 1 pipe one should expose its recovered top endpoint.")
	_expect_vector_close(pipe_bottom, Vector2(551.0, 591.5), "Stage 1 pipe one should expose its recovered bottom endpoint.")
	game.player["pos"] = pipe_bottom + Vector2(0.0, 1.0)
	game.player["pipe_direction"] = 0
	game.player["pipe_index"] = -1
	game._try_enter_pipe(game.player.get("pos", Vector2.ZERO))
	_expect(int(game.player.get("pipe_direction", 0)) == -1 and int(game.player.get("pipe_index", -1)) == 0, "Entering below a pipe should travel upward through that pipe.")
	var upward_before: Vector2 = game.player.get("pos", Vector2.ZERO)
	game._update_player_pipe_travel(-1)
	_expect_vector_close(game.player.get("pos", Vector2.ZERO), Vector2(pipe_origin.x, upward_before.y - GameData.PIPE_PULL_SPEED), "Upward pipe travel should lock x and pull at the source-compatible speed.")
	var pipe_steps := 0
	while int(game.player.get("pipe_direction", 0)) != 0 and pipe_steps < 30:
		game._update_player_pipe_travel(int(game.player.get("pipe_direction", 0)))
		pipe_steps += 1
	_expect(int(game.player.get("pipe_direction", 0)) == 0 and int(game.player.get("pipe_index", -1)) == -1, "Upward travel should release after clearing the top endpoint.")
	_expect(float(game.player.get("pos", Vector2.ZERO).y) < pipe_top.y, "Upward pipe travel should emerge above the top endpoint.")
	game.player["pos"] = pipe_top - Vector2(0.0, 1.0)
	game.player["pipe_direction"] = 0
	game.player["pipe_index"] = -1
	game._try_enter_pipe(game.player.get("pos", Vector2.ZERO))
	_expect(int(game.player.get("pipe_direction", 0)) == 1 and int(game.player.get("pipe_index", -1)) == 0, "Entering above a pipe should travel downward through that pipe.")
	var downward_before: Vector2 = game.player.get("pos", Vector2.ZERO)
	game._update_player_pipe_travel(1)
	_expect_vector_close(game.player.get("pos", Vector2.ZERO), Vector2(pipe_origin.x, downward_before.y + GameData.PIPE_PULL_SPEED), "Downward pipe travel should lock x and pull at the source-compatible speed.")
	pipe_steps = 0
	while int(game.player.get("pipe_direction", 0)) != 0 and pipe_steps < 30:
		game._update_player_pipe_travel(int(game.player.get("pipe_direction", 0)))
		pipe_steps += 1
	_expect(int(game.player.get("pipe_direction", 0)) == 0 and int(game.player.get("pipe_index", -1)) == -1, "Downward travel should release after clearing the bottom endpoint.")
	_expect(float(game.player.get("pos", Vector2.ZERO).y) > pipe_bottom.y, "Downward pipe travel should emerge below the bottom endpoint.")

	# The large flying enemy is the source's fixed special spawn, not a spawn
	# relative to the player's current position.
	game._start_stage(1)
	game.enemies.clear()
	game.docks.clear()
	game.wave = 6
	game.simulation_tick = 1350
	game._handle_spawns()
	var special_spawn := StageLayout.source_pixels_to_map(Vector2(-540.0, -410.0))
	_expect_vector_close(special_spawn, Vector2(15.5, 145.5), "The source special-spawn coordinate should convert into map space exactly.")
	_expect(game.enemies.size() == 1 and game.enemies[0].get("id", "") == "flying_big", "Wave 6 tick 1350 should create the fixed Flying Big special spawn.")
	if game.enemies.size() == 1:
		_expect_vector_close(game.enemies[0].get("pos", Vector2.ZERO), special_spawn, "The fixed Flying Big spawn must ignore the player's current position.")
		_expect_vector_close(game._map_to_source_pixels(game.enemies[0].get("pos", Vector2.ZERO)), Vector2(-540.0, -410.0), "The special spawn should round-trip to the recovered source coordinate.")

	# Docks originate at the source's offscreen portal coordinate. Their spawn
	# counter may reach a cadence while travelling, but they must not create an
	# enemy until after a docked update has completed.
	game._start_stage(1)
	game.enemies.clear()
	game.docks.clear()
	game._create_dock("blue", "small_green")
	_expect(game.docks.size() == 1, "Creating a dock should retain a pending offscreen dock.")
	if game.docks.size() == 1:
		_expect_vector_close(game.docks[0].get("pos", Vector2.ZERO), StageLayout.enemy_dock_initial_position_in_map(), "A new dock should begin at the source portal coordinate.")
		var pending_dock: Dictionary = game.docks[0]
		pending_dock["island_index"] = 0
		pending_dock["dock_side"] = "left"
		pending_dock["spawn_interval"] = 3
		pending_dock["counter"] = 2
		pending_dock["is_docked"] = false
		game.docks[0] = pending_dock
		game._update_docks()
		_expect(not bool(game.docks[0].get("is_docked", true)) and game.enemies.is_empty(), "A travelling dock must not spawn when its cadence expires before it docks.")
		var dock_layout := StageLayout.layout_for(1)
		var dock_island: Dictionary = dock_layout.get("islands", [])[0]
		var dock_target: Vector2 = StageLayout.island_dock_edge_points_in_map(dock_island, game._dock_half_width("blue")).get("left", Vector2.ZERO)
		pending_dock = game.docks[0]
		# The source dock may finish within 3px of its approach target. Godot must
		# snap that tolerance shut so walkers have a continuous dock-to-grass floor.
		pending_dock["pos"] = dock_target + Vector2(-2.0, 0.0)
		pending_dock["is_docked"] = false
		game.docks[0] = pending_dock
		game._update_docks()
		_expect(bool(game.docks[0].get("is_docked", false)) and game.enemies.is_empty(), "Docking should complete before any later dock spawn is allowed.")
		_expect_vector_close(game.docks[0].get("pos", Vector2.ZERO), dock_target, "A dock should snap exactly to the island edge when its approach completes.")
		game._update_docks()
		_expect(game.enemies.is_empty(), "A dock should wait for its next cadence after docking.")
		game._update_docks()
		_expect(game.enemies.size() == 1, "A dock should spawn its assigned enemy on the first post-docking cadence.")
		if game.enemies.size() == 1:
			_expect(float(game.enemies[0].get("default_dir", 0.0)) == 1.0, "A left-docked enemy should inherit the source-compatible rightward departure direction.")
			var dock_spawn_position: Vector2 = game.enemies[0].get("pos", Vector2.ZERO)
			game._update_enemies()
			_expect(game.enemies.size() == 1 and game.enemies[0].get("pos", Vector2.ZERO).distance_to(dock_spawn_position) > 0.01, "A dock-spawned ground enemy should stand/move on the dock rather than freeze outside the island bounds.")
			var live_dock: Dictionary = game.docks[0]
			var dock_position: Vector2 = live_dock.get("pos", Vector2.ZERO)
			var spawned_enemy_position: Vector2 = game.enemies[0].get("pos", Vector2.ZERO)
			_expect(absf(spawned_enemy_position.y + game._enemy_foot_offset("small_green") - dock_position.y) < 0.01, "A dock-spawned Small Green's native sprite feet should sit on the dock top.")
			# A dock spawn must cross the sealed handoff to the grass island, then
			# remain grounded instead of ping-ponging at the platform edge or falling.
			var crossing_island_left := StageLayout.island_bounds_in_map(dock_island).position.x
			for crossing_tick in range(70):
				if game.enemies.is_empty():
					break
				var crossing_enemy: Dictionary = game.enemies[0]
				crossing_enemy["move_dir"] = 1.0
				crossing_enemy["default_dir"] = 1.0
				crossing_enemy["targets_objects"] = false
				crossing_enemy["move_counter"] = 0
				game.enemies[0] = crossing_enemy
				game._update_enemies()
				game._update_docks()
				if not game.enemies.is_empty() and game.enemies[0].get("pos", Vector2.ZERO).x > crossing_island_left + 5.0:
					break
			_expect(not game.enemies.is_empty() and game.enemies[0].get("pos", Vector2.ZERO).x > crossing_island_left + 5.0, "A dock-spawned walker should cross onto the stationary grass platform instead of bouncing on its dock.")
			if not game.enemies.is_empty():
				var crossed_walker_position: Vector2 = game.enemies[0].get("pos", Vector2.ZERO)
				_expect(absf(crossed_walker_position.y + game._enemy_foot_offset("small_green") - StageLayout.island_bounds_in_map(dock_island).position.y) < 0.01, "A walker that reaches grass should remain grounded on it instead of falling into the void.")
			var player_landing_dock_position: Vector2 = game.docks[0].get("pos", dock_position)
			game.player["pos"] = player_landing_dock_position + Vector2(0.0, -40.0)
			game.player["vel"] = Vector2(0.0, 6.0)
			game.player["pipe_direction"] = 0
			for gravity_tick in range(10):
				game._update_player()
				if bool(game.player.get("grounded", false)):
					break
			_expect(bool(game.player.get("grounded", false)) and absf(float(game.player.get("pos", Vector2.ZERO).y) - (player_landing_dock_position.y - 11.5)) < 0.01, "The player should land on a dock, matching Flash applyGravity dock collision.")

	# Enemy gravity must resume when its dock is destroyed. Flash removes the
	# dock after its enemy pass, then applyGravity lets any stranded walker fall
	# rather than pinning it at the old dock height.
	game._start_stage(1)
	game.enemies.clear()
	game.docks.clear()
	var destroyed_dock_position := Vector2(190.0, 580.0)
	game.docks.append({"id": "blue", "pos": destroyed_dock_position, "health": 0.0})
	game._create_enemy("small_green", destroyed_dock_position - Vector2(0.0, 12.0))
	var stranded_enemy: Dictionary = game.enemies[0]
	stranded_enemy["speed"] = 0.0
	stranded_enemy["move_dir"] = 1.0
	stranded_enemy["default_dir"] = 1.0
	game.enemies[0] = stranded_enemy
	var stranded_y := float(game.enemies[0].get("pos", Vector2.ZERO).y)
	game._update_enemies()
	_expect(game.enemies.size() == 1 and float(game.enemies[0].get("pos", Vector2.ZERO).y) > stranded_y, "A walker stranded by a destroyed dock should begin falling rather than freeze in midair.")
	game._update_docks()
	_expect(game.docks.is_empty(), "A destroyed dock should be removed after its final update pass.")
	for fall_tick in range(40):
		if game.enemies.is_empty():
			break
		game._update_enemies()
	_expect(game.enemies.is_empty(), "A stranded walking enemy should eventually pass the source fall threshold and despawn.")

	# Shooting fliers choose a map island, fly to its right-side aiming point,
	# and emit one leftward laser on their 60-tick shooting check.
	game._start_stage(1)
	game.enemies.clear()
	game.lasers.clear()
	var shooter_layout := StageLayout.layout_for(1)
	var shooter_island: Dictionary = shooter_layout.get("islands", [])[0]
	var shooter_bounds := StageLayout.island_bounds_in_map(shooter_island)
	var shooter_target := Vector2(shooter_bounds.end.x, StageLayout.map_position(shooter_island).y - game._enemy_render_size("flying_big").y / 3.0)
	game._create_enemy("flying_big", shooter_target)
	var shooting_enemy: Dictionary = game.enemies[0]
	shooting_enemy["counter"] = GameData.ENEMY_SHOOT_CHECK_INTERVAL_TICKS - 1
	shooting_enemy["shoot_target"] = 0
	shooting_enemy["has_shot"] = false
	shooting_enemy["speed"] = 0.0
	game.enemies[0] = shooting_enemy
	game._update_enemies()
	_expect_vector_close(game.enemies[0].get("pos", Vector2.ZERO), shooter_target, "A shooting flyer should target the selected island's right-side source position.")
	_expect(bool(game.enemies[0].get("has_shot", false)), "A shooting flyer at its target should fire on the 60-tick check.")
	_expect(game.lasers.size() == 1, "A shooting flyer should create one laser when it reaches the source target.")
	if game.lasers.size() == 1:
		_expect_vector_close(game.lasers[0].get("pos", Vector2.ZERO), shooter_target, "A shooting flyer's laser should begin at the flyer target position.")
		_expect_vector_close(game.lasers[0].get("vel", Vector2.ZERO), Vector2.LEFT * GameData.LASER_SPEED, "A shooting flyer's laser should travel left at the recovered speed.")
		var source_laser_bounds: Rect2 = game._laser_hit_bounds(game.lasers[0])
		_expect_vector_close(source_laser_bounds.position, shooter_target + Vector2(-GameData.LASER_SIZE.x, -GameData.LASER_SIZE.y * 0.5), "A shooting flyer's slab should extend left from its source anchor.")
		_expect_vector_close(source_laser_bounds.size, GameData.LASER_SIZE, "A shooting flyer should use the original 121x49 laser slab.")
	game._update_enemies()
	_expect(game.lasers.size() == 1, "A shooting flyer should not emit repeated lasers after its single shot at a selected island.")
	# The player can be inside the long source slab while far from its anchor.
	# It damages every second overlapping tick, rather than acting as a small ball.
	game.lasers.clear()
	game.player["pos"] = Vector2(310.0, 300.0)
	game.player["health"] = 10.0
	game._create_laser(Vector2(400.0, 300.0), Vector2.LEFT)
	game._update_lasers()
	_expect(float(game.player.get("health", 0.0)) == 10.0, "The source laser should wait for its every-second-tick player damage cadence.")
	game._update_lasers()
	_expect(float(game.player.get("health", 0.0)) == 9.0, "A player inside the long laser slab should take its source-compatible sustained damage.")

	# Regular chasing fliers use the slower screen-space rate; this adjustment
	# must not leak into the separate shooting-flyer movement above.
	var ordinary_flyer := {
		"pos": Vector2(300.0, 300.0),
		"speed": 2.0,
		"targets_objects": false,
	}
	game.player["pos"] = Vector2(500.0, 300.0)
	game._move_flying_enemy(ordinary_flyer)
	_expect_vector_close(ordinary_flyer.get("pos", Vector2.ZERO), Vector2(300.0 + 2.0 * GameData.ORDINARY_FLYING_SPEED_SCALE, 300.0), "Ordinary chasing fliers should use the reduced movement rate.")

	# Dock spawns retain their base period and use stage-specific phase offsets.
	_expect(GameData.dock_creation_interval_for_stage(1, 1) == 1200, "Wave 1 dock cadence should use the 1200-tick base period.")
	_expect(GameData.dock_creation_interval_for_stage(1, 5) == 1200, "Changing stage must not shorten the Wave 1 dock period.")
	_expect(GameData.scheduled_dock_event(1, 0, 1).is_empty(), "Dock scheduling should not fire at tick zero.")
	_expect(not GameData.scheduled_dock_event(1, 50, 1).is_empty(), "Stage 1's Wave 1 dock should fire at its 50-tick phase.")
	_expect(GameData.scheduled_dock_event(1, 1200, 1).is_empty(), "Stage 1's Wave 1 dock should not fire at the unshifted base tick.")
	_expect(not GameData.scheduled_dock_event(1, 250, 5).is_empty(), "Stage 5's Wave 1 dock should fire at its 250-tick phase.")
	game._start_stage(1)
	game.docks.clear()
	game.simulation_tick = 50
	game._handle_spawns()
	_expect(game.docks.size() == 1 and game.docks[0].get("id", "") == "blue", "The game loop should materialize the Stage 1 dock at tick 50.")
	game.docks.clear()
	game.simulation_tick = 1200
	game._handle_spawns()
	_expect(game.docks.is_empty(), "The game loop should respect the shifted dock phase at tick 1200.")

	# Building interaction is menu-first: select an adjacent rubble site, buy, then construct.
	game._start_stage(1)
	var first_site: Dictionary = game.buildings[0]
	game.player["pos"] = first_site.get("pos", Vector2.ZERO)
	game._build_or_repair()
	_expect(game.paused and game.building_menu_site_index == 0, "Using build beside rubble should open its site-specific menu.")
	game._select_building("small_shack")
	_expect(not game.paused, "Choosing a building should return to play.")
	_expect(game.money == 0, "Buying the $70 Small Shack should consume all Stage 1 starting money.")
	_expect(bool(game.buildings[0].get("constructing", false)), "The selected rubble site should enter construction.")
	var build_total := float(game.buildings[0].get("build_total", 0.0))
	var build_steps := int(ceil(build_total / float(GameData.PLAYER_BUILD_HEALTH_PER_TICK)))
	for build_tick in range(build_steps):
		game._build_or_repair()
	_expect(game.buildings[0].get("state") == "complete", "A selected building should complete after finished health times three.")
	var spawn_interval := int(GameData.get_building("small_shack").get("spawn_interval_ticks", 0))
	for spawn_tick in range(spawn_interval):
		game._update_buildings()
	_expect(game.friendlies.size() == 1, "A completed Small Shack should spawn its defender at 630 ticks.")

	# A hit awards +1 immediately; the later death awards worth * 4 and drops worth coins.
	game.enemies.clear()
	game.coins.clear()
	game.score = 0
	var player_position: Vector2 = game.player.get("pos", Vector2.ZERO)
	var target_position := player_position + Vector2(GameData.BULLET_SPEED, 0)
	var small_green: Dictionary = GameData.get_enemy("small_green")
	game._create_enemy("small_green", target_position)
	game._create_bullet(player_position, Vector2.RIGHT * GameData.BULLET_SPEED, 1, "player")
	game._update_bullets()
	_expect(game.score == 1, "Every enemy bullet hit should award one score immediately.")
	_expect(game.enemies.size() == 1 and float(game.enemies[0].get("health", 0.0)) == float(small_green.get("health", 0)) - 1.0, "The first hit should damage, not immediately remove, Small Green.")
	game._create_bullet(player_position, Vector2.RIGHT * GameData.BULLET_SPEED, 100, "player")
	game._update_bullets()
	game._update_enemies()
	var expected_kill_score := 2 + int(small_green.get("worth", 0)) * 4
	_expect(game.coins.size() == int(small_green.get("worth", 0)) and game.score == expected_kill_score, "Each of the two hits should award +1, and the Small Green death should add worth * 4 and drop worth coins.")

	# Flash bullets ignore ordinary islands, but collide against the full EnemyDock
	# clip.  A shot near a wide dock's edge used to miss because the recreation
	# compared it only to a 24px circle at the dock centre.
	game._start_stage(1)
	game.enemies.clear()
	game.docks.clear()
	game.bullets.clear()
	var dock_hit_position := Vector2(400.0, 350.0)
	var dock_health := float(GameData.get_dock("blue").get("health", 90))
	game.docks.append({"id": "blue", "pos": dock_hit_position, "health": dock_health})
	var dock_edge_shot_start := Vector2(dock_hit_position.x - game._dock_half_width("blue") - GameData.BULLET_SPEED + 2.0, dock_hit_position.y + 10.0)
	game._create_bullet(dock_edge_shot_start, Vector2.RIGHT * GameData.BULLET_SPEED, 1, "player")
	game._update_bullets()
	_expect(game.bullets.is_empty() and float(game.docks[0].get("health", 0.0)) == dock_health - 1.0, "A player bullet should hit the full left edge of a moving EnemyDock, not only its centre.")
	# Sweep the bullet's previous-to-current segment as well, so a shot cannot
	# tunnel through a moving dock if a future weapon/projectile uses a larger
	# per-tick speed.
	game.docks[0]["health"] = dock_health
	game._create_bullet(Vector2(dock_hit_position.x - 130.0, dock_hit_position.y + 10.0), Vector2.RIGHT * 260.0, 1, "player")
	game._update_bullets()
	_expect(game.bullets.is_empty() and float(game.docks[0].get("health", 0.0)) == dock_health - 1.0, "A swept bullet should not tunnel through an EnemyDock between ticks.")
	# Verify the normal 20px/tick diagonal case against a dock during its bobbing
	# update—the practical case that exposed the narrow centre-circle collision.
	game.docks.clear()
	game.bullets.clear()
	game.docks.append({"id": "blue", "pos": Vector2(320.0, 400.0), "health": dock_health, "counter": 0, "spawn_interval": 999999, "island_index": 0, "dock_side": "left", "is_docked": true, "float_counter": 0})
	game._update_docks()
	var moving_dock_position: Vector2 = game.docks[0].get("pos", Vector2.ZERO)
	var moving_dock_half: float = game._dock_half_width("blue")
	game._create_bullet(moving_dock_position + Vector2(-moving_dock_half - 6.0, 10.0), Vector2(1.0, -1.0).normalized() * GameData.BULLET_SPEED, 1, "player")
	game._update_bullets()
	_expect(game.bullets.is_empty() and float(game.docks[0].get("health", 0.0)) == dock_health - 1.0, "A normal-speed diagonal shot should hit a bobbing EnemyDock corner.")
	# Target evaluation precedes lifetime expiry in Flash, so frame 26 still has
	# a chance to strike the dock it reaches on that frame.
	var lifetime_dock: Dictionary = game.docks[0]
	lifetime_dock["health"] = dock_health
	game.docks[0] = lifetime_dock
	game._create_bullet(moving_dock_position + Vector2(-moving_dock_half - 18.0, 10.0), Vector2.RIGHT * GameData.BULLET_SPEED, 1, "player")
	var terminal_bullet: Dictionary = game.bullets[0]
	terminal_bullet["counter"] = GameData.BULLET_LIFETIME_TICKS
	game.bullets[0] = terminal_bullet
	game._update_bullets()
	_expect(game.bullets.is_empty() and float(game.docks[0].get("health", 0.0)) == dock_health - 1.0, "A terminal-lifetime bullet should still damage the EnemyDock it reaches.")

	# Source onCoin awards money/score and creates a rising money-style $1 text.
	game._start_stage(1)
	game.coins.clear()
	game.float_texts.clear()
	game.score = 0
	var money_before_coin: int = game.money
	var coin_player_position: Vector2 = game.player.get("pos", Vector2.ZERO)
	game._create_coin(coin_player_position)
	var guaranteed_coin: Dictionary = game.coins[0]
	guaranteed_coin["vel"] = Vector2.ZERO
	game.coins[0] = guaranteed_coin
	game._update_pickups()
	_expect(game.coins.is_empty() and game.money == money_before_coin + 1 and game.score == 2, "Collecting a coin should grant the source-compatible $1 and +2 score.")
	_expect(game.float_texts.size() == 1 and game.float_texts[0].get("text", "") == "$1" and bool(game.float_texts[0].get("money_text", false)), "Collecting a coin should create the original rising $1 money feedback.")
	if game.float_texts.size() == 1:
		var float_y := float(game.float_texts[0].get("pos", Vector2.ZERO).y)
		var float_alpha := float(game.float_texts[0].get("alpha", 1.0))
		game._update_float_texts()
		_expect(float(game.float_texts[0].get("pos", Vector2.ZERO).y) < float_y and float(game.float_texts[0].get("alpha", 1.0)) < float_alpha, "Coin $1 feedback should rise and fade each source-compatible tick.")

	# Enemy visuals use the original parent wrapper frames at their native scale,
	# not the old hand-authored 24/42/48px substitute rectangles.
	_expect_vector_close(game._enemy_render_size("green_centipede"), Vector2(69.0, 161.0), "Green Centipede should retain its original native body dimensions.")
	_expect(absf(game._enemy_foot_offset("green_centipede") - 83.0) < 0.01, "Green Centipede should use its recovered wrapper foot offset when grounded.")
	var wrapper_texture: Texture2D = game._load_texture("res://assets/original/enemies/enemy_07.png")
	_expect(wrapper_texture != null and wrapper_texture.get_size() == Vector2(124.0, 170.0), "Original Enemy wrapper frame 7 should be available as an unscaled 124x170 canvas.")

	# Exercise the timer and terminal win branch without a long, nondeterministic run.
	game._start_stage(1)
	game.player["health"] = 100000.0
	game.wave = 1
	game.simulation_tick = GameData.WAVE_INTERVAL_TICKS - 1
	game._tick()
	_expect(game.wave == 2, "Wave should increment from 1 to 2 at 900 ticks.")

	game._start_stage(1)
	game.player["health"] = 100000.0
	game.wave = GameData.LAST_COMPLETED_WAVE
	game.simulation_tick = GameData.WAVE_INTERVAL_TICKS - 1
	game._tick()
	_expect(game.mode == game.MODE_WON, "Timer should win when the wave exceeds 65.")

	game._start_stage(1)
	for count in range(62):
		game._create_enemy("small_green", Vector2(100 + count, 300))
	_expect(game.enemies.size() == GameData.MAX_ENEMIES_SOURCE_COMPATIBLE, "Source-compatible cap should retain 61 enemies.")

	game.free()
	game = null
	await process_frame
	if failures.is_empty():
		print("SMOKE TEST PASS")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _expect_vector_close(actual: Vector2, expected: Vector2, message: String, tolerance: float = 0.01) -> void:
	_expect(actual.distance_to(expected) <= tolerance, "%s (expected %s, got %s)" % [message, expected, actual])
