extends Node3D

const MAP_HALF := 200.0
const TRADE_RADIUS := 16.0

var gray_cards := 1
var wood := 0
var stone := 0
var health := 100
var hunger := 100
var thirst := 100
var player: CharacterBody3D
var camera: Camera3D
var hud: Label
var move_touch := Vector2.ZERO
var touch_start := Vector2.ZERO
var touch_id := -1
var in_safe_zone := true

var bosses := [
	{"id": "eiffel", "name": "Eyfel Kulesi", "pos": Vector3(-130, 0, 130), "color": Color(0.45, 0.32, 0.18)},
	{"id": "colosseum", "name": "Kolezyum", "pos": Vector3(0, 0, 160), "color": Color(0.62, 0.55, 0.42)},
	{"id": "great_wall", "name": "Cin Seddi", "pos": Vector3(140, 0, 130), "color": Color(0.55, 0.48, 0.38)},
	{"id": "sydney_opera", "name": "Sydney Opera", "pos": Vector3(170, 0, 0), "color": Color(0.82, 0.80, 0.72)},
	{"id": "pisa", "name": "Pisa Kulesi", "pos": Vector3(140, 0, -130), "color": Color(0.78, 0.74, 0.66)},
	{"id": "golden_gate", "name": "Golden Gate", "pos": Vector3(0, 0, -160), "color": Color(0.72, 0.28, 0.16)},
	{"id": "hollywood", "name": "Hollywood", "pos": Vector3(-130, 0, -130), "color": Color(0.75, 0.70, 0.55)},
	{"id": "brandenburg", "name": "Brandenburg", "pos": Vector3(-170, 0, 0), "color": Color(0.58, 0.56, 0.50)},
	{"id": "rushmore", "name": "Mount Rushmore", "pos": Vector3(-160, 0, 80), "color": Color(0.50, 0.48, 0.44)},
	{"id": "space_needle", "name": "Space Needle", "pos": Vector3(160, 0, 80), "color": Color(0.70, 0.72, 0.74)}
]

func _ready():
	_build_world()
	_build_trade_zone()
	_build_bosses()
	_build_player()
	_build_hud()

func _build_world():
	var ground = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(MAP_HALF * 2.0, MAP_HALF * 2.0)
	ground.mesh = plane
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.34, 0.22)
	ground.material_override = mat
	add_child(ground)
	for i in 40:
		var rock = MeshInstance3D.new()
		var mesh = BoxMesh.new()
		mesh.size = Vector3(1.5, 1.5, 1.5)
		rock.mesh = mesh
		var p = _rand_outside_trade(70, MAP_HALF - 12)
		rock.position = Vector3(p.x, 0.75, p.z)
		add_child(rock)
	for i in 48:
		var tree = MeshInstance3D.new()
		var mesh = CylinderMesh.new()
		mesh.top_radius = 0.35
		mesh.bottom_radius = 0.55
		mesh.height = 4.0
		tree.mesh = mesh
		var p = _rand_outside_trade(70, MAP_HALF - 12)
		tree.position = Vector3(p.x, 2, p.z)
		var m = StandardMaterial3D.new()
		m.albedo_color = Color(0.28, 0.15, 0.06)
		tree.material_override = m
		add_child(tree)

func _rand_outside_trade(min_r: float, max_r: float) -> Vector3:
	var p = Vector3.ZERO
	for _i in 20:
		p = Vector3(randf_range(-max_r, max_r), 0, randf_range(-max_r, max_r))
		if p.length() > min_r:
			return p
	return Vector3(min_r + 10, 0, 0)

func _build_trade_zone():
	var zone = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = TRADE_RADIUS
	cyl.bottom_radius = TRADE_RADIUS
	cyl.height = 0.12
	zone.mesh = cyl
	zone.position = Vector3(0, 0.06, 0)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.55, 0.22)
	zone.material_override = mat
	zone.set_meta("trade", true)
	add_child(zone)
	for i in 6:
		var stall = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(1.6, 1.4, 1.2)
		stall.mesh = box
		var ang = i * TAU / 6.0
		stall.position = Vector3(cos(ang) * 7.0, 0.7, sin(ang) * 7.0)
		var sm = StandardMaterial3D.new()
		sm.albedo_color = Color(0.36, 0.24, 0.12)
		stall.material_override = sm
		add_child(stall)

func _build_bosses():
	for b in bosses:
		var marker = MeshInstance3D.new()
		var mesh = CylinderMesh.new()
		mesh.top_radius = 1.2
		mesh.bottom_radius = 2.4
		mesh.height = 10.0
		marker.mesh = mesh
		marker.position = Vector3(b.pos.x, 5.0, b.pos.z)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = b.color
		marker.material_override = mat
		marker.set_meta("boss_id", b.id)
		marker.set_meta("boss_name", b.name)
		add_child(marker)

func _build_player():
	player = CharacterBody3D.new()
	player.position = Vector3(0, 1, 0)
	add_child(player)
	var body = MeshInstance3D.new()
	var capsule = CapsuleMesh.new()
	capsule.height = 1.8
	capsule.radius = 0.45
	body.mesh = capsule
	player.add_child(body)
	camera = Camera3D.new()
	camera.position = Vector3(0, 7, 9)
	camera.rotation_degrees.x = -32
	camera.current = true
	player.add_child(camera)

func _build_hud():
	var layer = CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(24, 24)
	hud.add_theme_font_size_override("font_size", 22)
	layer.add_child(hud)
	var help = Label.new()
	help.text = "GRAY CARD WARS  |  Sol surukle: hareket\nMerkez: yesil takas (guvenli)  |  Kenar: 10 boss"
	help.position = Vector2(24, 130)
	help.add_theme_font_size_override("font_size", 18)
	layer.add_child(help)

func _nearest_boss() -> String:
	var best := ""
	var best_d := 9999.0
	for b in bosses:
		var d = player.position.distance_to(b.pos)
		if d < best_d:
			best_d = d
			best = "%s (%.0f m)" % [b.name, d]
	return best

func _physics_process(delta):
	hunger = max(0, hunger - delta * 0.12)
	thirst = max(0, thirst - delta * 0.18)
	var v = move_touch
	if Input.is_key_pressed(KEY_W): v.y = -1
	if Input.is_key_pressed(KEY_S): v.y = 1
	if Input.is_key_pressed(KEY_A): v.x = -1
	if Input.is_key_pressed(KEY_D): v.x = 1
	var dir = Vector3(v.x, 0, v.y)
	if dir.length() > 1: dir = dir.normalized()
	player.velocity = dir * 6.0
	player.move_and_slide()
	player.position.x = clamp(player.position.x, -MAP_HALF + 2.0, MAP_HALF - 2.0)
	player.position.z = clamp(player.position.z, -MAP_HALF + 2.0, MAP_HALF - 2.0)
	var flat = Vector3(player.position.x, 0, player.position.z)
	in_safe_zone = flat.length() <= TRADE_RADIUS
	var zone = "TAKAS (guvenli)" if in_safe_zone else "VAHSI"
	hud.text = "HP %d   Aclik %d   Susuzluk %d\nGray Card %d   Odun %d   Tas %d\nBolge: %s\nYakin boss: %s" % [health, hunger, thirst, gray_cards, wood, stone, zone, _nearest_boss()]

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < get_viewport().get_visible_rect().size.x * 0.65 and touch_id == -1:
			touch_id = event.index
			touch_start = event.position
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
			move_touch = Vector2.ZERO
			_gather_nearby()
	elif event is InputEventScreenDrag and event.index == touch_id:
		move_touch = (event.position - touch_start) / 90.0
		move_touch = move_touch.limit_length(1.0)

func _gather_nearby():
	if player == null: return
	for n in get_children():
		if n is MeshInstance3D and n != player and n.position.distance_to(player.position) < 3.0:
			if n.has_meta("trade") or n.has_meta("boss_id"):
				continue
			if n.mesh is CylinderMesh:
				wood += 25
				n.queue_free()
				return
			if n.mesh is BoxMesh:
				stone += 20
				n.queue_free()
				return
