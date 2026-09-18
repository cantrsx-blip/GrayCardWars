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
	# Render a guaranteed first frame before expensive mobile world generation.
	_build_player()
	_build_hud()
	zone_label.text="DUNYA YUKLENIYOR..."
	_build_world_staged()

func _build_world_staged() -> void:
	await get_tree().process_frame
	_build_world()
	await get_tree().process_frame
	_build_hills_and_pits()
	_build_trade_zone()
	await get_tree().process_frame
	_build_bosses()
	await get_tree().process_frame
	_build_gatherables()
	_spawn_combatants()
	zone_label.text=""

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

func _build_terrain_mesh():
	var st=SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cells:=64; var step:=(MAP_HALF*2.0)/float(cells)
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.22,.34,.13); mat.roughness=.96
	for z in cells:
		for x in cells:
			var x0=-MAP_HALF+x*step; var x1=x0+step; var z0=-MAP_HALF+z*step; var z1=z0+step
			var a=Vector3(x0,height_at(x0,z0),z0); var b=Vector3(x1,height_at(x1,z0),z0); var c=Vector3(x1,height_at(x1,z1),z1); var d=Vector3(x0,height_at(x0,z1),z1)
			st.set_uv(Vector2(float(x)/cells,float(z)/cells)); st.add_vertex(a)
			st.set_uv(Vector2(float(x+1)/cells,float(z)/cells)); st.add_vertex(b)
			st.set_uv(Vector2(float(x+1)/cells,float(z+1)/cells)); st.add_vertex(c)
			st.set_uv(Vector2(float(x)/cells,float(z)/cells)); st.add_vertex(a)
			st.set_uv(Vector2(float(x+1)/cells,float(z+1)/cells)); st.add_vertex(c)
			st.set_uv(Vector2(float(x)/cells,float(z+1)/cells)); st.add_vertex(d)
	st.generate_normals()
	var mesh=st.commit(); var terrain=MeshInstance3D.new(); terrain.name="Terrain"; terrain.mesh=mesh; terrain.material_override=mat; add_child(terrain)
	var body=StaticBody3D.new(); body.name="TerrainCollision"; var cs=CollisionShape3D.new(); cs.shape=mesh.create_trimesh_shape(); body.add_child(cs); add_child(body)

func _build_world():
	world_env=WorldEnvironment.new(); var env=Environment.new(); env.background_mode=Environment.BG_COLOR; env.background_color=Color(.48,.65,.76); env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color=Color(.62,.68,.72); env.ambient_light_energy=0.65; env.tonemap_mode=Environment.TONE_MAPPER_FILMIC; env.fog_enabled=true; env.fog_light_color=Color(.68,.73,.75); env.fog_density=.0028; world_env.environment=env; add_child(world_env)
	var sun=DirectionalLight3D.new(); sun.rotation_degrees=Vector3(-52,-28,0); sun.light_energy=1.15; sun.shadow_enabled=true; sun.directional_shadow_max_distance=95; add_child(sun)
	_build_terrain_mesh()
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
	# Human silhouette: shoulders, arms and legs instead of a capsule-only avatar.
	var cloth=StandardMaterial3D.new(); cloth.albedo_color=Color(.16,.20,.25)
	var skin=StandardMaterial3D.new(); skin.albedo_color=Color(.72,.58,.46)
	_add_human_limb(Vector3(.22,.62,.20),Vector3(-.42,.12,0),cloth)
	_add_human_limb(Vector3(.22,.62,.20),Vector3(.42,.12,0),cloth)
	_add_human_limb(Vector3(.25,.78,.25),Vector3(-.18,-.70,0),cloth)
	_add_human_limb(Vector3(.25,.78,.25),Vector3(.18,-.70,0),cloth)
	_add_human_limb(Vector3(.72,.20,.24),Vector3(0,.48,0),cloth)
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
	var actions = [["TOPLA", _gather_nearby], ["KULLAN", _use_nearest_interior], ["ATES", _shoot], ["KAMP", _build_fire], ["EV", _build_house], ["BOT", _build_boat], ["HARITA", _toggle_map], ["ENVANTER", _toggle_inventory], ["URET", _toggle_crafting], ["PARCA", _cycle_build_piece], ["DURBUN", _toggle_scope], ["ZIPLA", _jump], ["DOLDUR", _reload_weapon], ["BOMBA", _throw_grenade], ["TNT", _place_tnt], ["HILE", _toggle_cheat_mode]]
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
	_create_hotbar(layer)
	_create_minimap(layer)
	_create_weapon_aim_ui(layer)
	_create_survival_clock(layer)
	_create_damage_effect(layer)
	_create_ammo_ui(layer)
	_create_cheat_ui(layer)
	_create_creative_menu(layer)
	_setup_sfx()
	fx_root=Node3D.new(); fx_root.name="Effects"; add_child(fx_root)

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
		if message_time<=0.0:
			if respawn_label: respawn_label.visible=false
			if gather_label: gather_label.visible=false
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
		heal_buffer+=delta*1.2
		var heal_whole=int(floor(heal_buffer))
		if heal_whole>0: health=min(100,health+heal_whole); heal_buffer-=heal_whole
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
	if dir.length()>.05:
		player_facing=dir.normalized(); player.rotation.y=atan2(-player_facing.x,-player_facing.z)
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
	_update_resource_respawns(delta)
	_update_build_preview()
	_update_map_dot()
	_update_minimap()
	_update_aim_marker()
	_update_weapon_feedback(delta)
	_update_day_cycle(delta)
	_update_footsteps(delta)
	_update_damage_effect(delta)
	_update_reload(delta)
	_update_crafting_feedback(delta)
	if health <= 0:
		_death_feedback()
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
		if event.pressed and event.position.x < get_viewport().get_visible_rect().size.x * 0.55 and touch_id == -1:
			touch_id = event.index
			touch_start = event.position; touch_moved=false
		elif not event.pressed and event.index == touch_id:
			touch_id = -1
			move_touch = Vector2.ZERO
			if joystick_knob: joystick_knob.position=Vector2(48,48)
			if not touch_moved: _gather_nearby()
	elif event.is_action_pressed("interact"):
		_gather_nearby()
	elif event.is_action_pressed("build_fire"):
		_build_fire()
	elif event.is_action_pressed("build_house"):
		_build_house()
	elif event.is_action_pressed("build_boat"):
		_build_boat()
	elif event is InputEventScreenDrag and event.index == touch_id:
		if event.position.distance_to(touch_start)>18.0: touch_moved=true
		move_touch = (event.position - touch_start) / 90.0
		move_touch = move_touch.limit_length(1.0)
		if joystick_knob: joystick_knob.position=Vector2(48,48)+move_touch*38.0

func _gather_nearby():
	_play_sfx("chop"); _gather_particles()
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
			wood += 35 if axe_count>0 else 25
		elif kind == "stone":
			stone += 30 if pickaxe_count>0 else 20
		elif kind == "grass":
			grass_n += 8
		elif kind == "wheat":
			wheat_n += 5
		elif kind == "mushroom":
			mushroom_n += 2
			hunger = minf(100.0, hunger + 8.0)
		if gather_label:
			var names={"wood":"ODUN +25","stone":"TAS +20","grass":"CIM +8","wheat":"BUGDAY +5","mushroom":"MANTAR +2"}; gather_label.text=names.get(kind,"TOPLANDI"); gather_label.visible=true; message_time=1.1
		_schedule_resource_respawn(n,kind)
		if kind=="wood": _fell_tree(n)
		elif kind=="stone": _break_rock(n)
		else: n.queue_free()
		return


func _enemy_visual(color: Color, scale_v := Vector3.ONE) -> Node3D:
	var root=Node3D.new(); root.scale=scale_v
	var cloth=StandardMaterial3D.new(); cloth.albedo_color=color
	var skin=StandardMaterial3D.new(); skin.albedo_color=Color(.64,.48,.36)
	_enemy_part(root,Vector3(.62,.78,.32),Vector3(0,1.05,0),cloth)
	_enemy_part(root,Vector3(.28,.28,.28),Vector3(0,1.62,0),skin,true)
	_enemy_part(root,Vector3(.18,.72,.18),Vector3(-.42,1.02,0),cloth)
	_enemy_part(root,Vector3(.18,.72,.18),Vector3(.42,1.02,0),cloth)
	_enemy_part(root,Vector3(.22,.82,.22),Vector3(-.18,.38,0),cloth)
	_enemy_part(root,Vector3(.22,.82,.22),Vector3(.18,.38,0),cloth)
	return root

func _enemy_part(root:Node3D,size:Vector3,pos:Vector3,mat:Material,sphere:=false):
	var m=MeshInstance3D.new()
	if sphere:
		var sh=SphereMesh.new(); sh.radius=size.x; sh.height=size.y*2.0; m.mesh=sh
	else:
		var bx=BoxMesh.new(); bx.size=size; m.mesh=bx
	m.position=pos; m.material_override=mat; root.add_child(m)

func _spawn_combatants():
	for b in bosses:
		for j in 3:
			var e = CharacterBody3D.new()
			e.position = b.pos + Vector3(cos(j * TAU / 3.0) * 12.0, 1.0, sin(j * TAU / 3.0) * 12.0)
			var rc=asset_corrections["raider"]; var rv=_place_asset(asset_paths["raider"],e,Vector3(0,rc["y"],0),rc["scale"],rc["rot"])
			if rv==null: e.add_child(_enemy_visual(Color(0.42,0.08,0.08)))
			var ecs=CollisionShape3D.new(); var esh=CapsuleShape3D.new(); esh.radius=.42; esh.height=1.75; ecs.shape=esh; ecs.position.y=.88; e.add_child(ecs)
			e.set_meta("hp", 60); e.set_meta("raider", true)
			add_child(e); enemies.append(e)
		var boss = CharacterBody3D.new(); boss.position = b.pos + Vector3(0,1,0)
		var bc=asset_corrections["boss"]; var bv=_place_asset(asset_paths["boss"],boss,Vector3(0,bc["y"],0),bc["scale"],bc["rot"])
		if bv==null: boss.add_child(_boss_visual())
		var bcs=CollisionShape3D.new(); var bsh=CapsuleShape3D.new(); bsh.radius=.7; bsh.height=2.7; bcs.shape=bsh; bcs.position.y=1.35; boss.add_child(bcs)
		boss.set_meta("hp",300); boss.set_meta("fort_boss",true)
		boss.set_meta("boss_weapon",true); boss.set_meta("boss_infinite_ammo",true); boss.set_meta("no_loot_weapon",true)
		add_child(boss); fort_bosses.append(boss)

func _update_combat(delta):
	for e in enemies:
		if not is_instance_valid(e): continue
		var d = player.global_position - e.global_position; var flat=Vector3(d.x,0,d.z)
		if flat.length() < 18.0 and not in_safe_zone:
			e.velocity = flat.normalized() * 2.2; e.move_and_slide(); e.global_position.y=height_at(e.global_position.x,e.global_position.z)+.05
			if d.length() < 1.5: _apply_damage(12.0 * delta)
	for b in fort_bosses:
		if not is_instance_valid(b): continue
		var d = player.global_position - b.global_position; var flat=Vector3(d.x,0,d.z)
		if flat.length() < 26.0 and not in_safe_zone:
			b.velocity = flat.normalized() * 1.6; b.move_and_slide(); b.global_position.y=height_at(b.global_position.x,b.global_position.z)+.05
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
	if not build_mode:
		build_mode=true; _ensure_build_preview(); return
	if wood<20: return
	var p=build_preview.global_position if build_preview else player.global_position+player_facing*5.0
	var sizes=[Vector3(5,.4,5),Vector3(5,3,.3),Vector3(5,3,.3),Vector3(5,3,.3),Vector3(5,.35,5),Vector3(2.2,.35,4.0),Vector3(1.5,1,1),Vector3(1.2,.45,2.2),Vector3(2.2,1.1,.8),Vector3(1.2,1.1,1.2),Vector3(.35,1.5,.35)]
	var offsets=[Vector3(0,.2,0),Vector3(0,1.5,0),Vector3(0,1.5,0),Vector3(0,1.5,0),Vector3(0,3.1,0),Vector3(0,.8,0),Vector3(0,.5,0),Vector3(0,.25,0),Vector3(0,.55,0),Vector3(0,.55,0),Vector3(0,.75,0)]
	wood-=20
	if build_piece==2: _build_door_frame(p)
	elif build_piece==3: _build_window_frame(p)
	elif build_piece>=6: _build_interior_prop(p,build_piece)
	else:
		var part=_add_static_box_return(p+offsets[build_piece],sizes[build_piece],Color(.42,.23,.08))
		if build_piece==5: part.rotation_degrees.x=-22
	house_parts+=1
	if gather_label: gather_label.text=build_piece_names[build_piece]+" KURULDU"; gather_label.visible=true; message_time=1.0

func _cycle_build_piece():
	build_piece=(build_piece+1)%build_piece_names.size()
	if hotbar_label: hotbar_label.text="YAPI: "+build_piece_names[build_piece]
	if build_mode: _update_preview_shape()

func _update_preview_shape():
	if build_preview==null: return
	var box=BoxMesh.new()
	var sizes=[Vector3(5,.4,5),Vector3(5,3,.3),Vector3(5,3,.3),Vector3(5,3,.3),Vector3(5,.35,5),Vector3(2.2,.35,4.0),Vector3(1.5,1,1),Vector3(1.2,.45,2.2),Vector3(2.2,1.1,.8),Vector3(1.2,1.1,1.2),Vector3(.35,1.5,.35)]
	box.size=sizes[build_piece]; build_preview.mesh=box

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


func _toggle_inventory():
	if inventory_panel==null: _create_inventory()
	inventory_panel.visible=not inventory_panel.visible
	if inventory_panel.visible: _refresh_inventory()

func _create_inventory():
	inventory_panel=Control.new(); inventory_panel.set_anchors_preset(Control.PRESET_CENTER); inventory_panel.position=Vector2(-260,-210); inventory_panel.size=Vector2(520,420)
	var bg=ColorRect.new(); bg.size=inventory_panel.size; bg.color=Color(.035,.045,.04,.96); inventory_panel.add_child(bg)
	var title=Label.new(); title.text="ENVANTER"; title.position=Vector2(24,18); title.add_theme_font_size_override("font_size",26); inventory_panel.add_child(title)
	var grid=GridContainer.new(); grid.name="Grid"; grid.columns=4; grid.position=Vector2(24,68); grid.size=Vector2(472,310); inventory_panel.add_child(grid)
	var layers=get_children().filter(func(n): return n is CanvasLayer); if layers.size()>0: layers[-1].add_child(inventory_panel)
	inventory_panel.visible=false

func _refresh_inventory():
	if inventory_panel==null: return
	var grid=inventory_panel.get_node("Grid"); for c in grid.get_children(): c.queue_free()
	var items=[["ODUN",wood],["TAS",stone],["CIM",grass_n],["BUGDAY",wheat_n],["MANTAR",mushroom_n],["GRAY KART",gray_cards],["MERMI",ammo],["BALTA",axe_count],["KAZMA",pickaxe_count],["CAN",health],["ACLIK",int(hunger)],["SU",int(thirst)]]
	for item in items:
		var cell=Label.new(); cell.text="%s\n%d" % [item[0],item[1]]; cell.custom_minimum_size=Vector2(112,72); cell.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; cell.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; cell.add_theme_font_size_override("font_size",18); grid.add_child(cell)

func _schedule_resource_respawn(n:Node3D,kind:String):
	respawn_nodes.append({"kind":kind,"pos":n.global_position,"time":RESOURCE_RESPAWN})

func _update_resource_respawns(delta:float):
	for i in range(respawn_nodes.size()-1,-1,-1):
		respawn_nodes[i]["time"]-=delta
		if respawn_nodes[i]["time"]>0.0: continue
		var p:Vector3=respawn_nodes[i]["pos"]
		if _build_blocks_respawn(p):
			respawn_nodes[i]["time"]=30.0
			continue
		_spawn_resource_at(str(respawn_nodes[i]["kind"]),p)
		respawn_nodes.remove_at(i)

func _build_blocks_respawn(p:Vector3)->bool:
	if house_parts>0 and Vector2(p.x-build_origin.x,p.z-build_origin.z).length()<7.0: return true
	if fire_built and Vector2(p.x-campfire_pos.x,p.z-campfire_pos.z).length()<3.0: return true
	return false

func _spawn_resource_at(kind:String,p:Vector3):
	p.y=height_at(p.x,p.z)
	if kind=="wood":
		var n=_place_asset(tree_assets[randi()%tree_assets.size()],self,p,Vector3.ONE*randf_range(.85,1.15),Vector3(0,randf_range(0,360),0))
		if n==null:
			n=MeshInstance3D.new(); var mesh=CylinderMesh.new(); mesh.top_radius=.35; mesh.bottom_radius=.55; mesh.height=4.0; n.mesh=mesh; n.position=p+Vector3(0,2,0); n.material_override=_simple_mat(Color(.28,.15,.06)); add_child(n)
		n.set_meta("loot","wood")
	elif kind=="stone":
		var n=_place_asset(rock_assets[randi()%rock_assets.size()],self,p,Vector3.ONE,Vector3(0,randf_range(0,360),0))
		if n==null: _add_static_box(p+Vector3(0,.75,0),Vector3(1.5,1.5,1.5),Color(.45,.43,.40)); n=get_child(get_child_count()-1)
		n.set_meta("loot","stone")
	else:
		var n=MeshInstance3D.new()
		if kind=="mushroom":
			var mesh=SphereMesh.new(); mesh.radius=.28; mesh.height=.36; n.mesh=mesh; n.position=p+Vector3(0,.22,0); n.material_override=_simple_mat(Color(.62,.22,.18))
		else:
			var mesh=CylinderMesh.new(); mesh.top_radius=.1; mesh.bottom_radius=.25; mesh.height=.7 if kind=="grass" else 1.1; n.mesh=mesh; n.position=p+Vector3(0,.35 if kind=="grass" else .55,0); n.material_override=_simple_mat(Color(.22,.55,.16) if kind=="grass" else Color(.78,.68,.22))
		n.set_meta("loot",kind); add_child(n)


func _toggle_crafting():
	if craft_panel==null: _create_crafting()
	craft_panel.visible=not craft_panel.visible
	if inventory_panel: inventory_panel.visible=false

func _create_crafting():
	craft_panel=Control.new(); craft_panel.set_anchors_preset(Control.PRESET_CENTER); craft_panel.position=Vector2(-245,-180); craft_panel.size=Vector2(490,360)
	var bg=ColorRect.new(); bg.size=craft_panel.size; bg.color=Color(.04,.05,.045,.96); craft_panel.add_child(bg)
	var title=Label.new(); title.text="URETIM"; title.position=Vector2(22,18); title.add_theme_font_size_override("font_size",26); craft_panel.add_child(title)
	var recipes=[["TAS BALTA  •  20 ODUN + 10 TAS",0],["TAS KAZMA  •  15 ODUN + 15 TAS",1],["5 MERMI  •  5 TAS",2]]
	for i in recipes.size():
		var b=Button.new(); b.text=recipes[i][0]; b.position=Vector2(45,75+i*70); b.size=Vector2(400,55); b.add_theme_font_size_override("font_size",18); crafting_flash_button=b
		b.pressed.connect(_craft.bind(recipes[i][1])); craft_panel.add_child(b)
	var layers=get_children().filter(func(n): return n is CanvasLayer); if layers.size()>0: layers[-1].add_child(craft_panel)
	craft_panel.visible=false

func _craft(kind:int):
	if cheat_mode:
		wood=max(wood,9999); stone=max(stone,9999); grass=max(grass,9999); wheat=max(wheat,9999); mushrooms=max(mushrooms,9999); reserve_ammo=max(reserve_ammo,9999)
	var crafted := false
	if kind==0 and axe_count==0 and wood>=20 and stone>=10:
		wood-=20; stone-=10; axe_count=1; selected_tool="TAS BALTA"; crafted=true
	elif kind==1 and pickaxe_count==0 and wood>=15 and stone>=15:
		wood-=15; stone-=15; pickaxe_count=1; selected_tool="TAS KAZMA"; crafted=true
	elif kind==2 and stone>=5:
		stone-=5; ammo+=5; crafted=true
	if not crafted:
		if gather_label: gather_label.text="MALZEME YETERSIZ"; gather_label.visible=true; message_time=1.2
		return
	_craft_success_feedback()
	_play_sfx("craft")
	if gather_label: gather_label.text="URETILDI"; gather_label.visible=true; message_time=1.2
	_refresh_inventory()


func _create_hotbar(layer:CanvasLayer):
	hotbar=HBoxContainer.new(); hotbar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE); hotbar.position=Vector2(360,-72); hotbar.size=Vector2(560,58); hotbar.alignment=BoxContainer.ALIGNMENT_CENTER
	var slots=[["ELLER",0],["BALTA",1],["KAZMA",2],["SILAH",3],["CEKIC",4]]
	for slot in slots:
		var b=Button.new(); b.text=slot[0]; b.custom_minimum_size=Vector2(102,52); b.pressed.connect(_select_hotbar.bind(slot[1])); hotbar.add_child(b)
	layer.add_child(hotbar)
	hotbar_label=Label.new(); hotbar_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE); hotbar_label.position=Vector2(0,-102); hotbar_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; hotbar_label.text="ELLER"; layer.add_child(hotbar_label)

func _select_hotbar(slot:int):
	if slot==1 and axe_count==0: return
	if slot==2 and pickaxe_count==0: return
	var names=["ELLER","TAS BALTA","TAS KAZMA","SILAH","YAPI CEKICI"]
	selected_tool=names[slot]; hotbar_label.text=selected_tool
	_update_held_item(slot)
	if slot==4: build_mode=true; _ensure_build_preview()
	else:
		build_mode=false
		if build_preview: build_preview.visible=false

func _ensure_build_preview():
	if build_preview==null:
		build_preview=MeshInstance3D.new(); var box=BoxMesh.new(); box.size=Vector3(5,.35,5); build_preview.mesh=box
		var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.2,.9,.35,.38); mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA; build_preview.material_override=mat; add_child(build_preview)
	build_preview.visible=true; _update_preview_shape()

func _update_build_preview():
	if not build_mode or build_preview==null or player==null: return
	var forward=player_facing; forward.y=0
	if forward.length()<.1: forward=Vector3(0,0,-1)
	var p=player.global_position+forward.normalized()*5.0; p.y=height_at(p.x,p.z)+.2
	build_preview.global_position=p


func _build_door_frame(p:Vector3):
	var c=Color(.42,.23,.08)
	_add_static_box(p+Vector3(-1.65,1.5,0),Vector3(1.7,3,.3),c)
	_add_static_box(p+Vector3(1.65,1.5,0),Vector3(1.7,3,.3),c)
	_add_static_box(p+Vector3(0,2.8,0),Vector3(1.7,.4,.3),c)

func _build_window_frame(p:Vector3):
	var c=Color(.42,.23,.08)
	_add_static_box(p+Vector3(-1.8,1.5,0),Vector3(1.4,3,.3),c)
	_add_static_box(p+Vector3(1.8,1.5,0),Vector3(1.4,3,.3),c)
	_add_static_box(p+Vector3(0,.45,0),Vector3(2.2,.9,.3),c)
	_add_static_box(p+Vector3(0,2.55,0),Vector3(2.2,.9,.3),c)
	# The center remains physically open so the player can see and aim outside.


func _build_interior_prop(p:Vector3,kind:int):
	var col=Color(.30,.19,.09)
	if kind==6:
		var obj=_add_static_box_return(p+Vector3(0,.5,0),Vector3(1.5,1,1),col); obj.add_to_group("interior_interactable"); obj.set_meta("interior","chest")
	elif kind==7:
		var obj=_add_static_box_return(p+Vector3(0,.22,0),Vector3(1.2,.44,2.2),Color(.32,.28,.20)); obj.add_to_group("interior_interactable"); obj.set_meta("interior","bed"); bed_spawn=p+Vector3(0,1,1.5); has_bed_spawn=true; _update_bed_minimap()
	elif kind==8:
		var obj=_add_static_box_return(p+Vector3(0,.55,0),Vector3(2.2,1.1,.8),col); obj.add_to_group("interior_interactable"); obj.set_meta("interior","workbench")
	elif kind==9:
		var obj=_add_static_box_return(p+Vector3(0,.5,0),Vector3(1.2,1,1.2),Color(.22,.22,.20)); obj.add_to_group("interior_interactable"); obj.set_meta("interior","stove")
		var glow=OmniLight3D.new(); glow.position=p+Vector3(0,1.3,0); glow.light_color=Color(1,.48,.16); glow.light_energy=1.4; glow.omni_range=7; add_child(glow)
	elif kind==10:
		_add_static_box(p+Vector3(0,.75,0),Vector3(.35,1.5,.35),Color(.18,.15,.10))
		var lamp=OmniLight3D.new(); lamp.position=p+Vector3(0,1.7,0); lamp.light_color=Color(1,.72,.38); lamp.light_energy=1.1; lamp.omni_range=8; add_child(lamp)


func _use_nearest_interior():
	var best:Node3D=null; var dist=3.0
	for n in get_tree().get_nodes_in_group("interior_interactable"):
		var d=player.global_position.distance_to(n.global_position)
		if d<dist: dist=d; best=n
	if best==null: return
	var kind=str(best.get_meta("interior",""))
	if kind=="chest": _toggle_chest_transfer()
	elif kind=="bed":
		bed_spawn=best.global_position+Vector3(0,1,1.5); has_bed_spawn=true; _update_bed_minimap(); _flash_message("YENIDEN DOGMA NOKTASI AYARLANDI")
	elif kind=="workbench": _toggle_crafting()
	elif kind=="stove": hunger=min(100.0,hunger+20.0); _flash_message("YEMEK PISIRILDI +20 ACLIK")

func _toggle_chest_transfer():
	if wood+stone+grass_n+wheat_n+mushroom_n>0:
		chest_storage["wood"]+=wood; chest_storage["stone"]+=stone; chest_storage["grass"]+=grass_n; chest_storage["wheat"]+=wheat_n; chest_storage["mushroom"]+=mushroom_n
		wood=0; stone=0; grass_n=0; wheat_n=0; mushroom_n=0; _flash_message("KAYNAKLAR SANDIGA KONDU")
	else:
		wood=chest_storage["wood"]; stone=chest_storage["stone"]; grass_n=chest_storage["grass"]; wheat_n=chest_storage["wheat"]; mushroom_n=chest_storage["mushroom"]
		chest_storage={"wood":0,"stone":0,"grass":0,"wheat":0,"mushroom":0}; _flash_message("SANDIK BOSALTILDI")
	_refresh_inventory()

func _flash_message(t:String):
	if gather_label: gather_label.text=t; gather_label.visible=true; message_time=1.5


func _create_minimap(layer:CanvasLayer):
	minimap_panel=Panel.new(); minimap_panel.position=Vector2(16,16); minimap_panel.size=Vector2(150,150)
	var bg=ColorRect.new(); bg.position=Vector2(5,5); bg.size=Vector2(140,140); bg.color=Color(.08,.14,.09,.82); minimap_panel.add_child(bg)
	# Safe trade zone
	var safe=ColorRect.new(); safe.position=Vector2(65,65); safe.size=Vector2(10,10); safe.color=Color(.2,.9,.35,.85); minimap_panel.add_child(safe)
	# Cardinal hints keep orientation readable on a small mobile screen.
	for item in [["K",Vector2(70,4)],["G",Vector2(70,130)],["B",Vector2(4,68)],["D",Vector2(132,68)]]:
		var l=Label.new(); l.text=item[0]; l.position=item[1]; minimap_panel.add_child(l)
	minimap_dot=ColorRect.new(); minimap_dot.size=Vector2(8,8); minimap_dot.color=Color(1,.82,.12,1); minimap_panel.add_child(minimap_dot)
	minimap_dir=Label.new(); minimap_dir.text="▲"; minimap_dir.size=Vector2(18,18); minimap_panel.add_child(minimap_dir)
	_add_minimap_landmarks()
	layer.add_child(minimap_panel)

func _update_minimap():
	if minimap_dot==null or player==null: return
	var px=clamp((player.global_position.x+MAP_HALF)/(MAP_HALF*2.0),0.0,1.0)
	var pz=clamp((player.global_position.z+MAP_HALF)/(MAP_HALF*2.0),0.0,1.0)
	var pos=Vector2(5+px*132.0,5+pz*132.0)
	minimap_dot.position=pos
	minimap_dir.position=pos+Vector2(-5,-15)
	minimap_dir.rotation=atan2(-player_facing.x,-player_facing.z)


func _create_weapon_aim_ui(layer:CanvasLayer):
	crosshair=Label.new(); crosshair.text="＋"; crosshair.add_theme_font_size_override("font_size",30)
	crosshair.set_anchors_preset(Control.PRESET_CENTER); crosshair.position=Vector2(-14,-20); crosshair.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(crosshair)
	aim_marker=Label.new(); aim_marker.text="•"; aim_marker.add_theme_font_size_override("font_size",28); aim_marker.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(aim_marker)
	scope_overlay=Control.new(); scope_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); scope_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var ring=Label.new(); ring.text="◯"; ring.add_theme_font_size_override("font_size",420); ring.set_anchors_preset(Control.PRESET_CENTER); ring.position=Vector2(-135,-270); scope_overlay.add_child(ring)
	var v=Label.new(); v.text="│\n│\n│\n│"; v.set_anchors_preset(Control.PRESET_CENTER); v.position=Vector2(-3,-72); scope_overlay.add_child(v)
	var h=Label.new(); h.text="────────────"; h.set_anchors_preset(Control.PRESET_CENTER); h.position=Vector2(-72,-12); scope_overlay.add_child(h)
	scope_overlay.visible=false; layer.add_child(scope_overlay)
	hit_marker=Label.new(); hit_marker.text="×"; hit_marker.add_theme_font_size_override("font_size",38); hit_marker.set_anchors_preset(Control.PRESET_CENTER); hit_marker.position=Vector2(-12,-24); hit_marker.visible=false; hit_marker.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(hit_marker)

func _toggle_scope():
	if not has_scope: return
	scoped=not scoped
	if camera: camera.fov=32.0 if scoped else 70.0
	if scope_overlay: scope_overlay.visible=scoped
	if crosshair: crosshair.visible=not scoped

func _update_aim_marker():
	if aim_marker==null or camera==null: return
	var center=get_viewport().get_visible_rect().size*.5
	var origin=camera.project_ray_origin(center); var dir=camera.project_ray_normal(center)
	var q=PhysicsRayQueryParameters3D.create(origin,origin+dir*120.0)
	q.exclude=[player]
	var hit=get_world_3d().direct_space_state.intersect_ray(q)
	if hit:
		var sp=camera.unproject_position(hit.position); aim_marker.position=sp-Vector2(7,15); aim_marker.visible=not scoped
	else:
		aim_marker.position=center-Vector2(7,15); aim_marker.visible=not scoped


func _update_weapon_feedback(delta:float):
	recoil=move_toward(recoil,0.0,delta*10.0)
	if camera: camera.rotation_degrees.x=-recoil
	if hit_marker_time>0.0:
		hit_marker_time-=delta
		if hit_marker_time<=0.0 and hit_marker: hit_marker.visible=false

func _show_hit_marker():
	if hit_marker: hit_marker.visible=true; hit_marker_time=.16


func _add_minimap_landmarks():
	if minimap_panel==null: return
	var points=[Vector2(-130,130),Vector2(0,160),Vector2(140,130),Vector2(170,0),Vector2(140,-130),Vector2(0,-160),Vector2(-130,-130),Vector2(-170,0),Vector2(-160,80),Vector2(160,80)]
	for wp in points:
		var m=ColorRect.new(); m.size=Vector2(5,5); m.color=Color(.9,.22,.16,.95)
		m.position=Vector2(5+(wp.x+MAP_HALF)/(MAP_HALF*2.0)*132.0,5+(wp.y+MAP_HALF)/(MAP_HALF*2.0)*132.0); minimap_panel.add_child(m); minimap_marks.append(m)
	if has_bed_spawn:
		_update_bed_minimap()

func _update_bed_minimap():
	if minimap_panel==null or not has_bed_spawn: return
	var old=minimap_panel.get_node_or_null("BedMark")
	if old: old.queue_free()
	var m=Label.new(); m.name="BedMark"; m.text="⌂"; m.add_theme_font_size_override("font_size",16)
	m.position=Vector2(5+(bed_spawn.x+MAP_HALF)/(MAP_HALF*2.0)*132.0,5+(bed_spawn.z+MAP_HALF)/(MAP_HALF*2.0)*132.0)-Vector2(5,9); minimap_panel.add_child(m)


func _update_held_item(slot:int):
	if held_item: held_item.queue_free()
	held_item=Node3D.new(); held_item.name="HeldItem"; player.add_child(held_item)
	held_item.position=Vector3(.48,1.05,-.48)
	var wood_mat=StandardMaterial3D.new(); wood_mat.albedo_color=Color(.30,.16,.06)
	var metal_mat=StandardMaterial3D.new(); metal_mat.albedo_color=Color(.30,.33,.36)
	if slot==0: held_item.visible=false; return
	if slot==1:
		_add_held_box(Vector3(.12,.8,.12),Vector3(0,-.05,0),wood_mat)
		_add_held_box(Vector3(.75,.18,.18),Vector3(0,.34,0),metal_mat)
	elif slot==2:
		_add_held_box(Vector3(.12,.9,.12),Vector3(0,-.05,0),wood_mat)
		_add_held_box(Vector3(.95,.14,.16),Vector3(0,.4,0),metal_mat)
	elif slot==3:
		_add_held_box(Vector3(.18,.18,.85),Vector3(0,0,-.18),metal_mat)
		_add_held_box(Vector3(.12,.35,.16),Vector3(0,-.22,.05),wood_mat)
	elif slot==4:
		_add_held_box(Vector3(.12,.82,.12),Vector3(0,-.05,0),wood_mat)
		_add_held_box(Vector3(.65,.28,.24),Vector3(0,.35,0),metal_mat)

func _add_held_box(sz:Vector3,pos:Vector3,mat:Material):
	var m=MeshInstance3D.new(); var b=BoxMesh.new(); b.size=sz; m.mesh=b; m.position=pos; m.material_override=mat; held_item.add_child(m)


func _create_survival_clock(layer:CanvasLayer):
	day_label=Label.new(); day_label.set_anchors_preset(Control.PRESET_TOP_RIGHT); day_label.position=Vector2(-245,12); day_label.size=Vector2(210,32); day_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT; day_label.text="09:00  ☀"; layer.add_child(day_label)

func _update_day_cycle(delta:float):
	day_clock=fmod(day_clock+delta*.035,24.0)
	var hour=int(floor(day_clock)); var minute=int(floor((day_clock-hour)*60.0))
	if day_label: day_label.text="%02d:%02d  %s" % [hour,minute,("☀" if hour>=6 and hour<19 else "☾")]
	var night=hour<6 or hour>=19
	var env=get_viewport().world_3d.environment
	if env:
		env.ambient_light_energy=move_toward(env.ambient_light_energy,.28 if night else .72,delta*.08)


func _craft_success_feedback():
	crafting_flash_time=.45
	if crafting_flash_button:
		crafting_flash_button.modulate=Color(.25,1.0,.35,1.0)
	_flash_message("URETIM TAMAMLANDI")

func _update_crafting_feedback(delta:float):
	if crafting_flash_time<=0.0: return
	crafting_flash_time-=delta
	if crafting_flash_button:
		var pulse=.65+sin(crafting_flash_time*30.0)*.18
		crafting_flash_button.scale=Vector2(pulse+0.35,pulse+0.35)
		if crafting_flash_time<=0.0:
			crafting_flash_button.modulate=Color.WHITE; crafting_flash_button.scale=Vector2.ONE


func _setup_sfx():
	# CC0 audio slots. Files can be replaced later without touching gameplay code.
	var paths={"gun":"res://assets/audio/gun.ogg","explosion":"res://assets/audio/explosion.ogg","chop":"res://assets/audio/chop.ogg","step":"res://assets/audio/steps.ogg","jump":"res://assets/audio/jump.ogg","death":"res://assets/audio/death.ogg","craft":"res://assets/audio/craft.ogg","break_wood":"res://assets/audio/break_wood.ogg","break_metal":"res://assets/audio/break_metal.ogg","break_stone":"res://assets/audio/break_stone.ogg","break_glass":"res://assets/audio/break_glass.ogg"}
	for key in paths:
		if ResourceLoader.exists(paths[key]):
			var p=AudioStreamPlayer.new(); p.stream=load(paths[key]); p.bus="Master"; add_child(p); sfx[key]=p

func _play_sfx(key:String):
	if sfx.has(key):
		var p:AudioStreamPlayer=sfx[key]
		p.pitch_scale=randf_range(.96,1.04); p.play()

func _update_footsteps(delta:float):
	if player==null: return
	var moving=Vector2(player.velocity.x,player.velocity.z).length()>1.0
	if moving and player.is_on_floor():
		step_timer-=delta
		if step_timer<=0.0: _play_sfx("step"); step_timer=.42
	else: step_timer=0.0


func _jump():
	if player and player.is_on_floor():
		player.velocity.y=7.2
		_play_sfx("jump")

func _death_feedback():
	_play_sfx("death"); _death_screen_effect()
	if scoped: _toggle_scope()


func _create_damage_effect(layer:CanvasLayer):
	damage_overlay=ColorRect.new(); damage_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	damage_overlay.color=Color(.55,.0,.0,0.0); damage_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(damage_overlay)

func _flash_damage(strength:=.38):
	if damage_overlay:
		damage_overlay.color=Color(.58,.0,.0,clamp(strength,.12,.72)); damage_time=.28

func _update_damage_effect(delta:float):
	if damage_overlay==null: return
	if damage_time>0:
		damage_time-=delta
		damage_overlay.color.a=move_toward(damage_overlay.color.a,0.0,delta*1.35)
	elif health<30:
		damage_overlay.color.a=.10+sin(Time.get_ticks_msec()/180.0)*.035
	else: damage_overlay.color.a=0.0

func _death_screen_effect():
	if damage_overlay: damage_overlay.color=Color(.48,.0,.0,.72); damage_time=1.25


func _muzzle_flash():
	if fx_root==null or player==null: return
	var flash=OmniLight3D.new(); flash.light_color=Color(1.0,.62,.22); flash.light_energy=4.0; flash.omni_range=3.5
	flash.position=player.global_position+Vector3(0,1.25,0)+(-player.global_transform.basis.z*1.0); fx_root.add_child(flash)
	var t=get_tree().create_timer(.07); t.timeout.connect(flash.queue_free)

func _gather_particles():
	if fx_root==null or player==null: return
	var p=GPUParticles3D.new(); p.amount=10; p.lifetime=.38; p.one_shot=true; p.explosiveness=1.0
	var mesh=BoxMesh.new(); mesh.size=Vector3(.035,.035,.035); p.draw_pass_1=mesh
	var pm=ParticleProcessMaterial.new(); pm.direction=Vector3(0,1,0); pm.spread=55.0; pm.initial_velocity_min=1.2; pm.initial_velocity_max=2.8; pm.gravity=Vector3(0,-5,0); p.process_material=pm
	p.position=player.global_position+(-player.global_transform.basis.z*1.2)+Vector3(0,.7,0); fx_root.add_child(p); p.emitting=true
	var t=get_tree().create_timer(.7); t.timeout.connect(p.queue_free)


func _create_ammo_ui(layer:CanvasLayer):
	ammo_label=Label.new(); ammo_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); ammo_label.position=Vector2(-260,-74); ammo_label.size=Vector2(220,42); ammo_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT; layer.add_child(ammo_label); _update_ammo_ui()

func _update_ammo_ui():
	if ammo_label: ammo_label.text=("DOLDURULUYOR..." if reloading else "%02d / %03d" % [magazine,reserve_ammo])

func _reload_weapon():
	if reloading or magazine>=magazine_size or reserve_ammo<=0: return
	reloading=true; reload_time=1.35; _update_ammo_ui()

func _update_reload(delta:float):
	if not reloading: return
	reload_time-=delta
	if reload_time<=0:
		var need=magazine_size-magazine; var take=min(need,reserve_ammo); magazine+=take; reserve_ammo-=take; reloading=false; _update_ammo_ui()


func _create_cheat_ui(layer:CanvasLayer):
	cheat_label=Label.new(); cheat_label.position=Vector2(510,10); cheat_label.size=Vector2(260,34); cheat_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; cheat_label.text=""; layer.add_child(cheat_label)

func _toggle_cheat_mode():
	cheat_mode=!cheat_mode
	if cheat_label: cheat_label.text=("HILE MODU ACIK" if cheat_mode else "")
	if creative_panel: creative_panel.visible=cheat_mode
	if cheat_mode:
		wood=9999; stone=9999; grass=9999; wheat=9999; mushrooms=9999; reserve_ammo=9999
		axe_count=max(axe_count,1); pickaxe_count=max(pickaxe_count,1)
		_flash_message("HILE MODU: SINIRSIZ URETIM")
	else: _flash_message("HILE MODU KAPALI")
	_update_ammo_ui()


func _create_creative_menu(layer:CanvasLayer):
	creative_panel=Panel.new(); creative_panel.position=Vector2(360,85); creative_panel.size=Vector2(560,430); creative_panel.visible=false; layer.add_child(creative_panel)
	var title=Label.new(); title.text="CREATIVE / HILE ENVANTERI"; title.position=Vector2(18,12); title.size=Vector2(520,35); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; creative_panel.add_child(title)
	var items=["BALTA","KAZMA","SILAH","MERMİ +100","ODUN +500","TAS +500","OT +500","BUGDAY +200","MANTAR +100","KAMP ATESI","EV PARCALARI","BOT"]
	for i in items.size():
		var b=Button.new(); b.text=items[i]; b.position=Vector2(24+(i%3)*174,60+(i/3)*78); b.size=Vector2(158,58); creative_panel.add_child(b); b.pressed.connect(_creative_give.bind(items[i]))

func _creative_give(item:String):
	if not cheat_mode: return
	match item:
		"BALTA": axe_count=max(axe_count,1); _select_hotbar(1)
		"KAZMA": pickaxe_count=max(pickaxe_count,1); _select_hotbar(2)
		"SILAH": _select_hotbar(3)
		"MERMİ +100": reserve_ammo+=100; _update_ammo_ui()
		"ODUN +500": wood+=500
		"TAS +500": stone+=500
		"OT +500": grass+=500
		"BUGDAY +200": wheat+=200
		"MANTAR +100": mushrooms+=100
		"KAMP ATESI": _build_campfire()
		"EV PARCALARI": build_mode=true; _select_hotbar(4); _ensure_build_preview()
		"BOT": _build_boat()
	_flash_message(item+" HAZIR")


func _fell_tree(tree:Node3D):
	# Tree tips away from the player, then disappears. Respawn scheduling stays unchanged.
	if tree==null or not is_instance_valid(tree): return
	var away=tree.global_position-player.global_position; away.y=0.0
	var axis=Vector3(away.z,0.0,-away.x).normalized()
	if axis.length()<.1: axis=Vector3.RIGHT
	var tw=create_tween(); tw.set_trans(Tween.TRANS_QUAD); tw.set_ease(Tween.EASE_IN)
	tw.tween_property(tree,"rotation",tree.rotation+axis*deg_to_rad(82.0),1.05)
	tw.parallel().tween_property(tree,"position:y",tree.position.y-.35,1.05)
	tw.tween_interval(.35); tw.tween_callback(tree.queue_free)


func _break_rock(rock:Node3D):
	if rock==null or not is_instance_valid(rock): return
	rock.visible=false
	for i in 8:
		var chunk=MeshInstance3D.new(); var mesh=BoxMesh.new(); mesh.size=Vector3(randf_range(.18,.42),randf_range(.14,.34),randf_range(.18,.42)); chunk.mesh=mesh
		var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.34,.33,.31); chunk.material_override=mat
		chunk.global_position=rock.global_position+Vector3(randf_range(-.35,.35),randf_range(.25,.8),randf_range(-.35,.35)); fx_root.add_child(chunk)
		var target=chunk.position+Vector3(randf_range(-1.4,1.4),randf_range(.25,.8),randf_range(-1.4,1.4))
		var tw=create_tween(); tw.set_parallel(true); tw.tween_property(chunk,"position",target,.42); tw.tween_property(chunk,"rotation",Vector3(randf()*4.0,randf()*4.0,randf()*4.0),.42)
		var timer=get_tree().create_timer(.55); timer.timeout.connect(chunk.queue_free)
	var t=get_tree().create_timer(.1); t.timeout.connect(rock.queue_free)


func _damage_structure(part:Node3D, damage:=35):
	if part==null or not is_instance_valid(part): return
	var kind=str(part.get_meta("build_piece",""))
	if kind not in ["DUVAR","PENCERE","KAPI"]: return
	var hp=int(part.get_meta("structure_hp",structure_hp_default))-damage
	part.set_meta("structure_hp",hp); _structure_hit_fx(part)
	if hp<=0: _shatter_structure(part,kind)

func _structure_hit_fx(part:Node3D):
	if fx_root==null: return
	for i in 5:
		var c=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=Vector3(.06,.06,.06); c.mesh=bm; c.global_position=part.global_position+Vector3(randf_range(-.5,.5),randf_range(.3,1.6),randf_range(-.3,.3)); fx_root.add_child(c)
		var tw=create_tween(); tw.tween_property(c,"position",c.position+Vector3(randf_range(-.5,.5),-.45,randf_range(-.5,.5)),.3); tw.tween_callback(c.queue_free)

func _shatter_structure(part:Node3D,kind:String):
	_play_break_sound(part,kind)
	part.visible=false
	var count=12 if kind=="DUVAR" else 8
	for i in count:
		var c=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=Vector3(randf_range(.12,.35),randf_range(.1,.28),randf_range(.08,.22)); c.mesh=bm; c.global_position=part.global_position+Vector3(randf_range(-1.0,1.0),randf_range(.25,1.8),randf_range(-.25,.25)); fx_root.add_child(c)
		var tw=create_tween(); tw.set_parallel(true); tw.tween_property(c,"position",c.position+Vector3(randf_range(-1.3,1.3),randf_range(-.7,.2),randf_range(-1.0,1.0)),.5); tw.tween_property(c,"rotation",Vector3(randf()*4.0,randf()*4.0,randf()*4.0),.5)
		var timer=get_tree().create_timer(.65); timer.timeout.connect(c.queue_free)
	var t=get_tree().create_timer(.12); t.timeout.connect(part.queue_free)


func _play_break_sound(part:Node3D,kind:String):
	var material_kind=str(part.get_meta("material",""))
	var sound="break_wood"
	if material_kind=="metal": sound="break_metal"
	elif material_kind=="stone": sound="break_stone"
	elif material_kind=="glass" or kind=="PENCERE": sound="break_glass"
	elif kind in ["DUVAR","KAPI"]: sound="break_wood"
	_play_sfx(sound)


func _add_human_limb(size:Vector3,pos:Vector3,mat:Material):
	var limb=MeshInstance3D.new(); var mesh=CapsuleMesh.new()
	mesh.radius=min(size.x,size.z)*.5; mesh.height=size.y
	limb.mesh=mesh; limb.position=pos; limb.material_override=mat; player.add_child(limb)


func _boss_visual() -> Node3D:
	var root=_enemy_visual(Color(.10,.11,.13),Vector3(2.15,2.15,2.15))
	var armor=StandardMaterial3D.new(); armor.albedo_color=Color(.20,.22,.24); armor.metallic=.75; armor.roughness=.32
	var dark=StandardMaterial3D.new(); dark.albedo_color=Color(.055,.06,.07); dark.metallic=.55
	_boss_armor_part(root,Vector3(.88,.42,.48),Vector3(0,1.28,0),armor)
	_boss_armor_part(root,Vector3(.34,.26,.42),Vector3(-.58,1.30,0),armor)
	_boss_armor_part(root,Vector3(.34,.26,.42),Vector3(.58,1.30,0),armor)
	_boss_armor_part(root,Vector3(.58,.22,.42),Vector3(0,.82,0),dark)
	_boss_armor_part(root,Vector3(.27,.46,.30),Vector3(-.20,.42,0),armor)
	_boss_armor_part(root,Vector3(.27,.46,.30),Vector3(.20,.42,0),armor)
	var helmet=MeshInstance3D.new(); var hm=SphereMesh.new(); hm.radius=.34; hm.height=.55; helmet.mesh=hm; helmet.position=Vector3(0,1.68,0); helmet.material_override=armor; root.add_child(helmet)
	return root

func _boss_armor_part(root:Node3D,size:Vector3,pos:Vector3,mat:Material):
	var m=MeshInstance3D.new(); var bx=BoxMesh.new(); bx.size=size; m.mesh=bx; m.position=pos; m.material_override=mat; root.add_child(m)


func _boss_can_fire(boss:Node) -> bool:
	return boss!=null and boss.has_meta("boss_weapon") and bool(boss.get_meta("boss_infinite_ammo",false))

func _is_player_loot_allowed(item:Node) -> bool:
	# Boss-only weapons/ammo are internal combat equipment and never enter loot/inventory UI.
	return item==null or not bool(item.get_meta("no_loot_weapon",false))


func _ammo_stock(ammo_type:String) -> int:
	match ammo_type:
		"7.62": return ammo_762
		"9MM": return ammo_9mm
		"12GA": return ammo_12ga
		"ROCKET": return ammo_rocket
	return 0

func _craft_explosive(kind:String):
	# Abstract game-only crafting costs, intentionally not a real-world recipe.
	if kind=="EL_BOMBASI":
		if not cheat_mode and (stone<12 or metal_scrap()<8): _flash_message("MALZEME YETERSIZ"); return
		if not cheat_mode: stone-=12
		grenade_count+=1; _craft_success_feedback()
	elif kind=="TNT":
		if not cheat_mode and (stone<20 or wood<10): _flash_message("MALZEME YETERSIZ"); return
		if not cheat_mode: stone-=20; wood-=10
		tnt_count+=1; _craft_success_feedback()

func metal_scrap() -> int:
	# Placeholder resource hook until scrap loot is added.
	return 9999 if cheat_mode else stone


func _throw_grenade():
	if grenade_count<=0 and not cheat_mode: _flash_message("EL BOMBASI YOK"); return
	if not cheat_mode: grenade_count-=1
	var p=player.global_position+Vector3(0,1.2,0)-player.global_transform.basis.z*4.5
	var timer=get_tree().create_timer(1.2); timer.timeout.connect(_game_explosion.bind(p,5.5,55))

func _place_tnt():
	if tnt_count<=0 and not cheat_mode: _flash_message("TNT YOK"); return
	if not cheat_mode: tnt_count-=1
	var p=player.global_position-player.global_transform.basis.z*2.2
	_flash_message("TNT YERLESTIRILDI")
	var timer=get_tree().create_timer(2.5); timer.timeout.connect(_game_explosion.bind(p,7.5,90))

func _game_explosion(pos:Vector3,radius:float,damage:int):
	_play_sfx("explosion")
	if fx_root:
		var light=OmniLight3D.new(); light.light_color=Color(1,.38,.08); light.light_energy=9; light.omni_range=radius*1.4; light.global_position=pos; fx_root.add_child(light)
		var timer=get_tree().create_timer(.14); timer.timeout.connect(light.queue_free)
	for e in enemies.duplicate():
		if is_instance_valid(e) and e.global_position.distance_to(pos)<=radius:
			e.set_meta("hp",int(e.get_meta("hp",60))-damage)
	for n in get_children():
		if n is Node3D and n.global_position.distance_to(pos)<=radius and n.has_meta("build_piece"): _damage_structure(n,damage)
	if player and player.global_position.distance_to(pos)<=radius:
		health=max(0,health-int(damage*.55)); _flash_damage(.65)
