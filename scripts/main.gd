extends Node3D

const MAP_HALF := 200.0
const TRADE_RADIUS := 16.0
const PLAYER_HEIGHT := 1.0
const BOSS_DRY := 42.0
const FORT_HALF := 20.0
const GATE_W := 5.5
const WALL_H := 5.0
const WALL_T := 1.4

var gray_cards := 1
var ammo := 40
var enemies: Array[CharacterBody3D] = []
var fort_bosses: Array[CharacterBody3D] = []
var fire_built := false
var house_parts := 0
var boat_built := false
var build_origin := Vector3.ZERO
var map_panel: Control
var map_dot: Label
var joystick_knob: ColorRect
var joystick_base: ColorRect
var asset_corrections = {
	"raider":{"scale":Vector3(1,1,1),"rot":Vector3.ZERO,"y":0.0},
	"boss":{"scale":Vector3(1.15,1.15,1.15),"rot":Vector3.ZERO,"y":0.0},
	"boat":{"scale":Vector3.ONE,"rot":Vector3.ZERO,"y":0.0}
}
var tree_assets = [
	"res://assets/environment/trees/tree_pine_01.glb",
	"res://assets/environment/trees/tree_pine_02.glb",
	"res://assets/environment/trees/tree_oak_01.glb",
	"res://assets/environment/trees/tree_broadleaf_01.glb",
	"res://assets/environment/trees/tree_old_giant_01.glb"
]
var rock_assets = [
	"res://assets/environment/rocks/rock_small_01.glb",
	"res://assets/environment/rocks/rock_medium_01.glb",
	"res://assets/environment/rocks/rock_large_01.glb",
	"res://assets/environment/rocks/rock_boulder_01.glb"
]
var plant_assets = [
	"res://assets/environment/plants/plant_grass_01.glb",
	"res://assets/environment/plants/plant_bush_01.glb",
	"res://assets/environment/plants/debris_log_01.glb"
]
var asset_paths = {
	"tree":"res://assets/environment/trees/tree_pine_01.glb",
	"rock":"res://assets/environment/rocks/rock_medium_01.glb",
	"raider":"res://assets/characters/enemies/raider.glb",
	"boss":"res://assets/characters/boss/brute_boss.glb",
	"campfire":"res://assets/props/campfire/campfire.glb",
	"boat":"res://assets/vehicles/boat/wood_skiff.glb"
}
var wood := 0
var stone := 0
var grass_n := 0
var wheat_n := 0
var mushroom_n := 0
var health := 100
var hunger := 100.0
var thirst := 100.0
var player: CharacterBody3D
var camera: Camera3D
var hud: Label
var move_touch := Vector2.ZERO
var touch_start := Vector2.ZERO
var touch_id := -1
var in_safe_zone := true
var in_pit := false
var in_dry := false
var damage_buffer := 0.0
var shoot_flash_time := 0.0
var hit_label: Label
var world_env: WorldEnvironment
var zone_label: Label
var trade_panel: Control

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

var pits := [
	Vector3(48, 0, -36),
	Vector3(-62, 0, 44),
	Vector3(88, 0, 72),
	Vector3(-90, 0, -70),
	Vector3(20, 0, 95),
	Vector3(-30, 0, -110)
]

func _ready():
	_build_world()
	_build_hills_and_pits()
	_build_trade_zone()
	_build_bosses()
	_build_gatherables()
	_build_player()
	_spawn_combatants()
	_build_hud()

func height_at(x: float, z: float) -> float:
	if Vector2(x, z).length() < TRADE_RADIUS + 5.0:
		return 0.0
	if _near_boss(x, z):
		return 0.0
	var h := 0.0
	h += sin(x * 0.032) * cos(z * 0.027) * 5.0
	h += sin(x * 0.081 + 1.3) * sin(z * 0.064) * 2.4
	h += sin((x + z) * 0.021) * 1.6
	for p in pits:
		var d = Vector2(x - p.x, z - p.z).length()
		if d < 22.0:
			var t = 1.0 - (d / 22.0)
			h -= t * t * 7.5
	return clampf(h, -8.0, 10.0)

func _near_boss(x: float, z: float) -> bool:
	for b in bosses:
		if Vector2(x - b.pos.x, z - b.pos.z).length() < BOSS_DRY:
			return true
	return false

func _add_static_box(pos: Vector3, size: Vector3, col: Color) -> void:
	var body = StaticBody3D.new()
	body.position = pos
	var mesh_i = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh_i.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = col
	mesh_i.material_override = mat
	body.add_child(mesh_i)
	var colshape = CollisionShape3D.new()
	var sh = BoxShape3D.new()
	sh.size = size
	colshape.shape = sh
	body.add_child(colshape)
	add_child(body)

func _load_asset(path:String)->Node3D:
	if not ResourceLoader.exists(path): return null
	var r=load(path)
	if not (r is PackedScene): return null
	var n=r.instantiate()
	if not (n is Node3D): return null
	return n

func _place_asset(path:String, parent:Node, pos:Vector3, scale_v:=Vector3.ONE, rot:=Vector3.ZERO)->Node3D:
	var n=_load_asset(path)
	if n==null: return null
	n.position=pos; n.scale=scale_v; n.rotation_degrees=rot; parent.add_child(n); return n

func _build_world():
	world_env=WorldEnvironment.new(); var env=Environment.new(); env.background_mode=Environment.BG_COLOR; env.background_color=Color(.48,.65,.76); env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color=Color(.62,.68,.72); env.ambient_light_energy=0.65; env.tonemap_mode=Environment.TONE_MAPPER_FILMIC; env.fog_enabled=true; env.fog_light_color=Color(.68,.73,.75); env.fog_density=.0028; world_env.environment=env; add_child(world_env)
	var sun=DirectionalLight3D.new(); sun.rotation_degrees=Vector3(-52,-28,0); sun.light_energy=1.15; sun.shadow_enabled=true; sun.directional_shadow_max_distance=95; add_child(sun)
	var ground=MeshInstance3D.new(); var plane=PlaneMesh.new(); plane.size=Vector2(MAP_HALF*2.0,MAP_HALF*2.0); ground.mesh=plane
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(0.22,0.34,0.13); mat.roughness=.96; ground.material_override=mat; add_child(ground)
	# Layered terrain patches break up the flat green prototype look at low mobile cost.
	for i in 70:
		var patch=MeshInstance3D.new(); var pm=PlaneMesh.new(); pm.size=Vector2(randf_range(10,28),randf_range(10,28)); patch.mesh=pm
		var px=randf_range(-190,190); var pz=randf_range(-190,190); patch.position=Vector3(px,.015,pz)
		var dirt=StandardMaterial3D.new(); dirt.albedo_color=Color(randf_range(.20,.30),randf_range(.16,.24),randf_range(.08,.13)); dirt.roughness=1.0; patch.material_override=dirt; add_child(patch)
	# Coastal water band for boat construction.
	var water=MeshInstance3D.new(); var wm=PlaneMesh.new(); wm.size=Vector2(400,28); water.mesh=wm; water.position=Vector3(0,.03,-190)
	var wmat=StandardMaterial3D.new(); wmat.albedo_color=Color(.035,.22,.34,.82); wmat.metallic=.05; wmat.roughness=.25; wmat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA; water.material_override=wmat; add_child(water)
	for i in 24:
		var p = _rand_outside_trade(28, MAP_HALF - 12)
		if _near_boss(p.x, p.z):
			continue
		var rock=_place_asset(rock_assets[randi()%rock_assets.size()],self,Vector3(p.x,height_at(p.x,p.z),p.z),Vector3.ONE,Vector3(0,randf_range(0,360),0))
		if rock==null:
			_add_static_box(Vector3(p.x,height_at(p.x,p.z)+.75,p.z),Vector3(1.5,1.5,1.5),Color(.45,.43,.40)); rock=get_child(get_child_count()-1)
		rock.set_meta("loot","stone")
	for i in 28:
		var p = _rand_outside_trade(28, MAP_HALF - 12)
		if _near_boss(p.x, p.z):
			continue
		var tree=_place_asset(tree_assets[randi()%tree_assets.size()],self,Vector3(p.x,height_at(p.x,p.z),p.z),Vector3.ONE*randf_range(.85,1.18),Vector3(0,randf_range(0,360),0))
		if tree==null:
			tree=MeshInstance3D.new(); var mesh=CylinderMesh.new(); mesh.top_radius=.35; mesh.bottom_radius=.55; mesh.height=4.0; tree.mesh=mesh; tree.position=Vector3(p.x,height_at(p.x,p.z)+2.0,p.z); tree.material_override=_simple_mat(Color(.28,.15,.06)); add_child(tree)
		tree.set_meta("loot","wood")
	for i in 45:
		var p=_rand_outside_trade(22,MAP_HALF-14)
		if _near_boss(p.x,p.z): continue
		_place_asset(plant_assets[randi()%plant_assets.size()],self,Vector3(p.x,height_at(p.x,p.z)+.02,p.z),Vector3.ONE*randf_range(.8,1.25),Vector3(0,randf_range(0,360),0))

func _build_hills_and_pits():
	for i in 16:
		var p = _rand_outside_trade(32, MAP_HALF - 22)
		if _near_boss(p.x, p.z):
			continue
		var h = maxf(height_at(p.x, p.z), 1.6)
		if h < 1.6:
			continue
		var hill = MeshInstance3D.new()
		var mesh = CylinderMesh.new()
		mesh.top_radius = 2.0
		mesh.bottom_radius = 7.0
		mesh.height = h
		hill.mesh = mesh
		hill.position = Vector3(p.x, h * 0.5, p.z)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.32, 0.38, 0.16)
		hill.material_override = mat
		add_child(hill)
	for p in pits:
		if _near_boss(p.x, p.z):
			continue
		var hole = MeshInstance3D.new()
		var mesh = CylinderMesh.new()
		mesh.top_radius = 16.0
		mesh.bottom_radius = 10.0
		mesh.height = 0.25
		hole.mesh = mesh
		hole.position = Vector3(p.x, -0.05, p.z)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.16, 0.12, 0.08)
		hole.material_override = mat
		add_child(hole)

func _build_fort(center: Vector3, accent: Color) -> void:
	var y0 := 0.0
	# kurak zemin + metal/tas taban (hasar yok)
	var floor = MeshInstance3D.new()
	var fmesh = BoxMesh.new()
	fmesh.size = Vector3(FORT_HALF * 2.0 + 2.0, 0.25, FORT_HALF * 2.0 + 2.0)
	floor.mesh = fmesh
	floor.position = Vector3(center.x, y0 + 0.12, center.z)
	var fm = StandardMaterial3D.new()
	fm.albedo_color = Color(0.50, 0.38, 0.22)
	floor.material_override = fm
	add_child(floor)

	var wood_c = Color(0.36, 0.22, 0.10)
	var stone_c = Color(0.48, 0.46, 0.42)
	var metal_c = Color(0.55, 0.56, 0.58)
	var seg = FORT_HALF - GATE_W * 0.5
	# Kuzey / guney duvar: iki parca + kapı boslugu
	_add_static_box(Vector3(center.x - (seg + GATE_W) * 0.5, y0 + WALL_H * 0.5, center.z - FORT_HALF), Vector3(seg, WALL_H, WALL_T), stone_c)
	_add_static_box(Vector3(center.x + (seg + GATE_W) * 0.5, y0 + WALL_H * 0.5, center.z - FORT_HALF), Vector3(seg, WALL_H, WALL_T), wood_c)
	_add_static_box(Vector3(center.x - (seg + GATE_W) * 0.5, y0 + WALL_H * 0.5, center.z + FORT_HALF), Vector3(seg, WALL_H, WALL_T), wood_c)
	_add_static_box(Vector3(center.x + (seg + GATE_W) * 0.5, y0 + WALL_H * 0.5, center.z + FORT_HALF), Vector3(seg, WALL_H, WALL_T), stone_c)
	# Dogu / bati
	_add_static_box(Vector3(center.x - FORT_HALF, y0 + WALL_H * 0.5, center.z - (seg + GATE_W) * 0.5), Vector3(WALL_T, WALL_H, seg), metal_c)
	_add_static_box(Vector3(center.x - FORT_HALF, y0 + WALL_H * 0.5, center.z + (seg + GATE_W) * 0.5), Vector3(WALL_T, WALL_H, seg), stone_c)
	_add_static_box(Vector3(center.x + FORT_HALF, y0 + WALL_H * 0.5, center.z - (seg + GATE_W) * 0.5), Vector3(WALL_T, WALL_H, seg), stone_c)
	_add_static_box(Vector3(center.x + FORT_HALF, y0 + WALL_H * 0.5, center.z + (seg + GATE_W) * 0.5), Vector3(WALL_T, WALL_H, seg), metal_c)

	# 4 kapi cercevesi (giris acik, cerceve hasarsiz)
	var frames = [
		Vector3(center.x, y0 + 3.2, center.z - FORT_HALF),
		Vector3(center.x, y0 + 3.2, center.z + FORT_HALF),
		Vector3(center.x - FORT_HALF, y0 + 3.2, center.z),
		Vector3(center.x + FORT_HALF, y0 + 3.2, center.z)
	]
	for i in frames.size():
		var fr = frames[i]
		var along_z = (i < 2)
		if along_z:
			_add_static_box(fr + Vector3(-GATE_W * 0.5, 0, 0), Vector3(0.45, 3.6, 0.55), metal_c)
			_add_static_box(fr + Vector3(GATE_W * 0.5, 0, 0), Vector3(0.45, 3.6, 0.55), metal_c)
			_add_static_box(fr + Vector3(0, 1.7, 0), Vector3(GATE_W + 0.4, 0.4, 0.55), wood_c)
		else:
			_add_static_box(fr + Vector3(0, 0, -GATE_W * 0.5), Vector3(0.55, 3.6, 0.45), metal_c)
			_add_static_box(fr + Vector3(0, 0, GATE_W * 0.5), Vector3(0.55, 3.6, 0.45), metal_c)
			_add_static_box(fr + Vector3(0, 1.7, 0), Vector3(0.55, 0.4, GATE_W + 0.4), wood_c)

	# pencereler: duvar ustunde gorsel (carpisma yok, sadece delik gorunumu)
	_add_window(Vector3(center.x - FORT_HALF * 0.55, y0 + 3.2, center.z - FORT_HALF), true)
	_add_window(Vector3(center.x + FORT_HALF * 0.55, y0 + 3.2, center.z + FORT_HALF), true)
	_add_window(Vector3(center.x - FORT_HALF, y0 + 3.2, center.z - FORT_HALF * 0.55), false)
	_add_window(Vector3(center.x + FORT_HALF, y0 + 3.2, center.z + FORT_HALF * 0.55), false)

	# Kale disi kayalik: 4 koridor haric girilmez
	_build_rock_ring(center, accent)

func _add_window(pos: Vector3, along_z: bool) -> void:
	var w = MeshInstance3D.new()
	var box = BoxMesh.new()
	if along_z:
		box.size = Vector3(1.6, 1.2, 0.2)
	else:
		box.size = Vector3(0.2, 1.2, 1.6)
	w.mesh = box
	w.position = pos
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.18, 0.22)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.55
	w.material_override = mat
	add_child(w)

func _build_rock_ring(center: Vector3, _accent: Color) -> void:
	var inner = FORT_HALF + 1.2
	var outer = BOSS_DRY - 1.0
	# her 8 derecede kaya, 4 kapı koridorunu atla
	var a := 0.0
	while a < TAU:
		var deg_ok = true
		# koridorlar: 0, 90, 180, 270 derece ±12
		for k in 4:
			var gate_a = k * PI * 0.5
			var diff = abs(atan2(sin(a - gate_a), cos(a - gate_a)))
			if diff < 0.22:
				deg_ok = false
		if deg_ok:
			var r = inner + 2.0
			while r < outer:
				var x = center.x + cos(a) * r
				var z = center.z + sin(a) * r
				var s = 2.4 + fmod(r + a, 1.7)
				_add_static_box(Vector3(x, s * 0.5, z), Vector3(s, s, s), Color(0.38, 0.34, 0.30))
				r += 3.2
		a += 0.18

func _build_gatherables():
	for i in 55:
		var p = _rand_outside_trade(20, MAP_HALF - 14)
		if _near_boss(p.x, p.z):
			continue
		var g = MeshInstance3D.new()
		var mesh = CylinderMesh.new()
		mesh.top_radius = 0.15
		mesh.bottom_radius = 0.35
		mesh.height = 0.55
		g.mesh = mesh
		g.position = Vector3(p.x, height_at(p.x, p.z) + 0.28, p.z)
		var m = StandardMaterial3D.new()
		m.albedo_color = Color(0.22, 0.55, 0.16)
		g.material_override = m
		g.set_meta("loot", "grass")
		add_child(g)
	for i in 32:
		var p = _rand_outside_trade(22, MAP_HALF - 14)
		if _near_boss(p.x, p.z):
			continue
		var w = MeshInstance3D.new()
		var mesh = CylinderMesh.new()
		mesh.top_radius = 0.08
		mesh.bottom_radius = 0.12
		mesh.height = 1.1
		w.mesh = mesh
		w.position = Vector3(p.x, height_at(p.x, p.z) + 0.55, p.z)
		var m = StandardMaterial3D.new()
		m.albedo_color = Color(0.78, 0.68, 0.22)
		w.material_override = m
		w.set_meta("loot", "wheat")
		add_child(w)
	for i in 22:
		var p = _rand_outside_trade(24, MAP_HALF - 16)
		if _near_boss(p.x, p.z):
			continue
		var mu = MeshInstance3D.new()
		var mesh = SphereMesh.new()
		mesh.radius = 0.28
		mesh.height = 0.36
		mu.mesh = mesh
		mu.position = Vector3(p.x, height_at(p.x, p.z) + 0.22, p.z)
		var m = StandardMaterial3D.new()
		m.albedo_color = Color(0.62, 0.22, 0.18)
		mu.material_override = m
		mu.set_meta("loot", "mushroom")
		add_child(mu)

func _rand_outside_trade(min_r: float, max_r: float) -> Vector3:
	var p = Vector3.ZERO
	for _i in 24:
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
		_build_fort(b.pos, b.color)
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
		marker.visible = false
		_build_landmark(b)
		marker.set_meta("boss_id", b.id)
		marker.set_meta("boss_name", b.name)
		add_child(marker)

func _build_player():
	player = CharacterBody3D.new()
	player.position = Vector3(0, PLAYER_HEIGHT, 0)
	var col = CollisionShape3D.new()
	var capshape = CapsuleShape3D.new()
	capshape.radius = 0.42
	capshape.height = 1.7
	col.shape = capshape
	player.add_child(col)
	add_child(player)
	var body = MeshInstance3D.new()
	var cap = CapsuleMesh.new()
	cap.height = 1.35
	cap.radius = 0.38
	body.mesh = cap
	body.position = Vector3(0, 0.15, 0)
	var bm = StandardMaterial3D.new()
	bm.albedo_color = Color(0.18, 0.22, 0.28)
	body.material_override = bm
	player.add_child(body)
	var head = MeshInstance3D.new()
	var sph = SphereMesh.new()
	sph.radius = 0.28
	head.mesh = sph
	head.position = Vector3(0, 0.95, 0)
	var hm = StandardMaterial3D.new()
	hm.albedo_color = Color(0.72, 0.58, 0.46)
	head.material_override = hm
	player.add_child(head)
	camera = Camera3D.new()
	camera.position = Vector3(0, 5.4, 7.2)
	camera.rotation_degrees.x = -25
	camera.fov = 68
	camera.current = true
	player.add_child(camera)

func _build_hud():
	var layer = CanvasLayer.new()
	add_child(layer)
	hit_label=Label.new(); hit_label.set_anchors_preset(Control.PRESET_CENTER); hit_label.position=Vector2(-20,-35); hit_label.text="+"; hit_label.visible=false; hit_label.add_theme_font_size_override("font_size",32); layer.add_child(hit_label)
	zone_label=Label.new(); zone_label.set_anchors_preset(Control.PRESET_TOP_WIDE); zone_label.position=Vector2(0,18); zone_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; zone_label.add_theme_font_size_override("font_size",24); zone_label.add_theme_color_override("font_shadow_color",Color(0,0,0,.9)); zone_label.add_theme_constant_override("shadow_offset_x",2); zone_label.add_theme_constant_override("shadow_offset_y",2); layer.add_child(zone_label)
	hud = Label.new()
	hud.position = Vector2(24, 22)
	hud.add_theme_font_size_override("font_size", 18)
	hud.add_theme_color_override("font_shadow_color",Color(0,0,0,.85)); hud.add_theme_constant_override("shadow_offset_x",2); hud.add_theme_constant_override("shadow_offset_y",2)
	layer.add_child(hud)
	joystick_base=ColorRect.new(); joystick_base.position=Vector2(42,500); joystick_base.size=Vector2(150,150); joystick_base.color=Color(.08,.08,.08,.32); layer.add_child(joystick_base)
	joystick_knob=ColorRect.new(); joystick_knob.position=Vector2(48,48); joystick_knob.size=Vector2(54,54); joystick_knob.color=Color(.92,.92,.92,.55); joystick_base.add_child(joystick_knob)
	var actions = [["TOPLA", _gather_nearby], ["ATES", _shoot], ["KAMP", _build_fire], ["EV", _build_house], ["BOT", _build_boat], ["HARITA", _toggle_map]]
	for i in actions.size():
		var b = Button.new()
		b.text = actions[i][0]
		b.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		b.position = Vector2(-158, 30 + i * 62)
		b.size = Vector2(142, 54)
		b.add_theme_font_size_override("font_size",18)
		b.pressed.connect(actions[i][1])
		layer.add_child(b)
	var trade=Button.new(); trade.text="TAKAS"; trade.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); trade.position=Vector2(-158,-70); trade.size=Vector2(142,54); trade.pressed.connect(_toggle_trade); layer.add_child(trade)
	_create_trade_panel(layer)

func _nearest_boss() -> String:
	var best := ""
	var best_d := 9999.0
	for b in bosses:
		var d = Vector2(player.position.x - b.pos.x, player.position.z - b.pos.z).length()
		if d < best_d:
			best_d = d
			best = "%s (%.0f m)" % [b.name, d]
	return best

func _physics_process(delta):
	if message_time>0.0:
		message_time-=delta
		if message_time<=0.0 and respawn_label: respawn_label.visible=false
	if shoot_flash_time>0.0:
		shoot_flash_time-=delta
		if shoot_flash_time<=0.0 and hit_label: hit_label.visible=false
	hunger = maxf(0.0, hunger - delta * 0.04)
	thirst = maxf(0.0, thirst - delta * 0.06)
	if hunger <= 0.0 or thirst <= 0.0:
		_apply_damage(8.0 * delta)
	if in_safe_zone:
		hunger = minf(100.0, hunger + delta * 0.8)
		thirst = minf(100.0, thirst + delta * 1.4)
	if fire_built and player.global_position.distance_to(campfire_pos)<5.0:
		hunger=minf(100.0,hunger+delta*.35)
		health=min(100,health+int(delta*1.2))
	var v = move_touch
	if Input.is_key_pressed(KEY_W): v.y = -1
	if Input.is_key_pressed(KEY_S): v.y = 1
	if Input.is_key_pressed(KEY_A): v.x = -1
	if Input.is_key_pressed(KEY_D): v.x = 1
	var dir = Vector3(v.x, 0, v.y)
	if dir.length() > 1.0:
		dir = dir.normalized()
	var speed = 4.2 if in_pit else 6.0
	if hunger<20.0 or thirst<20.0: speed*=.78
	player.velocity = dir * speed
	player.move_and_slide()
	player.position.x = clampf(player.position.x, -MAP_HALF + 2.0, MAP_HALF - 2.0)
	player.position.z = clampf(player.position.z, -MAP_HALF + 2.0, MAP_HALF - 2.0)
	var hy = height_at(player.position.x, player.position.z)
	player.position.y = hy + PLAYER_HEIGHT
	in_pit = hy < -2.0
	in_dry = _near_boss(player.position.x, player.position.z)
	var flat = Vector2(player.position.x, player.position.z)
	in_safe_zone = flat.length() <= TRADE_RADIUS
	if trade_panel and trade_panel.visible and not in_safe_zone: trade_panel.visible=false
	_update_combat(delta)
	_update_map_dot()
	if health <= 0:
		_respawn()
	var zone = "VAHSI"
	if in_safe_zone:
		zone = "TAKAS"
	elif in_pit:
		zone = "CUKUR"
	elif in_dry:
		zone = "KURAK / KALE"
	zone_label.text="%s  •  %s" % [zone,_nearest_boss()]
	hud.text = "HP %d  Ac %d  Su %d  Kart %d  Mermi %d\nOdun %d  Tas %d  Cim %d  Bugday %d  Mantar %d" % [
		health, int(hunger), int(thirst), gray_cards, ammo,
		wood, stone, grass_n, wheat_n, mushroom_n
	]

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < get_viewport().get_visible_rect().size.x * 0.65 and touch_id == -1:
			touch_id = event.index
			touch_start = event.position
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
			move_touch = Vector2.ZERO
			if joystick_knob: joystick_knob.position=Vector2(48,48)
			_gather_nearby()
	elif event.is_action_pressed("interact"):
		_gather_nearby()
	elif event.is_action_pressed("build_fire"):
		_build_fire()
	elif event.is_action_pressed("build_house"):
		_build_house()
	elif event.is_action_pressed("build_boat"):
		_build_boat()
	elif event is InputEventScreenDrag and event.index == touch_id:
		move_touch = (event.position - touch_start) / 90.0
		move_touch = move_touch.limit_length(1.0)
		if joystick_knob: joystick_knob.position=Vector2(48,48)+move_touch*38.0

func _gather_nearby():
	if player == null:
		return
	for n in get_children():
		var pos = n.position
		if n.get_child_count() > 0 and n is StaticBody3D:
			pos = n.position
		if pos.distance_to(player.position) > 3.2:
			continue
		if n.has_meta("trade") or n.has_meta("boss_id"):
			continue
		if not n.has_meta("loot"):
			continue
		var kind = str(n.get_meta("loot"))
		if kind == "wood":
			wood += 25
		elif kind == "stone":
			stone += 20
		elif kind == "grass":
			grass_n += 8
		elif kind == "wheat":
			wheat_n += 5
		elif kind == "mushroom":
			mushroom_n += 2
			hunger = minf(100.0, hunger + 8.0)
		n.queue_free()
		return


func _enemy_visual(color: Color, scale_v := Vector3.ONE) -> MeshInstance3D:
	var m = MeshInstance3D.new()
	var cap = CapsuleMesh.new(); cap.radius = 0.48; cap.height = 1.8
	m.mesh = cap; m.scale = scale_v
	var mat = StandardMaterial3D.new(); mat.albedo_color = color; m.material_override = mat
	return m

func _spawn_combatants():
	for b in bosses:
		for j in 3:
			var e = CharacterBody3D.new()
			e.position = b.pos + Vector3(cos(j * TAU / 3.0) * 12.0, 1.0, sin(j * TAU / 3.0) * 12.0)
			var rc=asset_corrections["raider"]; var rv=_place_asset(asset_paths["raider"],e,Vector3(0,rc["y"],0),rc["scale"],rc["rot"])
			if rv==null: e.add_child(_enemy_visual(Color(0.42,0.08,0.08)))
			e.set_meta("hp", 60); e.set_meta("raider", true)
			add_child(e); enemies.append(e)
		var boss = CharacterBody3D.new(); boss.position = b.pos + Vector3(0,1,0)
		var bc=asset_corrections["boss"]; var bv=_place_asset(asset_paths["boss"],boss,Vector3(0,bc["y"],0),bc["scale"],bc["rot"])
		if bv==null: boss.add_child(_enemy_visual(Color(0.12,0.04,0.04), Vector3(1.8,1.8,1.8)))
		boss.set_meta("hp",300); boss.set_meta("fort_boss",true)
		add_child(boss); fort_bosses.append(boss)

func _update_combat(delta):
	for e in enemies:
		if not is_instance_valid(e): continue
		var d = player.global_position - e.global_position
		if d.length() < 18.0 and not in_safe_zone:
			e.velocity = d.normalized() * 2.2; e.move_and_slide()
			if d.length() < 1.5: _apply_damage(12.0 * delta)
	for b in fort_bosses:
		if not is_instance_valid(b): continue
		var d = player.global_position - b.global_position
		if d.length() < 26.0 and not in_safe_zone:
			b.velocity = d.normalized() * 1.6; b.move_and_slide()
			if d.length() < 2.0: _apply_damage(18.0 * delta)

func _apply_damage(amount:float):
	damage_buffer += amount
	var whole=int(floor(damage_buffer))
	if whole>0:
		health=max(0,health-whole)
		damage_buffer-=whole

func _shoot():
	if ammo <= 0 or in_safe_zone: return
	ammo -= 1
	var target: CharacterBody3D = null; var best := 18.0
	for e in enemies:
		if is_instance_valid(e):
			var d = e.global_position.distance_to(player.global_position)
			if d < best: best = d; target = e
	for b in fort_bosses:
		if is_instance_valid(b):
			var d = b.global_position.distance_to(player.global_position)
			if d < best: best = d; target = b
	if target == null: return
	shoot_flash_time=.12; if hit_label: hit_label.text="✦"; hit_label.visible=true
	var hp_now = int(target.get_meta("hp")) - 30; target.set_meta("hp", hp_now)
	if hp_now <= 0:
		var reward=5 if target.has_meta("fort_boss") else 1; gray_cards+=reward
		if hit_label: hit_label.text="+%d KART" % reward; hit_label.visible=true; shoot_flash_time=.8
		target.queue_free()

func _build_fire():
	if fire_built or wood < 15 or stone < 5: return
	wood -= 15; stone -= 5; fire_built = true
	var cp=player.global_position+Vector3(2,0,0); campfire_pos=cp
	if _place_asset(asset_paths["campfire"],self,cp)==null: _add_static_box(cp+Vector3(0,.3,0),Vector3(1.4,.5,1.4),Color(.35,.14,.04))

func _build_house():
	if house_parts >= 6 or wood < 20: return
	wood -= 20
	if house_parts == 0: build_origin = player.global_position + Vector3(5,0,0)
	var parts=[Vector3(0,.2,0),Vector3(0,1.7,-2.5),Vector3(0,1.7,2.5),Vector3(-2.5,1.7,0),Vector3(2.5,1.7,0),Vector3(0,3.5,0)]
	var sizes=[Vector3(5,.4,5),Vector3(5,3,.3),Vector3(5,3,.3),Vector3(.3,3,5),Vector3(.3,3,5),Vector3(5,.3,5)]
	_add_static_box(build_origin + parts[house_parts], sizes[house_parts], Color(0.42,0.23,0.08)); house_parts += 1

func _build_boat():
	if boat_built or wood < 40: return
	wood -= 40; boat_built = true
	var bp=Vector3(player.position.x,0.35,-192)
	var bc=asset_corrections["boat"]; bp.y+=bc["y"]
	var boat=_place_asset(asset_paths["boat"],self,bp,bc["scale"],bc["rot"])
	if boat==null: _add_static_box(bp,Vector3(3,.6,6),Color(.35,.16,.05))

func _toggle_map():
	if map_panel == null: _create_map()
	map_panel.visible = not map_panel.visible

func _create_map():
	map_panel = Control.new(); map_panel.position = Vector2(110,70); map_panel.size = Vector2(620,520)
	var bg=ColorRect.new(); bg.size=map_panel.size; bg.color=Color(0.08,0.13,0.09,0.95); map_panel.add_child(bg)
	for b in bosses:
		var l=Label.new(); l.text=b.name
		l.position=Vector2(25+(b.pos.x+MAP_HALF)/(MAP_HALF*2.0)*570.0,35+(b.pos.z+MAP_HALF)/(MAP_HALF*2.0)*440.0); map_panel.add_child(l)
	map_dot=Label.new(); map_dot.text="● SEN"; map_panel.add_child(map_dot)
	var layers=get_children().filter(func(n): return n is CanvasLayer)
	if layers.size()>0: layers[-1].add_child(map_panel)
	map_panel.visible=false
	_update_map_dot()

func _update_map_dot():
	if map_dot == null or player == null: return
	var nx=clampf((player.position.x+MAP_HALF)/(MAP_HALF*2.0),0.0,1.0)
	var nz=clampf((player.position.z+MAP_HALF)/(MAP_HALF*2.0),0.0,1.0)
	map_dot.position=Vector2(25+nx*570.0,35+nz*440.0)

func _respawn():
	wood /= 2; stone /= 2; grass_n /= 2; wheat_n /= 2; mushroom_n /= 2
	health=100; hunger=70.0; thirst=80.0; damage_buffer=0.0; player.velocity=Vector3.ZERO; player.position=Vector3(0,PLAYER_HEIGHT,0)
	if trade_panel: trade_panel.visible=false
	if map_panel: map_panel.visible=false
	if respawn_label:
		respawn_label.text="YENIDEN DOGDUN  •  Kaynaklarin yarisi kaybedildi  •  Kartlar korundu"; respawn_label.visible=true; message_time=3.5


func _landmark_box(p: Vector3, size: Vector3, c: Color, rot := Vector3.ZERO):
	var body = _add_static_box_return(p, size, c)
	body.rotation_degrees = rot
	return body

func _add_static_box_return(pos: Vector3, size: Vector3, col: Color) -> StaticBody3D:
	var body=StaticBody3D.new(); body.position=pos
	var mi=MeshInstance3D.new(); var box=BoxMesh.new(); box.size=size; mi.mesh=box
	var mat=StandardMaterial3D.new(); mat.albedo_color=col; mi.material_override=mat; body.add_child(mi)
	var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=size; cs.shape=sh; body.add_child(cs); add_child(body)
	return body

func _build_landmark(b):
	var c:Vector3=b.pos; var col:Color=b.color; var id:String=b.id
	if id=="eiffel":
		for sx in [-1,1]:
			for sz in [-1,1]: _landmark_box(c+Vector3(sx*3,6,sz*3),Vector3(1,12,1),col,Vector3(sz*10,0,-sx*10))
		_landmark_box(c+Vector3(0,11,0),Vector3(7,0.7,7),col); _landmark_box(c+Vector3(0,17,0),Vector3(1.2,12,1.2),col)
	elif id=="colosseum":
		for i in 20:
			var a=i*TAU/20.0; _landmark_box(c+Vector3(cos(a)*8,3,sin(a)*5),Vector3(1.1,6,1.1),col)
	elif id=="great_wall":
		_landmark_box(c+Vector3(0,3,0),Vector3(22,6,2.2),col)
		for x in [-10.0,10.0]: _landmark_box(c+Vector3(x,5,0),Vector3(4,10,4),col)
	elif id=="sydney_opera":
		for x in [-5.0,0.0,5.0]: _landmark_box(c+Vector3(x,4,0),Vector3(5,8,1.2),col,Vector3(0,0,25 if x<0 else -25))
	elif id=="pisa":
		var tower=_landmark_box(c+Vector3(0,7,0),Vector3(5,14,5),col); tower.rotation_degrees.z=8
	elif id=="golden_gate":
		for x in [-7.0,7.0]: _landmark_box(c+Vector3(x,7,0),Vector3(2,14,2),col)
		_landmark_box(c+Vector3(0,8,0),Vector3(18,1,2),col)
	elif id=="hollywood":
		for i in 9: _landmark_box(c+Vector3(-8+i*2,3,0),Vector3(1.3,6,0.8),Color(0.92,0.92,0.86))
	elif id=="brandenburg":
		for x in [-6.0,-3.0,0.0,3.0,6.0]: _landmark_box(c+Vector3(x,4,0),Vector3(1,8,1),col)
		_landmark_box(c+Vector3(0,8,0),Vector3(15,2,3),col)
	elif id=="rushmore":
		_landmark_box(c+Vector3(0,5,0),Vector3(18,10,5),col)
		for x in [-6.0,-2.0,2.0,6.0]: _landmark_box(c+Vector3(x,8,-3),Vector3(3,4,2),Color(0.58,0.56,0.52))
	elif id=="space_needle":
		_landmark_box(c+Vector3(0,8,0),Vector3(1.5,16,1.5),col)
		var dish=MeshInstance3D.new(); var cyl=CylinderMesh.new(); cyl.top_radius=5; cyl.bottom_radius=3.5; cyl.height=1.8; dish.mesh=cyl; dish.position=c+Vector3(0,15,0); dish.material_override=_simple_mat(col); add_child(dish)

func _simple_mat(c:Color)->StandardMaterial3D:
	var m=StandardMaterial3D.new(); m.albedo_color=c; m.roughness=.75; return m


func _create_trade_panel(layer:CanvasLayer):
	trade_panel=Control.new(); trade_panel.position=Vector2(390,185); trade_panel.size=Vector2(500,300); trade_panel.visible=false
	var bg=ColorRect.new(); bg.size=trade_panel.size; bg.color=Color(.05,.07,.06,.92); trade_panel.add_child(bg)
	var title=Label.new(); title.text="GUVENLI TAKAS MERKEZI"; title.position=Vector2(120,18); title.add_theme_font_size_override("font_size",22); trade_panel.add_child(title)
	var offers=[["1 KART  >  +15 MERMI",0],["1 KART  >  +35 YIYECEK",1],["1 KART  >  +35 SU",2],["2 KART  >  +40 HP",3]]
	for i in offers.size():
		var b=Button.new(); b.text=offers[i][0]; b.position=Vector2(75,62+i*52); b.size=Vector2(350,44); b.pressed.connect(_buy_trade.bind(offers[i][1])); trade_panel.add_child(b)
	layer.add_child(trade_panel)

func _toggle_trade():
	if not in_safe_zone: return
	trade_panel.visible=not trade_panel.visible

func _buy_trade(kind:int):
	if not in_safe_zone: trade_panel.visible=false; return
	var cost=2 if kind==3 else 1
	if gray_cards<cost: return
	gray_cards-=cost
	if kind==0: ammo+=15
	elif kind==1: hunger=minf(100.0,hunger+35.0)
	elif kind==2: thirst=minf(100.0,thirst+35.0)
	else: health=min(100,health+40)

func _trade():
	_toggle_trade()
