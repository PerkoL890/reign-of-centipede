extends SceneTree

const StageLayout = preload("res://scripts/stage_layout_data.gd")
const OUTPUT_DIR := "res://tests/artifacts"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var scene: PackedScene = load("res://scenes/Main.tscn")
	var game: Node2D = scene.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	await _capture("01-menu")

	game._show_stage_select()
	await process_frame
	await _capture("02-stage-select")

	game._start_stage(1)
	await process_frame
	await _capture("03-tutorial")

	game._close_tutorial()
	await _settle()
	await _capture("04-stage-1")
	# Force a representative camera delta to visually regress the source parallax
	# layers. The sky stays continuous at the screen borders because the layers
	# are oversized and sit over a single gradient, rather than repeating the
	# flattened root-frame PNG.
	game.paused = true
	var opening_camera: Vector2 = game.camera_position
	game.camera_position += Vector2(360.0, 180.0)
	game.queue_redraw()
	await _capture("04-stage-1-parallax")
	game.camera_position = opening_camera
	game.paused = false

	# Pin the separately rendered Player children for visual regression checks:
	# body faces the mouse, weapon frame 1 pivots at the recovered hand point,
	# and the short source-style muzzle flash uses its own nested registration.
	game.paused = true
	game.player["aim"] = Vector2.RIGHT
	game.player["facing"] = 1.0
	game.player["muzzle_flash_ticks"] = 4
	game.queue_redraw()
	await _capture("04-player-aim-right")
	game.paused = false

	# Verify the original money feedback is visibly rendered in world space.
	game.coins.clear()
	game.float_texts.clear()
	game._create_coin(game.player.get("pos", Vector2.ZERO))
	var capture_coin: Dictionary = game.coins[0]
	capture_coin["vel"] = Vector2.ZERO
	game.coins[0] = capture_coin
	game._update_pickups()
	game.queue_redraw()
	await _capture("04-coin-pickup")

	# Large Enemy bodies use the original unscaled wrapper canvas. Place one on
	# an island by its recovered foot point to catch accidental squash/offset
	# regressions against the stage's native 1:1 geometry.
	game.paused = true
	game.enemies.clear()
	var capture_island: Dictionary = StageLayout.layout_for(1).get("islands", [])[0]
	var capture_ground := StageLayout.island_bounds_in_map(capture_island)
	var green_position := Vector2(game.player.get("pos", Vector2.ZERO).x + 100.0, capture_ground.position.y - game._enemy_foot_offset("green_centipede"))
	game._create_enemy("green_centipede", green_position)
	game.queue_redraw()
	await _capture("04-enemy-native-scale")
	game.paused = false

	for stage_number in range(2, 6):
		game._start_stage(stage_number)
		await _settle()
		await _capture("stage-%d" % stage_number)

	game._start_stage(1)
	game.player["pos"] = game.buildings[0].get("pos", Vector2.ZERO)
	game._open_build_menu_nearby()
	await process_frame
	await _capture("05-building-menu")

	game._close_building_menu()
	game._show_weapon_menu()
	await process_frame
	await _capture("06-weapon-menu")

	game._close_game_menu()
	game._show_pause_menu()
	await process_frame
	await _capture("07-pause")

	game._resume_from_pause()
	game._start_stage(1)
	await _settle()
	var balloon_anchor: Vector2 = game.player.get("pos", Vector2.ZERO) + Vector2(110.0, -100.0)
	game._create_balloon(balloon_anchor, true)
	game.queue_redraw()
	await process_frame
	await _capture("08-balloon-box")

	var balloon_position: Vector2 = game.balloons[0].get("pos", Vector2.ZERO)
	game._create_bullet(balloon_position - Vector2(20.0, 0.0), Vector2.RIGHT * 20.0, 1, "player")
	game._update_bullets()
	await _settle()
	await _capture("09-released-box")
	if not game.boxes.is_empty():
		var released_box: Dictionary = game.boxes[0]
		var released_position: Vector2 = released_box.get("pos", Vector2.ZERO)
		print("RELEASED_BOX pos=%s ground=%s player=%s camera=%s" % [
			released_position,
			game._ground_y_at(released_position.x, released_position.y),
			game.player.get("pos", Vector2.ZERO),
			game.camera_position,
		])

	game.free()
	await process_frame
	quit(0)

func _capture(name: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("CAPTURE SKIPPED %s: headless renderer has no viewport texture" % name)
		return
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null:
		push_error("CAPTURE FAILED %s: viewport image is null" % name)
		return
	var path := ProjectSettings.globalize_path(OUTPUT_DIR.path_join("%s.png" % name))
	var result := image.save_png(path)
	print("CAPTURE %s %dx%d result=%d path=%s" % [name, image.get_width(), image.get_height(), result, path])

func _settle() -> void:
	for frame in range(20):
		await physics_frame
