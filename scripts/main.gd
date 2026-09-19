extends Node3D

const MAP_HALF := 200.0
const PLAYER_HEIGHT := 1.0
const POI_FLAT_RADIUS := 42.0

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
	"raider":{"scale":Vector3(1.12,1.12,1.12),"rot":Vector3.ZERO,"y":0.0},
	"boss":{"scale":Vector3(1.15,1.15,1.15),"rot":Vector3(0,0,180),"y":0.0},
	"boat":{"scale":Vector3.ONE,"rot":Vector3(180,0,0),"y":0.12},
	"campfire":{"scale":Vector3.ONE,"rot":Vector3.ZERO,"y":0.0},
	"tree_old_giant":{"scale":Vector3(.70,.70,.70),"rot":Vector3.ZERO,"y":0.0}
}
var tree_assets = [
	"res://assets/environment/trees/tree_pine_01.glb",
	"res://assets/environment/trees/tree_pine_02.glb",
	"res://assets/environment/trees/tree_oak_01.glb",
	"res://assets/environment/trees/tree_broadleaf_01.glb",
	"res://assets/environment/trees/tree_old_giant_01.glb",
	"res://assets/environment/trees/tree_young_01.glb",
	"res://assets/environment/trees/tree_young_02.glb",
	"res://assets/environment/trees/tree_pine_03.glb"
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
	"boat":"res://assets/vehicles/boat/wood_skiff.glb",
	"house_floor":"res://assets/building/wood/floor.glb",
	"house_wall":"res://assets/building/wood/wall.glb",
	"house_doorway":"res://assets/building/wood/doorway_wall.glb",
	"house_door":"res://assets/building/wood/door.glb",
	"house_window_wall":"res://assets/building/wood/window_wall.glb",
	"house_roof":"res://assets/building/wood/roof.glb",
	"house_stairs":"res://assets/building/wood/stairs.glb",
	"house_chest":"res://assets/props/survival/wood_chest.glb",
	"house_bed":"res://assets/props/survival/simple_bed.glb",
	"house_workbench":"res://assets/props/survival/workbench.glb",
	"house_stove":"res://assets/props/survival/crate.glb",
	"house_lamp":"res://assets/props/survival/lantern.glb"
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
var in_pit := false
var in_dry := false
var damage_buffer := 0.0
var shoot_flash_time := 0.0
var hit_label: Label
var world_env: WorldEnvironment
var zone_label: Label
var message_time := 0.0
var respawn_label: Label
var gather_label: Label
var campfire_pos := Vector3.ZERO
var heal_buffer := 0.0
var inventory_panel: Control
var store_panel: Control
var craft_panel: Control
var hotbar: Control
var selected_tool := "ELLER"
var axe_count := 0
var pickaxe_count := 0
var build_mode := false
var build_preview: Node3D
var build_piece := 0
var build_piece_names := ["TEMEL","DUVAR","KAPI","PENCERE","TAVAN","MERDIVEN"]
var scoped := false
var has_scope := true
var scope_overlay: Control
var aim_marker: Control
var recoil := 0.0
var damage_overlay: ColorRect
var damage_time := 0.0
var ammo_label: Label
var reloading := false
var reload_time := 0.0
var magazine_size := 30
var magazine := 30
var reserve_ammo := 120
var cheat_label: Label
var creative_panel: Control
var cheat_mode := false
var fx_root: Node3D
var structure_hp_default := 100
var ammo_762 := 48
var ammo_9mm := 60
var ammo_12ga := 24
var ammo_rocket := 3
var grenade_count := 0
var tnt_count := 0
var crosshair: Control
var hit_marker: Control
var hit_marker_time := 0.0
var minimap_panel: Control
var minimap_marks: Array = []
var has_bed_spawn := false
var bed_spawn := Vector3.ZERO
var held_item: Node3D
var day_label: Label
var day_clock := 9.0
var crafting_flash_time := 0.0
var crafting_flash_button: Control
var sfx: Dictionary = {}
var step_timer := 0.0
var hotbar_label: Label
var player_facing := Vector3(0,0,-1)
var player_move_speed := 3.4
var fly_mode := false
var fly_height := 0.0
var waypoint_active := false
var waypoint_pos := Vector3.ZERO
var waypoint_label: Label
var facing_label: Label
var map_waypoint: Label
var map_hint: Label
var touch_moved := false
var look_touch_id := -1
var look_pitch := 0.0
var look_sensitivity := 0.075
var chest_storage: Dictionary = {"wood":0,"stone":0,"grass":0,"wheat":0,"mushroom":0,"ammo":0}
var minimap_dot: Control
var minimap_dir: Control
var built_floors: Array[Node3D] = []
var built_roofs: Array[Node3D] = []
var built_walls: Array[Node3D] = []
var built_stairs: Array[Node3D] = []
var stair_mode := "terrain"
var stair_rise := .45
var preview_valid := false
var tree_hits: Dictionary = {}
var rock_hits: Dictionary = {}
var metal_parts := 0
var scope_stage := 0
var crouched := false
var crouch_button: Button
var waypoint_ground_arrow: Node3D
var waypoint_ground_arrows: Array[Node3D] = []
var weather_root: Node3D
var weather_particles: GPUParticles3D
var weather_timer := 55.0
var weather_duration := 0.0
var weather_state := "clear"
const RESOURCE_RESPAWN := 90.0
var respawn_nodes: Array = []

var pois := [
	{"id":"unfinished_house","name":"Tamamlanmamis Ev","pos":Vector3(-130,0,130),"color":Color(.34,.28,.20)},
	{"id":"watchtower","name":"Gozetleme Kulesi","pos":Vector3(0,0,160),"color":Color(.30,.27,.22)},
	{"id":"plane_wreck","name":"Ucak Enkazi","pos":Vector3(140,0,130),"color":Color(.30,.32,.33)},
	{"id":"tank_site","name":"Tank Bolgesi","pos":Vector3(170,0,0),"color":Color(.25,.29,.22)},
	{"id":"factory","name":"Fabrika","pos":Vector3(140,0,-130),"color":Color(.30,.29,.27)},
	{"id":"junkyard","name":"Arac Hurdaligi","pos":Vector3(0,0,-160),"color":Color(.34,.25,.19)},
	{"id":"military_post","name":"Askeri Karakol","pos":Vector3(-130,0,-130),"color":Color(.24,.28,.21)},
	{"id":"bunker","name":"Yeralti Siginagi","pos":Vector3(-170,0,0),"color":Color(.32,.32,.30)},
	{"id":"gas_station","name":"Terk Edilmis Benzinlik","pos":Vector3(-160,0,80),"color":Color(.38,.28,.18)},
	{"id":"shipyard","name":"Liman Tersane","pos":Vector3(160,0,80),"color":Color(.25,.29,.31)}
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
	# Keep scene entry light on Android: show the camera/HUD first, then build the
	# expensive world over several frames instead of blocking the first render.
	_build_player()
	_build_world_environment()
	_build_world_light()
	_build_hud()
	zone_label.text="DUNYA YUKLENIYOR..."
	call_deferred("_build_world_staged")

func _build_world_staged() -> void:
	await get_tree().process_frame
	_build_world_base()
	await get_tree().process_frame
	_build_weather_system()
	await get_tree().process_frame
	_build_rocks_staged()
	await get_tree().process_frame
	_build_meteors_staged()
	await get_tree().process_frame
	_build_trees_staged()
	await get_tree().process_frame
	_build_hills_and_pits()
	_build_pois()
	# Small plants/mushrooms removed. Trees are the only vegetation for now.
	# Raiders and bosses intentionally disabled for the KARA KIYI rebuild.
	zone_label.text=""

func height_at(x: float, z: float) -> float:
	if _near_poi(x, z):
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

func _near_poi(x: float, z: float) -> bool:
	for b in pois:
		if Vector2(x - b.pos.x, z - b.pos.z).length() < POI_FLAT_RADIUS:
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
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var r=ResourceLoader.load(path)
	if not (r is PackedScene):
		return null
	var n=(r as PackedScene).instantiate()
	if not (n is Node3D):
		if n: n.queue_free()
		return null
	return n

func _place_asset(path:String, parent:Node, pos:Vector3, scale_v:=Vector3.ONE, rot:=Vector3.ZERO)->Node3D:
	var n=_load_asset(path)
	if n==null: return null
	n.position=pos; n.scale=scale_v; n.rotation_degrees=rot; parent.add_child(n); return n

func _ground_color(h:float, z:float=0.0)->Color:
	# KARA KIYI south-shore blend. Keep water material untouched.
	if z < -170.0:
		var shore_t=clampf((-170.0-z)/18.0,0.0,1.0)
		return Color(.78,.70,.42).lerp(Color(.50,.42,.31),shore_t)
	if h < -1.5: return Color(.52,.38,.22)
	if h < .4: return Color(.78,.70,.42)
	if h > 6.0: return Color(.62,.60,.55)
	return Color(1,1,1)

func _ground_asset_to_terrain(n:Node3D, x:float, z:float)->void:
	var ymin:=INF
	var stack:Array[Node]=[n]
	while not stack.is_empty():
		var cur=stack.pop_back()
		if cur is MeshInstance3D and cur.mesh!=null:
			var aabb: AABB=cur.mesh.get_aabb()
			for ix in 2:
				for iy in 2:
					for iz in 2:
						var corner=aabb.position+Vector3(aabb.size.x*ix,aabb.size.y*iy,aabb.size.z*iz)
						ymin=minf(ymin,(cur.global_transform*corner).y)
		for child in cur.get_children(): stack.append(child)
	if ymin<INF: n.global_position.y+=height_at(x,z)-ymin

func _add_tree_canopy(parent:Node3D, tree_path:String, tree_scale:float)->void:
	var canopy_color=Color(.18,.46,.14) if "pine" in tree_path else Color(.24,.52,.16)
	if not ("pine" in tree_path or "oak" in tree_path or "broadleaf" in tree_path): return
	var offsets:Array[Vector3]
	if "pine" in tree_path:
		offsets=[Vector3(0,3.6,0),Vector3(0,4.8,0),Vector3(0,6.0,0),Vector3(0,7.2,0)]
	else:
		offsets=[Vector3(-.8,5.0,0),Vector3(.8,5.1,.2),Vector3(0,5.8,-.7),Vector3(0,6.2,.7)]
	for off in offsets:
		var crown=MeshInstance3D.new(); var sphere=SphereMesh.new()
		sphere.radius=(1.45 if "pine" in tree_path else 1.8)*tree_scale; sphere.height=sphere.radius*2.0
		crown.mesh=sphere; crown.position=off*tree_scale; crown.material_override=_simple_mat(canopy_color); parent.add_child(crown)

func _terrain_surface(cells:int) -> ArrayMesh:
	var st=SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step:=(MAP_HALF*2.0)/float(cells)
	for z in cells:
		for x in cells:
			var x0=-MAP_HALF+x*step; var x1=x0+step; var z0=-MAP_HALF+z*step; var z1=z0+step
			var a=Vector3(x0,height_at(x0,z0),z0); var b=Vector3(x1,height_at(x1,z0),z0); var cc=Vector3(x1,height_at(x1,z1),z1); var d=Vector3(x0,height_at(x0,z1),z1)
			st.set_color(_ground_color(a.y,a.z)); st.set_uv(Vector2(x0/8.0,z0/8.0)); st.add_vertex(a)
			st.set_color(_ground_color(b.y,b.z)); st.set_uv(Vector2(x1/8.0,z0/8.0)); st.add_vertex(b)
			st.set_color(_ground_color(cc.y,cc.z)); st.set_uv(Vector2(x1/8.0,z1/8.0)); st.add_vertex(cc)
			st.set_color(_ground_color(a.y,a.z)); st.set_uv(Vector2(x0/8.0,z0/8.0)); st.add_vertex(a)
			st.set_color(_ground_color(cc.y,cc.z)); st.set_uv(Vector2(x1/8.0,z1/8.0)); st.add_vertex(cc)
			st.set_color(_ground_color(d.y,d.z)); st.set_uv(Vector2(x0/8.0,z1/8.0)); st.add_vertex(d)
	st.generate_normals()
	return st.commit()

func _build_terrain_mesh():
	var mesh=_terrain_surface(64)
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.22,.34,.13); mat.roughness=.96; mat.vertex_color_use_as_albedo=true
	if ResourceLoader.exists("res://assets/environment/ground/grass_albedo.jpg"):
		var t=ResourceLoader.load("res://assets/environment/ground/grass_albedo.jpg")
		if t is Texture2D: mat.albedo_texture=t
	if ResourceLoader.exists("res://assets/environment/ground/grass_normal.png"):
		var n=ResourceLoader.load("res://assets/environment/ground/grass_normal.png")
		if n is Texture2D: mat.normal_enabled=true; mat.normal_texture=n
	if ResourceLoader.exists("res://assets/environment/ground/grass_roughness.jpg"):
		var r=ResourceLoader.load("res://assets/environment/ground/grass_roughness.jpg")
		if r is Texture2D: mat.roughness_texture=r
	var terrain=MeshInstance3D.new(); terrain.name="Terrain"; terrain.mesh=mesh; terrain.material_override=mat; add_child(terrain)
	# Keep the visible terrain detailed, but use a much coarser collision mesh on startup.
	var collision_mesh=_terrain_surface(24)
	var body=StaticBody3D.new(); body.name="TerrainCollision"
	var cs=CollisionShape3D.new(); cs.shape=collision_mesh.create_trimesh_shape(); body.add_child(cs); add_child(body)

func _make_kara_tree(parent:Node3D) -> void:
	# Upright original tree: dark weathered trunk + conifer crown.
	var trunk=MeshInstance3D.new(); var tm=CylinderMesh.new(); tm.top_radius=.22; tm.bottom_radius=.34; tm.height=5.2
	trunk.mesh=tm; trunk.position.y=2.6; trunk.material_override=_simple_mat(Color(.18,.105,.055)); parent.add_child(trunk)
	for i in 4:
		var crown=MeshInstance3D.new(); var cm=CylinderMesh.new()
		cm.top_radius=.05; cm.bottom_radius=1.65-float(i)*.22; cm.height=2.2
		crown.mesh=cm; crown.position.y=4.4+float(i)*.85; crown.material_override=_simple_mat(Color(.10,.22,.12)); parent.add_child(crown)

func _make_meteor(parent:Node3D) -> void:
	var meteor=MeshInstance3D.new(); var mm=SphereMesh.new(); mm.radius=.72; mm.height=1.15
	meteor.mesh=mm; meteor.position.y=.48; meteor.scale=Vector3(1.22,.74,1.02); meteor.rotation_degrees=Vector3(randf_range(-8,8),randf_range(0,360),randf_range(-6,6))
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.27,.23,.22); mat.metallic=.58; mat.roughness=.82; meteor.material_override=mat; parent.add_child(meteor)

func _make_kara_rock(parent:Node3D) -> void:
	# Light coastal stone, deliberately not coal-black.
	var rock=MeshInstance3D.new(); var rm=SphereMesh.new(); rm.radius=.72; rm.height=1.15
	rock.mesh=rm; rock.position.y=.48; rock.scale=Vector3(1.25,.72,1.0); rock.rotation_degrees=Vector3(randf_range(-8,8),randf_range(0,360),randf_range(-6,6))
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.68,.67,.63); mat.roughness=.96; rock.material_override=mat; parent.add_child(rock)

func _build_world_environment() -> void:
	if world_env != null:
		return
	world_env=WorldEnvironment.new()
	var env=Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=Color(.48,.65,.76)
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=Color(.62,.68,.72)
	env.ambient_light_energy=.65
	env.tonemap_mode=Environment.TONE_MAPPER_FILMIC
	env.fog_enabled=true
	env.fog_light_color=Color(.68,.73,.75)
	env.fog_density=.0028
	world_env.environment=env
	add_child(world_env)

func _build_world_light() -> void:
	if get_node_or_null("WorldSun") != null:
		return
	var sun=DirectionalLight3D.new()
	sun.name="WorldSun"
	sun.rotation_degrees=Vector3(-52,-28,0)
	sun.light_energy=1.15
	sun.shadow_enabled=not OS.has_feature("mobile")
	sun.directional_shadow_max_distance=95
	add_child(sun)

func _build_world_base():
	_build_world_environment()
	_build_world_light()
	_build_terrain_mesh()
	# Coastal water band for boat construction.
	var water=MeshInstance3D.new(); water.name="Water"; var wm=PlaneMesh.new(); wm.size=Vector2(400,28); water.mesh=wm; water.position=Vector3(0,.03,-190)
	var wmat=StandardMaterial3D.new(); wmat.albedo_color=Color(.04,.28,.42,.78); wmat.metallic=.08; wmat.roughness=.18; wmat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA; water.material_override=wmat; add_child(water)

func _build_rocks_staged() -> void:
	for i in (40 if OS.has_feature("mobile") else 156):
		var p = _rand_map_point(MAP_HALF - 12)
		if not _near_poi(p.x, p.z):
			var rock_body=StaticBody3D.new(); rock_body.position=Vector3(p.x,height_at(p.x,p.z),p.z); add_child(rock_body)
			_make_kara_rock(rock_body)
			var rcs=CollisionShape3D.new(); var rsh=SphereShape3D.new(); rsh.radius=.68; rcs.shape=rsh; rcs.position.y=.5; rock_body.add_child(rcs)
			rock_body.set_meta("loot","stone")
		if i > 0 and i % 16 == 0:
			await get_tree().process_frame

func _build_meteors_staged() -> void:
	for i in (40 if OS.has_feature("mobile") else 156):
		var mp = _rand_map_point(MAP_HALF - 12)
		if not _near_poi(mp.x, mp.z):
			var meteor_body=StaticBody3D.new(); meteor_body.position=Vector3(mp.x,height_at(mp.x,mp.z),mp.z); add_child(meteor_body)
			_make_meteor(meteor_body)
			var mcs=CollisionShape3D.new(); var msh=SphereShape3D.new(); msh.radius=.68; mcs.shape=msh; mcs.position.y=.5; meteor_body.add_child(mcs)
			meteor_body.set_meta("loot","meteor")
		if i > 0 and i % 16 == 0:
			await get_tree().process_frame

func _build_trees_staged() -> void:
	for i in (80 if OS.has_feature("mobile") else 330):
		var p = _rand_map_point(MAP_HALF - 12)
		if not _near_poi(p.x, p.z):
			var tree_body=StaticBody3D.new(); tree_body.position=Vector3(p.x,height_at(p.x,p.z),p.z); tree_body.rotation_degrees.y=randf_range(0,360); add_child(tree_body)
			_make_kara_tree(tree_body)
			var trunk_col=CollisionShape3D.new(); var trunk_shape=CylinderShape3D.new(); trunk_shape.radius=.34; trunk_shape.height=5.2; trunk_col.shape=trunk_shape; trunk_col.position.y=2.6; tree_body.add_child(trunk_col)
			tree_body.set_meta("loot","wood")
		if i > 0 and i % 16 == 0:
			await get_tree().process_frame

func _build_hills_and_pits():
	# Terrain heightfield already provides hills and pits. Avoid duplicate cylinder geometry.
	pass

func _build_gatherables():
	# Vegetation intentionally disabled; trees are spawned by _build_world only.
	pass

func _rand_map_point(max_r: float) -> Vector3:
	return Vector3(randf_range(-max_r,max_r),0,randf_range(-max_r,max_r))

func _build_pois():
	# Build the ten abandoned survival POIs.
	for b in pois:
		_build_survival_poi(b)

func _build_player():
	player = CharacterBody3D.new()
	player.position = Vector3(0, height_at(0.0,0.0) + PLAYER_HEIGHT, 0)
	var col = CollisionShape3D.new()
	var capshape = CapsuleShape3D.new()
	capshape.radius = 0.42
	capshape.height = 1.7
	col.shape = capshape
	player.add_child(col)
	add_child(player)
	# First-person KARA KIYI camera. No third-person body/head is rendered.
	camera = Camera3D.new()
	camera.name = "FirstPersonCamera"
	camera.position = Vector3(0, 0.72, 0)
	camera.fov = 72
	camera.current = true
	player.add_child(camera)

func _build_hud():
	var layer = CanvasLayer.new()
	add_child(layer)
	hit_label=Label.new(); hit_label.set_anchors_preset(Control.PRESET_CENTER); hit_label.position=Vector2(-20,-35); hit_label.text="+"; hit_label.visible=false; hit_label.add_theme_font_size_override("font_size",32); layer.add_child(hit_label)
	zone_label=Label.new(); zone_label.set_anchors_preset(Control.PRESET_TOP_WIDE); zone_label.position=Vector2(0,18); zone_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; zone_label.add_theme_font_size_override("font_size",24); layer.add_child(zone_label)
	hud=Label.new(); hud.position=Vector2(176,22); hud.add_theme_font_size_override("font_size",18); layer.add_child(hud)
	joystick_base=ColorRect.new(); joystick_base.set_anchors_preset(Control.PRESET_BOTTOM_LEFT); joystick_base.position=Vector2(24,-224); joystick_base.size=Vector2(200,200); joystick_base.color=Color(.08,.08,.08,.32); layer.add_child(joystick_base)
	joystick_knob=ColorRect.new(); joystick_knob.position=Vector2(64,64); joystick_knob.size=Vector2(72,72); joystick_knob.color=Color(.92,.92,.92,.55); joystick_base.add_child(joystick_knob)
	for item in [["↑",Vector2(88,4)],["↓",Vector2(88,168)],["←",Vector2(8,86)],["→",Vector2(168,86)]]:
		var jl=Label.new(); jl.text=item[0]; jl.position=item[1]; jl.size=Vector2(28,28); jl.add_theme_font_size_override("font_size",22); jl.mouse_filter=Control.MOUSE_FILTER_IGNORE; joystick_base.add_child(jl)
	# URET, DOLDUR, BOMBA and TNT are intentionally removed from the gameplay HUD.
	var actions=[["KULLAN",_use_nearest_interior],["ENVANTER",_toggle_inventory],["PARCA",_cycle_build_piece],["HILE",_toggle_cheat_mode],["UC",_toggle_fly_mode],["ALCAL",_fly_down],["MAĞAZA",_open_store]]
	for i in actions.size():
		var b=Button.new(); b.text=actions[i][0]; b.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		var col=i%2; var row=int(i/2); b.position=Vector2(-300+col*148,12+row*42); b.size=Vector2(140,38); b.add_theme_font_size_override("font_size",15); b.pressed.connect(actions[i][1]); layer.add_child(b)
	_create_hotbar(layer); _create_minimap(layer); _create_weapon_aim_ui(layer)
	var action_btn=Button.new(); action_btn.text="VUR"; action_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); action_btn.position=Vector2(-250,-215); action_btn.size=Vector2(104,104); action_btn.add_theme_font_size_override("font_size",20)
	var action_style=StyleBoxFlat.new(); action_style.bg_color=Color(1.0,.78,.08,.34); action_style.corner_radius_top_left=52; action_style.corner_radius_top_right=52; action_style.corner_radius_bottom_left=52; action_style.corner_radius_bottom_right=52
	action_btn.add_theme_stylebox_override("normal",action_style); action_btn.add_theme_stylebox_override("pressed",action_style); action_btn.pressed.connect(_primary_action); layer.add_child(action_btn)
	var jump_btn=Button.new(); jump_btn.text="↑ Zıpla"; jump_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); jump_btn.position=Vector2(-238,-310); jump_btn.size=Vector2(92,76); jump_btn.add_theme_font_size_override("font_size",18); jump_btn.pressed.connect(_jump); layer.add_child(jump_btn)
	var scope_btn=Button.new(); scope_btn.text="🔭"; scope_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); scope_btn.position=Vector2(-350,-320); scope_btn.size=Vector2(82,82); scope_btn.add_theme_font_size_override("font_size",28)
	var scope_style=StyleBoxFlat.new(); scope_style.bg_color=Color(.10,.10,.10,.30); scope_style.corner_radius_top_left=41; scope_style.corner_radius_top_right=41; scope_style.corner_radius_bottom_left=41; scope_style.corner_radius_bottom_right=41
	scope_btn.add_theme_stylebox_override("normal",scope_style); scope_btn.add_theme_stylebox_override("pressed",scope_style); scope_btn.pressed.connect(_toggle_scope); layer.add_child(scope_btn)
	var build_btn=Button.new(); build_btn.text="İNŞA ET"; build_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT); build_btn.position=Vector2(28,-390); build_btn.size=Vector2(150,56); build_btn.pressed.connect(_build_house); layer.add_child(build_btn)
	crouch_button=Button.new(); crouch_button.text="↓ Çömel"; crouch_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); crouch_button.position=Vector2(-238,-104); crouch_button.size=Vector2(104,80); crouch_button.add_theme_font_size_override("font_size",18)
	var crouch_style=StyleBoxFlat.new(); crouch_style.bg_color=Color(.12,.12,.12,.34); crouch_style.corner_radius_top_left=40; crouch_style.corner_radius_top_right=40; crouch_style.corner_radius_bottom_left=40; crouch_style.corner_radius_bottom_right=40
	crouch_button.add_theme_stylebox_override("normal",crouch_style); crouch_button.add_theme_stylebox_override("pressed",crouch_style); crouch_button.pressed.connect(_toggle_crouch); layer.add_child(crouch_button)
	var aim=Label.new(); aim.text="+"; aim.set_anchors_preset(Control.PRESET_CENTER); aim.position=Vector2(-14,-22); aim.size=Vector2(28,44); aim.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; aim.add_theme_font_size_override("font_size",32); aim.add_theme_color_override("font_color",Color(.95,.08,.06,1)); aim.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(aim)
	_create_survival_clock(layer); _create_damage_effect(layer); _create_ammo_ui(layer); _create_cheat_ui(layer)
	facing_label=Label.new(); facing_label.set_anchors_preset(Control.PRESET_TOP_WIDE); facing_label.position=Vector2(0,48); facing_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; facing_label.add_theme_font_size_override("font_size",22); layer.add_child(facing_label)
	waypoint_label=Label.new(); waypoint_label.set_anchors_preset(Control.PRESET_TOP_WIDE); waypoint_label.position=Vector2(0,76); waypoint_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; waypoint_label.add_theme_font_size_override("font_size",20); layer.add_child(waypoint_label)
	_create_creative_menu(layer); _setup_sfx(); fx_root=Node3D.new(); fx_root.name="Effects"; add_child(fx_root)

func _open_store():
	if store_panel==null:
		_create_store_panel()
	store_panel.visible=not store_panel.visible

func _create_store_panel():
	var layers=get_children().filter(func(n): return n is CanvasLayer)
	if layers.is_empty(): return
	store_panel=Panel.new()
	store_panel.set_anchors_preset(Control.PRESET_CENTER)
	store_panel.position=Vector2(-390,-290)
	store_panel.size=Vector2(780,580)
	layers[-1].add_child(store_panel)
	var title=Label.new(); title.text="MAĞAZA"; title.position=Vector2(20,12); title.size=Vector2(620,38); title.add_theme_font_size_override("font_size",26); store_panel.add_child(title)
	var close=Button.new(); close.text="✕"; close.position=Vector2(712,10); close.size=Vector2(50,38); close.pressed.connect(_open_store); store_panel.add_child(close)
	var categories=["TÜMÜ","SİLAHLAR","MERMİLER","ZIRHLAR","ALETLER"]
	for i in categories.size():
		var b=Button.new(); b.text=categories[i]
		b.position=Vector2(18+i*146,58); b.size=Vector2(140,44); b.add_theme_font_size_override("font_size",14)
		b.pressed.connect(_store_category.bind(categories[i])); store_panel.add_child(b)
	_store_category("TÜMÜ")
	store_panel.visible=true

func _store_items(category:String) -> Array:
	var colors=["gray","green","blue","orange","red"]
	var bases:Array=[]
	if category=="TÜMÜ":
		var all:Array=[]
		for cat in ["SİLAHLAR","MERMİLER","ZIRHLAR","ALETLER"]:
			all.append_array(_store_items(cat))
		return all
	if category=="SİLAHLAR":
		bases=[
			["spear","Mızrak"],["torch","Meşale"],["bow","Yay"],["crossbow","Arbalet"],
			["pistol","Tabanca"],["shotgun","Pompalı"],["rifle","Tüfek"],["explosive","Patlayıcı"]
		]
	elif category=="MERMİLER":
		bases=[
			["pistol_ammo","Tabanca Mermisi"],["shotgun_shell","Pompalı Mermisi"],["rifle_ammo","Tüfek Mermisi"],
			["arrow","Ok"],["spearhead","Mızrak Ucu"]
		]
	elif category=="ZIRHLAR":
		bases=[
			["wood_helmet","Ahşap Kask"],["wood_chest","Ahşap Göğüslük"],["wood_pants","Ahşap Pantolon"],["wood_boots","Ahşap Bot"],
			["stone_helmet","Taş Kask"],["stone_chest","Taş Göğüslük"],["stone_pants","Taş Pantolon"],["stone_boots","Taş Bot"],
			["metal_helmet","Metal Kask"],["metal_chest","Metal Göğüslük"],["metal_pants","Metal Pantolon"],["metal_boots","Metal Bot"]
		]
	elif category=="ALETLER":
		# Alet görselleri ayrı asset olarak eklendiğinde bu listeye bağlanacak.
		# Şimdilik kategori korunuyor ve mevcut mağaza davranışı kaybolmuyor.
		return []
	var items:Array=[]
	for base in bases:
		for rarity in colors:
			var suffix=rarity
			if category=="MERMİLER":
				match rarity:
					"gray": suffix="normal_gray"
					"green": suffix="sharp_green"
					"blue": suffix="piercing_blue"
					"orange": suffix="incendiary_orange"
					"red": suffix="explosive_red"
			var folder="armor-assets-2" if category=="ZIRHLAR" else "weapons-ammo-armor"
			var path="res://assets/%s/%s_%s_128.png" % [folder,base[0],suffix]
			items.append({"name":base[1],"rarity":rarity,"path":path})
	return items

func _store_rarity_name(rarity:String) -> String:
	match rarity:
		"gray": return "Gri"
		"green": return "Yeşil"
		"blue": return "Mavi"
		"orange": return "Turuncu"
		"red": return "Kırmızı"
	return rarity

func _store_category(category:String):
	if store_panel==null: return
	var old=store_panel.get_node_or_null("ItemsScroll")
	if old: old.queue_free()
	var scroll=ScrollContainer.new(); scroll.name="ItemsScroll"; scroll.position=Vector2(20,116); scroll.size=Vector2(740,440); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	store_panel.add_child(scroll)
	var grid=GridContainer.new(); grid.name="ItemGrid"; grid.columns=5; grid.custom_minimum_size=Vector2(720,0); grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	for item in _store_items(category):
		var slot=Button.new()
		slot.custom_minimum_size=Vector2(136,112); slot.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		slot.expand_icon=true
		slot.icon_max_width=82
		slot.tooltip_text="%s • %s" % [item.name,_store_rarity_name(item.rarity)]
		if ResourceLoader.exists(item.path):
			slot.icon=load(item.path)
		else:
			slot.text=item.name
		grid.add_child(slot)
	_flash_message("MAĞAZA: "+category)

func _nearest_poi() -> String:
	var best := ""
	var best_d := 9999.0
	for b in pois:
		var d = Vector2(player.position.x - b.pos.x, player.position.z - b.pos.z).length()
		if d < best_d:
			best_d = d
			best = "%s (%.0f m)" % [b.name, d]
	return best

func _physics_process(delta):
	if player == null or camera == null or hud == null or zone_label == null:
		return
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
	# Mobile movement follows what the camera/player is facing: up=forward, down=back.
	var forward=Vector3(0,0,-1)
	var right=Vector3(1,0,0)
	if camera:
		forward=-camera.global_transform.basis.z; forward.y=0.0; forward=forward.normalized()
		right=camera.global_transform.basis.x; right.y=0.0; right=right.normalized()
	var dir = right*v.x + forward*(-v.y)
	if dir.length() > 1.0: dir = dir.normalized()
	var speed = player_move_speed * (.70 if in_pit else 1.0)
	if hunger<20.0 or thirst<20.0: speed*=.78
	if fly_mode: speed*=2.2
	# FPS view direction is controlled by right-side look drag, not movement stick.
	player.velocity.x=dir.x*speed; player.velocity.z=dir.z*speed
	if fly_mode:
		player.velocity.y=0.0
		player.position += Vector3(player.velocity.x,0,player.velocity.z)*delta
	else:
		# Real jump physics: upward impulse, gravity while airborne, then collision landing.
		if not player.is_on_floor():
			player.velocity.y-=18.0*delta
		elif player.velocity.y<0.0:
			player.velocity.y=0.0
		player.move_and_slide()
	player.position.x = clampf(player.position.x, -MAP_HALF + 2.0, MAP_HALF - 2.0)
	player.position.z = clampf(player.position.z, -MAP_HALF + 2.0, MAP_HALF - 2.0)
	var hy = height_at(player.position.x, player.position.z)
	if not fly_mode:
		# Terrain has no physics body, so only clamp when falling to terrain. Never overwrite
		# positive jump velocity, otherwise jumping teleports/snaps instead of making an arc.
		var floor_under:=false
		for f in built_floors + built_roofs:
			if not is_instance_valid(f): continue
			var lp=player.global_position-f.global_position
			if absf(lp.x)<=2.48 and absf(lp.z)<=2.48 and player.global_position.y>=f.global_position.y:
				floor_under=true; break
		var terrain_y=hy+PLAYER_HEIGHT
		if not floor_under and player.position.y<=terrain_y and player.velocity.y<=0.0:
			player.position.y=terrain_y
			player.velocity.y=0.0
	elif player.position.y < hy+3.0: player.position.y=hy+3.0
	in_pit = hy < -2.0
	in_dry = _near_poi(player.position.x, player.position.z)
	var flat = Vector2(player.position.x, player.position.z)
	_update_combat(delta)
	_update_resource_respawns(delta)
	_update_build_preview()
	_update_map_dot()
	_update_navigation_ui()
	_update_minimap()
	_update_aim_marker()
	_update_weapon_feedback(delta)
	_update_day_cycle(delta)
	_update_weather(delta)
	_update_footsteps(delta)
	_update_damage_effect(delta)
	_update_reload(delta)
	_update_crafting_feedback(delta)
	if health <= 0:
		_death_feedback()
		_respawn()
	var zone = "VAHSI"
	if in_pit:
		zone = "CUKUR"
	elif in_dry:
		zone = "TERK EDILMIS BOLGE"
	zone_label.text="%s  •  %s" % [zone,_nearest_poi()]
	hud.text = "HP %d  Ac %d  Su %d  Kart %d  Mermi %d\nOdun %d  Tas %d  Cim %d  Bugday %d  Mantar %d" % [
		health, int(hunger), int(thirst), gray_cards, ammo,
		wood, stone, grass_n, wheat_n, mushroom_n
	]

func _build_weather_system():
	weather_root=Node3D.new(); weather_root.name="LocalWeather"; add_child(weather_root)
	# Compatibility renderer on Android can be fragile with startup GPU particles.
	# Weather state still runs; particles are simply omitted on mobile.
	if OS.has_feature("mobile"):
		weather_particles=null
		return
	weather_particles=GPUParticles3D.new(); weather_particles.amount=420; weather_particles.lifetime=2.2; weather_particles.visibility_aabb=AABB(Vector3(-18,-14,-18),Vector3(36,28,36)); weather_particles.emitting=false; weather_root.add_child(weather_particles)
	var pm=ParticleProcessMaterial.new(); pm.emission_shape=ParticleProcessMaterial.EMISSION_SHAPE_BOX; pm.emission_box_extents=Vector3(13,.5,13); pm.direction=Vector3(0,-1,0); pm.spread=8.0; pm.initial_velocity_min=12.0; pm.initial_velocity_max=18.0; pm.gravity=Vector3(0,-9,0); weather_particles.process_material=pm
	var mesh=QuadMesh.new(); mesh.size=Vector2(.035,1.0); var mat=StandardMaterial3D.new(); mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED; mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA; mat.albedo_color=Color(.72,.82,.88,.65); mesh.material=mat; weather_particles.draw_pass_1=mesh

func _set_weather(kind:String):
	weather_state=kind
	if weather_particles==null: return
	var env:Environment=world_env.environment if world_env else null
	if kind=="clear":
		weather_particles.emitting=false; weather_duration=0.0; weather_timer=randf_range(45.0,100.0)
		if env:
			env.background_color=Color(.48,.65,.76); env.ambient_light_color=Color(.62,.68,.72); env.ambient_light_energy=.65
			env.fog_enabled=true; env.fog_light_color=Color(.68,.73,.75); env.fog_density=.0028
		return
	var pm=weather_particles.process_material as ParticleProcessMaterial; var mesh=weather_particles.draw_pass_1 as QuadMesh; var mat=mesh.material as StandardMaterial3D
	if kind=="rain":
		weather_particles.amount=460; weather_particles.lifetime=2.0; pm.initial_velocity_min=13.0; pm.initial_velocity_max=19.0; pm.gravity=Vector3(0,-10,0); pm.spread=8.0; mesh.size=Vector2(.035,1.15); mat.albedo_color=Color(.65,.76,.84,.62); weather_duration=randf_range(35.0,70.0)
		if env:
			env.background_color=Color(.18,.23,.27); env.ambient_light_color=Color(.42,.47,.50); env.ambient_light_energy=.46
			env.fog_enabled=true; env.fog_light_color=Color(.38,.43,.46); env.fog_density=.010
	else:
		weather_particles.amount=260; weather_particles.lifetime=5.0; pm.initial_velocity_min=1.2; pm.initial_velocity_max=2.5; pm.gravity=Vector3(0,-.8,0); pm.spread=35.0; mesh.size=Vector2(.13,.13); mat.albedo_color=Color(.95,.97,1.0,.82); weather_duration=randf_range(30.0,60.0)
		if env:
			env.background_color=Color(.55,.62,.67); env.ambient_light_color=Color(.70,.76,.82); env.ambient_light_energy=.55
			env.fog_enabled=true; env.fog_light_color=Color(.76,.82,.86); env.fog_density=.007
	weather_particles.restart(); weather_particles.emitting=true

func _update_weather(delta:float):
	if weather_root and player: weather_root.global_position=player.global_position+Vector3(0,11,0)
	if weather_state=="clear":
		weather_timer-=delta
		if weather_timer<=0.0:
			var roll=randf()
			_set_weather("snow" if roll<.22 else "rain")
	else:
		weather_duration-=delta
		if weather_duration<=0.0: _set_weather("clear")

func _toggle_crouch():
	if player==null or camera==null: return
	crouched=not crouched
	camera.position.y=.34 if crouched else .72
	player_move_speed=2.4 if crouched else 3.4
	if crouch_button: crouch_button.text="↑ Kalk" if crouched else "↓ Çömel"

func _look_pad_input(event):
	if event is InputEventScreenDrag and player and camera:
		# Preserve the left movement zone and right-side button column.
		var vw=get_viewport().get_visible_rect().size.x
		if event.position.x < vw*.32 or event.position.x > vw*.78: return
		player.rotation_degrees.y -= event.relative.x * look_sensitivity
		look_pitch=clampf(look_pitch-event.relative.y*look_sensitivity,-72.0,72.0)
		camera.rotation_degrees.x=look_pitch
		player_facing=-player.global_transform.basis.z

func _input(event):
	if event is InputEventScreenTouch:
		var vw=get_viewport().get_visible_rect().size.x
		if event.pressed:
			# Movement joystick only owns touches that actually begin inside its left control area.
			# Previously almost the whole left half of the screen could latch movement.
			if event.position.x < vw * 0.32 and touch_id == -1:
				touch_id=event.index; touch_start=event.position; touch_moved=false; move_touch=Vector2.ZERO
			elif event.position.x >= vw * 0.45 and look_touch_id == -1:
				look_touch_id=event.index
		else:
			if event.index == touch_id:
				touch_id=-1; move_touch=Vector2.ZERO
				if joystick_knob: joystick_knob.position=Vector2(64,64)
				
			elif event.index == look_touch_id:
				look_touch_id=-1
	elif event is InputEventScreenDrag:
		if event.index == touch_id:
			if event.position.distance_to(touch_start)>18.0: touch_moved=true
			move_touch=(event.position-touch_start)/54.0
			if move_touch.length()<0.10: move_touch=Vector2.ZERO
			else: move_touch=move_touch.limit_length(1.0)
			if joystick_knob: joystick_knob.position=Vector2(64,64)+move_touch*26.0
		elif event.index == look_touch_id and player and camera:
			# Slow, controlled FPS look. Horizontal drag turns the facing direction.
			player.rotation_degrees.y -= event.relative.x * look_sensitivity
			look_pitch=clampf(look_pitch-event.relative.y*look_sensitivity,-72.0,72.0)
			camera.rotation_degrees.x=look_pitch
			player_facing=-player.global_transform.basis.z
	elif event.is_action_pressed("build_fire"):
		_build_fire()
	elif event.is_action_pressed("build_house"):
		_build_house()

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
	for b in pois:
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
		if flat.length() < 18.0:
			e.velocity = flat.normalized() * 2.2; e.move_and_slide(); e.global_position.y=height_at(e.global_position.x,e.global_position.z)+.05
			if d.length() < 1.5: _apply_damage(12.0 * delta)
	for b in fort_bosses:
		if not is_instance_valid(b): continue
		var d = player.global_position - b.global_position; var flat=Vector3(d.x,0,d.z)
		if flat.length() < 26.0:
			b.velocity = flat.normalized() * 1.6; b.move_and_slide(); b.global_position.y=height_at(b.global_position.x,b.global_position.z)+.05
			if d.length() < 2.0: _apply_damage(18.0 * delta)

func _apply_damage(amount:float):
	damage_buffer += amount
	var whole=int(floor(damage_buffer))
	if whole>0:
		health=max(0,health-whole)
		damage_buffer-=whole

func _primary_action():
	if player==null or camera==null: return
	if build_mode:
		_update_build_preview()
		if preview_valid: _build_house()
		else: _flash_message("BU PARCA BURAYA KURULAMAZ")
		return
	if selected_tool=="SILAH":
		_shoot(); return
	var space=get_world_3d().direct_space_state
	var from=camera.global_position; var to=from+(-camera.global_transform.basis.z)*4.2
	var q=PhysicsRayQueryParameters3D.create(from,to); q.exclude=[player]
	var hit=space.intersect_ray(q)
	if hit.is_empty(): return
	var obj=hit.get("collider")
	if obj==null or not obj.has_meta("loot"): return
	var kind=str(obj.get_meta("loot"))
	if selected_tool=="TAS BALTA" and kind=="wood":
		var id=obj.get_instance_id(); var count=int(tree_hits.get(id,0))+1; tree_hits[id]=count; _play_sfx("chop"); _gather_particles(); _flash_message("AGAC %d / 4" % count)
		if count>=4:
			wood+=35; tree_hits.erase(id); _schedule_resource_respawn(obj,"wood"); _fell_tree(obj)
	elif selected_tool=="TAS KAZMA" and kind in ["stone","meteor"]:
		var id=obj.get_instance_id(); var needed=8 if kind=="meteor" else 4; var count=int(rock_hits.get(id,0))+1; rock_hits[id]=count; _play_sfx("chop"); _gather_particles()
		_flash_message(("%s %d / %d" % [("METEOR" if kind=="meteor" else "TAS"),count,needed]))
		if count>=needed:
			rock_hits.erase(id); _schedule_resource_respawn(obj,kind)
			if kind=="meteor": metal_parts+=20; _flash_message("METAL PARCALARI +20")
			else: stone+=20
			_break_rock(obj)

func _shoot():
	if ammo <= 0: return
	ammo -= 1
	var target: CharacterBody3D; var best := 18.0
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
	var fire_light=OmniLight3D.new(); fire_light.position=cp+Vector3(0,1.0,0); fire_light.light_color=Color(1,.55,.2); fire_light.light_energy=2.2; fire_light.omni_range=8; add_child(fire_light)

func _house_asset(key:String,p:Vector3,yaw:float,size:Vector3)->Node3D:
	var body=StaticBody3D.new(); body.position=p; body.rotation_degrees.y=yaw; add_child(body)
	var visual=_load_asset(asset_paths[key])
	if visual!=null: body.add_child(visual)
	else:
		var mi=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=size; mi.mesh=bm; mi.position.y=size.y*.5; mi.material_override=_simple_mat(Color(.42,.23,.08)); body.add_child(mi)
	var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=size; cs.shape=sh; cs.position.y=size.y*.5; body.add_child(cs)
	body.set_meta("build_piece",build_piece_names[build_piece]); body.set_meta("structure_hp",structure_hp_default); body.set_meta("material","wood")
	return body

func _add_house_light(roof_pos:Vector3):
	var light=OmniLight3D.new(); light.position=roof_pos+Vector3(0,-1.35,0); light.light_color=Color(1.0,.88,.68); light.light_energy=.85; light.omni_range=7.0; light.shadow_enabled=false; add_child(light)

func _build_house():
	if not build_mode:
		build_mode=true; _ensure_build_preview(); return
	_update_build_preview()
	if not preview_valid: _flash_message("BU PARCA BURAYA KURULAMAZ"); return
	if wood<20: return
	var p=build_preview.global_position
	var yaw=build_preview.rotation_degrees.y
	wood-=20
	var made: Node3D
	match build_piece:
		0:
			made=_build_foundation(p); built_floors.append(made)
		1:
			made=_build_wall_panel(p,yaw); built_walls.append(made)
		2:
			made=_build_door_frame(p,yaw); built_walls.append(made)
		3:
			made=_build_window_frame(p,yaw); built_walls.append(made)
		4:
			made=_build_roof_panel(p,yaw); built_roofs.append(made); _add_house_light(p)
		5:
			made=_build_stairs(p,yaw,stair_rise); built_stairs.append(made)
		8: _build_interior_prop(p,build_piece,yaw+180.0)
		_: _build_interior_prop(p,build_piece,yaw)
	house_parts+=1
	if gather_label: gather_label.text=build_piece_names[build_piece]+" KURULDU"; gather_label.visible=true; message_time=1.0

func _cycle_build_piece():
	build_piece=(build_piece+1)%build_piece_names.size()
	if hotbar_label: hotbar_label.text="YAPI: "+build_piece_names[build_piece]
	if build_mode: _update_preview_shape()

func _update_preview_shape():
	if build_preview==null: return
	if build_piece==5:
		# Show the real stair silhouette in preview instead of a triangular wedge.
		var steps:=6
		var st=ArrayMesh.new()
		var arrays=[]
		arrays.resize(Mesh.ARRAY_MAX)
		var verts=PackedVector3Array()
		var inds=PackedInt32Array()
		var run=5.0
		var depth=run/float(steps)
		for i in steps:
			var t=float(i)/float(steps-1)
			var y=3.0*t
			var z0=-run*.5+depth*float(i)
			var z1=z0+depth
			var x0=-2.68; var x1=2.68
			var base=verts.size()
			verts.append_array(PackedVector3Array([
				Vector3(x0,y,z0),Vector3(x1,y,z0),Vector3(x1,y,z1),Vector3(x0,y,z1)
			]))
			inds.append_array(PackedInt32Array([base,base+1,base+2,base,base+2,base+3]))
		arrays[Mesh.ARRAY_VERTEX]=verts
		arrays[Mesh.ARRAY_INDEX]=inds
		st.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		build_preview.mesh=st
	else:
		var box=BoxMesh.new()
		var sizes=[Vector3(5,.45,5),Vector3(5.3,3,.3),Vector3(5.3,3,.3),Vector3(5.3,3,.3),Vector3(5,.35,5),Vector3(3,3,5)]
		box.size=sizes[build_piece]; build_preview.mesh=box

func _build_boat():
	if boat_built or wood < 40: return
	wood -= 40; boat_built = true
	var bp=Vector3(player.position.x,0.12,-192)
	var bc=asset_corrections["boat"]
	var boat=_place_asset(asset_paths["boat"],self,bp,bc["scale"],bc["rot"])
	if boat!=null: boat.name="PlayerBoat"
	else: _add_static_box(bp,Vector3(3,.6,6),Color(.35,.16,.05))

func _minimap_input(event):
	if event is InputEventScreenTouch and event.pressed:
		_toggle_map()

func _toggle_map():
	if map_panel == null: _create_map()
	map_panel.visible = not map_panel.visible

func _create_map():
	map_panel=Control.new(); map_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg=ColorRect.new(); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); bg.color=Color(.055,.07,.055,.985); bg.mouse_filter=Control.MOUSE_FILTER_STOP; bg.gui_input.connect(_map_input); map_panel.add_child(bg)
	var title=Label.new(); title.text="KARA KIYI  •  HEDEF NOKTASINI SEÇ"; title.set_anchors_preset(Control.PRESET_TOP_WIDE); title.position=Vector2(0,18); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; title.add_theme_font_size_override("font_size",26); map_panel.add_child(title)
	for bdata in pois:
		var l=Label.new(); l.text="• "+bdata.name
		l.position=Vector2(70+(bdata.pos.x+MAP_HALF)/(MAP_HALF*2.0)*1140.0,65+(bdata.pos.z+MAP_HALF)/(MAP_HALF*2.0)*570.0); l.add_theme_font_size_override("font_size",15); map_panel.add_child(l)
	map_dot=Label.new(); map_dot.text="▲ SEN"; map_dot.add_theme_font_size_override("font_size",18); map_panel.add_child(map_dot)
	map_waypoint=Label.new(); map_waypoint.text="◎ HEDEF"; map_waypoint.add_theme_font_size_override("font_size",18); map_waypoint.visible=waypoint_active; map_panel.add_child(map_waypoint)
	map_hint=Label.new(); map_hint.text="Haritada bir noktaya dokun. Hedef kaydedilir ve oyun ekranına dönülür."; map_hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE); map_hint.position=Vector2(0,-42); map_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; map_panel.add_child(map_hint)
	var close=Button.new(); close.text="✕"; close.set_anchors_preset(Control.PRESET_TOP_RIGHT); close.position=Vector2(-70,18); close.size=Vector2(52,52); close.pressed.connect(_toggle_map); map_panel.add_child(close)
	var layers=get_children().filter(func(n): return n is CanvasLayer)
	if layers.size()>0: layers[-1].add_child(map_panel)
	map_panel.visible=false
	_update_map_dot()

func _map_input(event):
	if not (event is InputEventScreenTouch) or not event.pressed: return
	var p=event.position
	if p.x<70 or p.x>1210 or p.y<65 or p.y>635: return
	var nx=clampf((p.x-70.0)/1140.0,0.0,1.0); var nz=clampf((p.y-65.0)/570.0,0.0,1.0)
	waypoint_pos=Vector3(nx*MAP_HALF*2.0-MAP_HALF,0,nz*MAP_HALF*2.0-MAP_HALF)
	waypoint_active=true
	if map_waypoint: map_waypoint.visible=true; map_waypoint.position=Vector2(70+nx*1140.0,65+nz*570.0)
	_update_navigation_ui()
	map_panel.visible=false

func _update_map_dot():
	if map_dot==null or player==null: return
	var nx=clampf((player.position.x+MAP_HALF)/(MAP_HALF*2.0),0.0,1.0); var nz=clampf((player.position.z+MAP_HALF)/(MAP_HALF*2.0),0.0,1.0)
	map_dot.position=Vector2(70+nx*1140.0,65+nz*570.0)
	map_dot.rotation=atan2(player_facing.x,-player_facing.z)
	if waypoint_active and map_waypoint:
		var wx=clampf((waypoint_pos.x+MAP_HALF)/(MAP_HALF*2.0),0.0,1.0); var wz=clampf((waypoint_pos.z+MAP_HALF)/(MAP_HALF*2.0),0.0,1.0)
		map_waypoint.position=Vector2(70+wx*1140.0,65+wz*570.0)

func _respawn():
	wood /= 2; stone /= 2; grass_n /= 2; wheat_n /= 2; mushroom_n /= 2
	health=100; hunger=70.0; thirst=80.0; damage_buffer=0.0; player.velocity=Vector3.ZERO; player.position=Vector3(0,PLAYER_HEIGHT,0)
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

func _landmark_cyl(p:Vector3, r_bot:float, r_top:float, h:float, col:Color):
	var mi=MeshInstance3D.new(); var cyl=CylinderMesh.new(); cyl.bottom_radius=r_bot; cyl.top_radius=r_top; cyl.height=h; mi.mesh=cyl; mi.position=p; mi.material_override=_simple_mat(col); add_child(mi)

func _build_survival_poi(b):
	var c:Vector3=b.pos; var col:Color=b.color; var id:String=b.id
	# Distinct abandoned survival silhouettes. No historical landmark or boss-fort geometry.
	if id=="unfinished_house":
		_landmark_box(c+Vector3(0,.25,0),Vector3(12,.5,10),Color(.32,.29,.25))
		for p in [Vector3(-5,2.5,-4.5),Vector3(5,2.5,-4.5),Vector3(-5,2.5,4.5),Vector3(5,2.5,4.5)]: _landmark_box(c+p,Vector3(.55,5,.55),col)
		_landmark_box(c+Vector3(-3.5,4.7,0),Vector3(5,.35,9),Color(.26,.22,.18),Vector3(0,0,-8))
	elif id=="watchtower":
		for x in [-3.0,3.0]:
			for z in [-3.0,3.0]: _landmark_box(c+Vector3(x,4.5,z),Vector3(.45,9,.45),col)
		_landmark_box(c+Vector3(0,8.7,0),Vector3(8,.45,8),col)
		_landmark_box(c+Vector3(0,10.2,0),Vector3(5.5,2.6,5.5),Color(.25,.24,.21))
		_landmark_box(c+Vector3(0,11.8,0),Vector3(7,.25,7),Color(.18,.18,.17))
	elif id=="plane_wreck":
		_landmark_box(c+Vector3(0,1,0),Vector3(15,2.1,3.2),col,Vector3(0,24,7))
		_landmark_box(c+Vector3(-1,.9,0),Vector3(5,.25,19),Color(.27,.29,.29),Vector3(0,24,7))
		_landmark_box(c+Vector3(6,.8,1),Vector3(5,1.2,2.5),Color(.22,.23,.23),Vector3(0,38,18))
	elif id=="tank_site":
		_landmark_box(c+Vector3(0,.8,0),Vector3(7,1.6,10),Color(.24,.29,.21))
		_landmark_box(c+Vector3(0,2,0),Vector3(4.2,1.3,4.4),col)
		_landmark_box(c+Vector3(0,2.2,-6),Vector3(.5,.5,9),Color(.18,.21,.17))
		for x in [-3.7,3.7]: _landmark_box(c+Vector3(x,.65,0),Vector3(.65,1.3,10.5),Color(.12,.13,.11))
	elif id=="factory":
		_landmark_box(c+Vector3(0,3,0),Vector3(19,6,13),col)
		_landmark_box(c+Vector3(-5,6.6,0),Vector3(7,.3,13),Color(.20,.20,.19),Vector3(0,0,8))
		_landmark_cyl(c+Vector3(6,9,3),1.25,1.0,12,Color(.22,.21,.20))
		_landmark_cyl(c+Vector3(2,7,-4),.8,.7,8,Color(.30,.23,.18))
	elif id=="junkyard":
		for i in 9:
			var x=float(i%3)*5.0-5.0; var z=float(i/3)*5.5-5.5
			_landmark_box(c+Vector3(x,.65,z),Vector3(3.6,1.3,5.2),Color(.30,.22,.17),Vector3(0,i*17,0))
		for x in [-8.0,8.0]: _landmark_box(c+Vector3(x,1.4,0),Vector3(.3,2.8,18),Color(.20,.19,.17))
	elif id=="military_post":
		_landmark_box(c+Vector3(0,1.5,0),Vector3(12,3,8),Color(.25,.29,.22))
		_landmark_box(c+Vector3(-7,1,-5),Vector3(5,2,3.5),col)
		for x in [-8.0,8.0]: _landmark_box(c+Vector3(x,.9,3),Vector3(.8,1.8,13),Color(.35,.33,.27))
		_landmark_box(c+Vector3(0,.8,9),Vector3(17,1.6,.7),Color(.35,.33,.27))
	elif id=="bunker":
		_landmark_box(c+Vector3(0,.45,0),Vector3(15,.9,11),Color(.29,.30,.29))
		_landmark_box(c+Vector3(0,1.2,-4.5),Vector3(5,2.4,1),Color(.15,.16,.15))
		_landmark_box(c+Vector3(-2.7,1.2,-2.5),Vector3(.5,2.4,5),col)
		_landmark_box(c+Vector3(2.7,1.2,-2.5),Vector3(.5,2.4,5),col)
	elif id=="gas_station":
		_landmark_box(c+Vector3(4,2.2,3),Vector3(10,4.4,8),Color(.34,.29,.23))
		_landmark_box(c+Vector3(-3,3,-4),Vector3(15,.35,7),Color(.31,.28,.24))
		for x in [-6.0,0.0]: _landmark_box(c+Vector3(x,1,-4),Vector3(.8,2,.8),Color(.25,.18,.14))
		for x in [-6.0,0.0]: _landmark_box(c+Vector3(x,.8,-4),Vector3(1.5,1.6,.8),Color(.37,.22,.15))
	elif id=="shipyard":
		_landmark_box(c+Vector3(0,.35,0),Vector3(20,.7,13),Color(.28,.25,.21))
		_landmark_box(c+Vector3(-6,2,0),Vector3(5,4,8),col)
		_landmark_box(c+Vector3(5,1.5,1),Vector3(7,3,4),Color(.30,.23,.18))
		for x in [-8.0,-3.0,2.0,7.0]: _landmark_box(c+Vector3(x,-.1,-8),Vector3(.6,1.8,7),Color(.24,.19,.14))

func _simple_mat(c:Color)->StandardMaterial3D:
	var m=StandardMaterial3D.new(); m.albedo_color=c; m.roughness=.75; return m


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
	# Check the actual placed structure nodes instead of one old build_origin point.
	for n in get_children():
		if not (n is Node3D) or not is_instance_valid(n): continue
		if not n.has_meta("build_piece"): continue
		var q:Vector3=n.global_position
		if Vector2(p.x-q.x,p.z-q.z).length()<3.6: return true
	if fire_built and Vector2(p.x-campfire_pos.x,p.z-campfire_pos.z).length()<3.0: return true
	return false

func _spawn_resource_at(kind:String,p:Vector3):
	if kind not in ["wood","stone","meteor"]: return
	p.y=height_at(p.x,p.z)
	if kind=="wood":
		var body=StaticBody3D.new(); body.position=p; body.rotation_degrees.y=randf_range(0,360); add_child(body); _make_kara_tree(body)
		var cs=CollisionShape3D.new(); var sh=CylinderShape3D.new(); sh.radius=.34; sh.height=5.2; cs.shape=sh; cs.position.y=2.6; body.add_child(cs); body.set_meta("loot","wood")
	else:
		var body=StaticBody3D.new(); body.position=p; add_child(body)
		if kind=="meteor": _make_meteor(body)
		else: _make_kara_rock(body)
		var cs=CollisionShape3D.new(); var sh=SphereShape3D.new(); sh.radius=.68; cs.shape=sh; cs.position.y=.5; body.add_child(cs); body.set_meta("loot",kind)

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
		wood=max(wood,9999); stone=max(stone,9999); grass_n=max(grass_n,9999); wheat_n=max(wheat_n,9999); mushroom_n=max(mushroom_n,9999); reserve_ammo=max(reserve_ammo,9999)
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
	hotbar=HBoxContainer.new(); hotbar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); hotbar.position=Vector2(-490,-88); hotbar.size=Vector2(980,78); hotbar.alignment=BoxContainer.ALIGNMENT_CENTER
	var slots=[["EL",0],["🪓",1],["⛏",2],["▰",3],["🔨",4],["",5],["",6]]
	for slot in slots:
		var b=Button.new(); b.text=slot[0]; b.custom_minimum_size=Vector2(138,75); b.add_theme_font_size_override("font_size",28)
		var st=StyleBoxFlat.new(); st.bg_color=Color(.08,.08,.08,.30); st.border_width_left=1; st.border_width_top=1; st.border_width_right=1; st.border_width_bottom=1; st.border_color=Color(.8,.8,.8,.35)
		b.add_theme_stylebox_override("normal",st); b.add_theme_stylebox_override("pressed",st)
		if int(slot[1])<=4: b.pressed.connect(_select_hotbar.bind(int(slot[1])))
		hotbar.add_child(b)
	layer.add_child(hotbar)
	hotbar_label=Label.new(); hotbar_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); hotbar_label.position=Vector2(-180,-118); hotbar_label.size=Vector2(360,28); hotbar_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; hotbar_label.text="ELLER"; layer.add_child(hotbar_label)

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

func _nearest_floor(max_dist:=9.0) -> Node3D:
	var best: Node3D; var best_d: float = float(max_dist)
	for f in built_floors:
		if not is_instance_valid(f): continue
		var d=player.global_position.distance_to(f.global_position)
		if d<best_d: best_d=d; best=f
	return best

func _nearest_build_surface(point:Vector3,max_dist:=8.0) -> Node3D:
	var best:Node3D
	var best_d=float(max_dist)
	for n in built_floors + built_roofs:
		if not is_instance_valid(n): continue
		var d=Vector2(point.x-n.global_position.x,point.z-n.global_position.z).length()
		if d<best_d:
			best_d=d; best=n
	return best

func _edge_slot_free(p:Vector3,yaw:float)->bool:
	for w in built_walls:
		if not is_instance_valid(w): continue
		if absf(w.global_position.y-p.y)>.25: continue
		if Vector2(w.global_position.x-p.x,w.global_position.z-p.z).length()>.35: continue
		var a=fposmod(w.rotation_degrees.y,180.0)
		var b=fposmod(yaw,180.0)
		if absf(a-b)<1.0 or absf(absf(a-b)-180.0)<1.0:
			return false
	return true

func _surface_has_roof_above(surface:Node3D)->bool:
	if surface==null: return false
	var expected_y=surface.global_position.y+(.225 if surface in built_floors else .09)+3.0
	for r in built_roofs:
		if not is_instance_valid(r): continue
		if Vector2(r.global_position.x-surface.global_position.x,r.global_position.z-surface.global_position.z).length()<.35 and absf(r.global_position.y-expected_y)<.35:
			return true
	return false

func _stair_below_roof(p:Vector3)->Node3D:
	for s in built_stairs:
		if not is_instance_valid(s): continue
		var high=s.global_transform*Vector3(0,0,2.5)
		if Vector2(high.x-p.x,high.z-p.z).length()<2.65 and absf(high.y-p.y)<.45:
			return s
	return null

func _update_build_preview():
	if not build_mode or build_preview==null or player==null: return
	preview_valid=false
	var forward=-player.global_transform.basis.z; forward.y=0.0; forward=forward.normalized()
	var probe=player.global_position+forward*5.0
	var floor=_nearest_floor(12.0)
	if build_piece==5:
		var surface=_nearest_build_surface(probe,6.0)
		if surface:
			# Once a ceiling/floor exists above this tile, stairs belong to the new storey.
			if _surface_has_roof_above(surface):
				build_preview.global_position=probe
				var mat_locked=build_preview.material_override as StandardMaterial3D
				if mat_locked: mat_locked.albedo_color=Color(.95,.12,.08,.40)
				return
			# On a foundation/roof, the low end starts on the surface and the high end reaches
			# exactly one wall height above it. The high end is aimed toward the selected edge.
			stair_mode="storey"; stair_rise=3.0
			var delta=probe-surface.global_position
			var side=Vector3.ZERO; var yaw=0.0
			if absf(delta.x)>absf(delta.z):
				side=Vector3(1.0 if delta.x>=0.0 else -1.0,0,0)
				yaw=90.0 if side.x>0.0 else -90.0
			else:
				side=Vector3(0,0,1.0 if delta.z>=0.0 else -1.0)
				yaw=0.0 if side.z>0.0 else 180.0
			# Local +Z is the high end. Centering on the tile puts that end on its wall edge.
			var p=surface.global_position
			p.y=surface.global_position.y+(.225 if surface in built_floors else .09)
			build_preview.global_position=p; build_preview.rotation_degrees.y=yaw; preview_valid=true
		else:
			# Bedrock placement is only useful when the stair can terminate on a foundation.
			var target=_nearest_floor(10.0)
			if target:
				stair_mode="terrain"
				var to_target=target.global_position-probe
				var side=Vector3.ZERO; var yaw=0.0
				if absf(to_target.x)>absf(to_target.z):
					side=Vector3(1.0 if to_target.x>0.0 else -1.0,0,0)
					yaw=90.0 if side.x>0.0 else -90.0
				else:
					side=Vector3(0,0,1.0 if to_target.z>0.0 else -1.0)
					yaw=0.0 if side.z>0.0 else 180.0
				# High end is locked to the foundation edge/top. Any excess low-end length
				# is allowed below bedrock, hiding it instead of leaving floating geometry.
				var high=target.global_position-side*2.5
				var high_y=target.global_position.y+.225
				var low_sample=high-side*5.0
				var rock_y=height_at(low_sample.x,low_sample.z)
				stair_rise=maxf(.20,high_y-rock_y)
				var center=high-side*2.5
				center.y=high_y-stair_rise
				build_preview.global_position=center; build_preview.rotation_degrees.y=yaw; preview_valid=true
			else:
				build_preview.global_position=probe
	elif build_piece==0:
		# Foundations remain ground-floor pieces only. Roofs are upper-floor build surfaces, not foundations.
		var p=probe
		if floor:
			var delta=probe-floor.global_position
			if absf(delta.x)>absf(delta.z):
				p=floor.global_position+Vector3(5.0*(1.0 if delta.x>=0.0 else -1.0),0,0)
			else:
				p=floor.global_position+Vector3(0,0,5.0*(1.0 if delta.z>=0.0 else -1.0))
			p.y=floor.global_position.y
		else:
			p.x=roundf(p.x/5.0)*5.0; p.z=roundf(p.z/5.0)*5.0
			p.y=_foundation_top_y(p.x,p.z)
		build_preview.global_position=p; build_preview.rotation_degrees.y=0; preview_valid=true
	else:
		var surface=_nearest_build_surface(probe,7.0)
		if surface:
			var delta=probe-surface.global_position
			var p=surface.global_position; var yaw=0.0
			if absf(delta.x)>absf(delta.z):
				p.x+=2.5*(1.0 if delta.x>=0.0 else -1.0); yaw=90.0
			else:
				p.z+=2.5*(1.0 if delta.z>=0.0 else -1.0); yaw=0.0
			var base_y=surface.global_position.y+(.225 if surface in built_floors else .09)
			if build_piece in [1,2,3]:
				p.y=base_y
				preview_valid=_edge_slot_free(p,yaw)
			elif build_piece==4:
				p=surface.global_position+Vector3(0,(.225 if surface in built_floors else .09)+3.0,0)
				yaw=0.0
				# One roof per level/tile. This roof becomes the next build surface.
				preview_valid=true
				for r in built_roofs:
					if is_instance_valid(r) and r.global_position.distance_to(p)<.35:
						preview_valid=false; break
			build_preview.global_position=p; build_preview.rotation_degrees.y=yaw
		else:
			build_preview.global_position=probe
	var mat=build_preview.material_override as StandardMaterial3D
	if mat: mat.albedo_color=Color(.2,.9,.35,.42) if preview_valid else Color(.95,.12,.08,.40)


func _foundation_top_y(x:float,z:float)->float:
	var corners=[Vector2(-2.5,-2.5),Vector2(2.5,-2.5),Vector2(-2.5,2.5),Vector2(2.5,2.5)]
	var top=-INF
	for off in corners: top=maxf(top,height_at(x+off.x,z+off.y))
	return top+.35

func _build_foundation(p:Vector3)->Node3D:
	var root=StaticBody3D.new(); root.position=p; root.set_meta("build_piece","TEMEL"); root.set_meta("structure_hp",structure_hp_default); add_child(root)
	var deck=MeshInstance3D.new(); var dm=BoxMesh.new(); dm.size=Vector3(5,.45,5); deck.mesh=dm; deck.material_override=_simple_mat(Color(.31,.20,.11)); root.add_child(deck)
	var dcs=CollisionShape3D.new(); var dsh=BoxShape3D.new(); dsh.size=Vector3(5,.45,5); dcs.shape=dsh; root.add_child(dcs)
	for off in [Vector2(-2.15,-2.15),Vector2(2.15,-2.15),Vector2(-2.15,2.15),Vector2(2.15,2.15)]:
		var gy=height_at(p.x+off.x,p.z+off.y)
		var deck_bottom=p.y-.225
		var leg_h=maxf(.35,deck_bottom-gy)
		var leg=MeshInstance3D.new(); var lm=BoxMesh.new(); lm.size=Vector3(.32,leg_h,.32); leg.mesh=lm
		# Leg top touches the underside of the deck; leg bottom reaches its own terrain sample.
		leg.position=Vector3(off.x,-.225-leg_h*.5,off.y); leg.material_override=_simple_mat(Color(.20,.14,.09)); root.add_child(leg)
	return root

func _build_stairs(p:Vector3,yaw:=0.0,rise:=3.0)->Node3D:
	var run=5.0
	var width=5.36
	var root=StaticBody3D.new(); root.position=p; root.rotation_degrees.y=yaw; add_child(root)
	var steps:=6
	var depth=run/float(steps)
	for i in steps:
		var t=float(i)/float(steps-1)
		var tread_h=.16
		var y=rise*t-tread_h*.5
		var z=-run*.5+depth*(float(i)+.5)
		var mi=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=Vector3(width,tread_h,depth+.08); mi.mesh=bm; mi.position=Vector3(0,y,z); mi.material_override=_simple_mat(Color(.42,.23,.08)); root.add_child(mi)
		var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=Vector3(width,tread_h,depth+.08); cs.shape=sh; cs.position=Vector3(0,y,z); root.add_child(cs)
	# Two slim wooden stringers visually support the treads without closing the underside.
	var angle=-atan2(rise,run)
	var length=sqrt(run*run+rise*rise)
	for x in [-2.35,2.35]:
		var rail=MeshInstance3D.new(); var rm=BoxMesh.new(); rm.size=Vector3(.18,.18,length); rail.mesh=rm
		rail.position=Vector3(x,rise*.5,0); rail.rotation.x=angle; rail.material_override=_simple_mat(Color(.30,.17,.07)); root.add_child(rail)
	root.set_meta("build_piece","MERDIVEN"); root.set_meta("structure_hp",structure_hp_default); root.set_meta("material","wood")
	return root
func _build_wall_panel(p:Vector3,yaw:=0.0)->Node3D:
	var root=StaticBody3D.new(); root.position=p; root.rotation_degrees.y=yaw; add_child(root)
	var mi=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=Vector3(5.36,3.0,.22); mi.mesh=bm; mi.position=Vector3(0,1.5,0); mi.material_override=_simple_mat(Color(.42,.23,.08)); root.add_child(mi)
	var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=Vector3(5.36,3.0,.22); cs.shape=sh; cs.position=Vector3(0,1.5,0); root.add_child(cs)
	root.set_meta("build_piece","DUVAR"); root.set_meta("structure_hp",structure_hp_default); root.set_meta("material","wood")
	return root

func _add_frame_box(root:Node3D,size:Vector3,pos:Vector3):
	var mi=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=size; mi.mesh=bm; mi.position=pos; mi.material_override=_simple_mat(Color(.42,.23,.08)); root.add_child(mi)
	var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=size; cs.shape=sh; cs.position=pos; root.add_child(cs)

func _build_door_frame(p:Vector3,yaw:=0.0)->Node3D:
	var root=StaticBody3D.new(); root.position=p; root.rotation_degrees.y=yaw; add_child(root)
	var opening=1.65
	var side=(5.36-opening)*.5
	_add_frame_box(root,Vector3(side,3.0,.22),Vector3(-(opening+side)*.5,1.5,0))
	_add_frame_box(root,Vector3(side,3.0,.22),Vector3((opening+side)*.5,1.5,0))
	_add_frame_box(root,Vector3(opening,.72,.22),Vector3(0,2.64,0))
	root.set_meta("build_piece","KAPI"); root.set_meta("structure_hp",structure_hp_default); root.set_meta("material","wood")
	return root

func _build_window_frame(p:Vector3,yaw:=0.0)->Node3D:
	var root=StaticBody3D.new(); root.position=p; root.rotation_degrees.y=yaw; add_child(root)
	var opening_w=2.0; var side=(5.36-opening_w)*.5
	_add_frame_box(root,Vector3(side,3.0,.22),Vector3(-(opening_w+side)*.5,1.5,0))
	_add_frame_box(root,Vector3(side,3.0,.22),Vector3((opening_w+side)*.5,1.5,0))
	_add_frame_box(root,Vector3(opening_w,.85,.22),Vector3(0,.425,0))
	_add_frame_box(root,Vector3(opening_w,.70,.22),Vector3(0,2.65,0))
	root.set_meta("build_piece","PENCERE"); root.set_meta("structure_hp",structure_hp_default); root.set_meta("material","wood")
	return root

func _build_roof_panel(p:Vector3,yaw:=0.0)->Node3D:
	var root=StaticBody3D.new(); root.position=p; root.rotation_degrees.y=yaw; add_child(root)
	var stair=_stair_below_roof(p)
	if stair:
		# Stair landing gets a half-floor opening so the player can emerge onto the next storey.
		var local_dir=stair.global_transform.basis.z.normalized()
		var along_x=absf(local_dir.x)>absf(local_dir.z)
		if along_x:
			var sx=1.0 if local_dir.x>0.0 else -1.0
			_add_frame_box(root,Vector3(2.54,.18,5.08),Vector3(-sx*1.27,0,0))
		else:
			var sz=1.0 if local_dir.z>0.0 else -1.0
			_add_frame_box(root,Vector3(5.08,.18,2.54),Vector3(0,0,-sz*1.27))
	else:
		_add_frame_box(root,Vector3(5.08,.18,5.08),Vector3.ZERO)
	root.set_meta("build_piece","TAVAN"); root.set_meta("structure_hp",structure_hp_default); root.set_meta("material","wood")
	return root
func _build_interior_prop(p:Vector3,kind:int,yaw:=0.0):
	var obj:Node3D
	if kind==6:
		obj=_house_asset("house_chest",p,yaw,Vector3(1.5,1,1)); obj.set_meta("interior","chest")
	elif kind==7:
		obj=_house_asset("house_bed",p,yaw,Vector3(1.2,.44,2.2)); obj.set_meta("interior","bed"); bed_spawn=p+Vector3(0,1,1.5); has_bed_spawn=true; _update_bed_minimap()
	elif kind==8:
		obj=_house_asset("house_workbench",p,yaw,Vector3(2.2,1.1,.8)); obj.set_meta("interior","workbench")
	elif kind==9:
		obj=_house_asset("house_stove",p,yaw,Vector3(1.2,1,1.2)); obj.set_meta("interior","stove")
		var glow=OmniLight3D.new(); glow.position=p+Vector3(0,1.3,0); glow.light_color=Color(1,.48,.16); glow.light_energy=1.4; glow.omni_range=7; add_child(glow)
	elif kind==10:
		obj=_house_asset("house_lamp",p,yaw,Vector3(.35,1.5,.35)); obj.set_meta("interior","lamp")
		var lamp=OmniLight3D.new(); lamp.position=p+Vector3(0,1.7,0); lamp.light_color=Color(1,.72,.38); lamp.light_energy=1.1; lamp.omni_range=8; add_child(lamp)
	if obj!=null: obj.add_to_group("interior_interactable")

func _use_nearest_interior():
	var best: Node3D; var dist=3.0
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
		chest_storage["wood"]+=wood; chest_storage["stone"]+=stone; chest_storage["grass_n"]+=grass_n; chest_storage["wheat_n"]+=wheat_n; chest_storage["mushroom"]+=mushroom_n
		wood=0; stone=0; grass_n=0; wheat_n=0; mushroom_n=0; _flash_message("KAYNAKLAR SANDIGA KONDU")
	else:
		wood=chest_storage["wood"]; stone=chest_storage["stone"]; grass_n=chest_storage["grass_n"]; wheat_n=chest_storage["wheat_n"]; mushroom_n=chest_storage["mushroom"]
		chest_storage={"wood":0,"stone":0,"grass_n":0,"wheat_n":0,"mushroom":0}; _flash_message("SANDIK BOSALTILDI")
	_refresh_inventory()

func _flash_message(t:String):
	if gather_label: gather_label.text=t; gather_label.visible=true; message_time=1.5


func _create_minimap(layer:CanvasLayer):
	minimap_panel=Panel.new(); minimap_panel.position=Vector2(16,16); minimap_panel.size=Vector2(150,150)
	var bg=ColorRect.new(); bg.position=Vector2(5,5); bg.size=Vector2(140,140); bg.color=Color(.08,.14,.09,.82); minimap_panel.add_child(bg)
	# Cardinal hints keep orientation readable on a small mobile screen.
	for item in [["K",Vector2(70,4)],["G",Vector2(70,130)],["B",Vector2(4,68)],["D",Vector2(132,68)]]:
		var l=Label.new(); l.text=item[0]; l.position=item[1]; minimap_panel.add_child(l)
	minimap_dot=ColorRect.new(); minimap_dot.size=Vector2(8,8); minimap_dot.color=Color(1,.82,.12,1); minimap_panel.add_child(minimap_dot)
	minimap_dir=Label.new(); minimap_dir.text="▲"; minimap_dir.size=Vector2(18,18); minimap_panel.add_child(minimap_dir)
	_add_minimap_landmarks()
	minimap_panel.mouse_filter=Control.MOUSE_FILTER_STOP; minimap_panel.gui_input.connect(_minimap_input)
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
	# Legacy white crosshair and moving aim dot removed. The red + from _build_hud is the only reticle.
	crosshair=null; aim_marker=null
	scope_overlay=Control.new(); scope_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); scope_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var ring=Label.new(); ring.text="◯"; ring.add_theme_font_size_override("font_size",420); ring.set_anchors_preset(Control.PRESET_CENTER); ring.position=Vector2(-135,-270); scope_overlay.add_child(ring)
	scope_overlay.visible=false; layer.add_child(scope_overlay)
	hit_marker=Label.new(); hit_marker.text="×"; hit_marker.add_theme_font_size_override("font_size",38); hit_marker.set_anchors_preset(Control.PRESET_CENTER); hit_marker.position=Vector2(-12,-24); hit_marker.visible=false; hit_marker.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(hit_marker)

func _toggle_scope():
	if not has_scope: return
	scope_stage=(scope_stage+1)%3
	scoped=scope_stage>0
	if camera:
		if scope_stage==1: camera.fov=48.0
		elif scope_stage==2: camera.fov=30.0
		else: camera.fov=72.0
	if scope_overlay: scope_overlay.visible=scoped

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
	if camera: camera.rotation_degrees.x=look_pitch-recoil
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
	held_item=Node3D.new(); held_item.name="HeldItem"; camera.add_child(held_item)
	held_item.position=Vector3(.38,-.30,-.72)
	if slot==0: held_item.visible=false; return
	var paths={1:"res://assets/items/tools/stone_axe.glb",2:"res://assets/items/tools/stone_pickaxe.glb",3:"res://assets/items/weapons/scrap_rifle.glb",4:"res://assets/items/tools/building_hammer.glb"}
	var visual=_load_asset(str(paths.get(slot,"")))
	if visual!=null:
		visual.scale=Vector3(.9,.9,.9)
		if slot in [1,4]: visual.rotation_degrees.z=180.0
		held_item.add_child(visual); return
	var wood_mat=StandardMaterial3D.new(); wood_mat.albedo_color=Color(.30,.16,.06)
	var metal_mat=StandardMaterial3D.new(); metal_mat.albedo_color=Color(.30,.33,.36)
	if slot==1:
		_add_held_box(Vector3(.12,.8,.12),Vector3(0,-.05,0),wood_mat); _add_held_box(Vector3(.75,.18,.18),Vector3(0,.34,0),metal_mat)
	elif slot==2:
		_add_held_box(Vector3(.12,.9,.12),Vector3(0,-.05,0),wood_mat); _add_held_box(Vector3(.95,.14,.16),Vector3(0,.4,0),metal_mat)
	elif slot==3:
		_add_held_box(Vector3(.18,.18,.85),Vector3(0,0,-.18),metal_mat); _add_held_box(Vector3(.12,.35,.16),Vector3(0,-.22,.05),wood_mat)
	elif slot==4:
		_add_held_box(Vector3(.12,.82,.12),Vector3(0,-.05,0),wood_mat); _add_held_box(Vector3(.65,.28,.24),Vector3(0,.35,0),metal_mat)

func _add_held_box(sz:Vector3,pos:Vector3,mat:Material):
	var m=MeshInstance3D.new(); var b=BoxMesh.new(); b.size=sz; m.mesh=b; m.position=pos; m.material_override=mat; held_item.add_child(m)


func _create_survival_clock(layer:CanvasLayer):
	day_label=Label.new(); day_label.set_anchors_preset(Control.PRESET_TOP_RIGHT); day_label.position=Vector2(-245,12); day_label.size=Vector2(210,32); day_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT; day_label.text="09:00  ☀"; layer.add_child(day_label)

func _update_day_cycle(delta:float):
	day_clock=fmod(day_clock+delta*.035,24.0)
	var hour=int(floor(day_clock)); var minute=int(floor((day_clock-hour)*60.0))
	if day_label: day_label.text="%02d:%02d  %s" % [hour,minute,("☀" if hour>=6 and hour<19 else "☾")]
	var night=hour<6 or hour>=19
	var env:Environment=world_env.environment if world_env else null
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
	if player==null or fly_mode: return
	# Terrain is procedural rather than a physics floor, so allow jump when standing at
	# terrain height as well as on foundation/roof/stair collisions.
	var ground_y=height_at(player.position.x,player.position.z)+PLAYER_HEIGHT
	if player.is_on_floor() or absf(player.position.y-ground_y)<.12:
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
		wood=9999; stone=9999; grass_n=9999; wheat_n=9999; mushroom_n=9999; reserve_ammo=9999
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
		"OT +500": grass_n+=500
		"BUGDAY +200": wheat_n+=200
		"MANTAR +100": mushroom_n+=100
		"KAMP ATESI": _build_fire()
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
	rock.set_process(false)
	for child in rock.get_children():
		if child is VisualInstance3D: child.visible=false
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
	for child in part.get_children():
		if child is VisualInstance3D: child.visible=false
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
	return 9999 if cheat_mode else metal_parts


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


func _toggle_fly_mode():
	if player==null: return
	var ground=height_at(player.position.x,player.position.z)+PLAYER_HEIGHT
	if not fly_mode:
		fly_mode=true
		player.position.y=maxf(player.position.y,ground)+3.0
	else:
		player.position.y+=3.0
	fly_height=player.position.y
	_flash_message("UCUS: 1 KADEME YUKSELDI")

func _fly_down():
	if not fly_mode or player==null: return
	var ground=height_at(player.position.x,player.position.z)+PLAYER_HEIGHT
	player.position.y=maxf(ground,player.position.y-3.0)
	fly_height=player.position.y
	if player.position.y<=ground+.05:
		player.position.y=ground; fly_mode=false; _flash_message("ZEMINE INILDI")
	else: _flash_message("UCUS: 1 KADEME ALCALDI")

func _make_waypoint_arrow()->Node3D:
	var root=Node3D.new(); add_child(root)
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(1.0,.78,.08,.88); mat.emission_enabled=true; mat.emission=Color(.65,.35,.03); mat.emission_energy_multiplier=.65
	var shaft=MeshInstance3D.new(); var sb=BoxMesh.new(); sb.size=Vector3(.55,.05,2.2); shaft.mesh=sb; shaft.position=Vector3(0,.04,-.75); shaft.material_override=mat; root.add_child(shaft)
	var head=MeshInstance3D.new(); var hb=BoxMesh.new(); hb.size=Vector3(1.6,.05,1.0); head.mesh=hb; head.position=Vector3(0,.04,-1.9); head.rotation_degrees.y=45; head.material_override=mat; root.add_child(head)
	return root

func _ensure_waypoint_ground_arrow():
	if waypoint_ground_arrows.size()>0: return
	for i in 4: waypoint_ground_arrows.append(_make_waypoint_arrow())
	waypoint_ground_arrow=waypoint_ground_arrows[0]

func _update_waypoint_ground_arrow():
	_ensure_waypoint_ground_arrow()
	if not waypoint_active or player==null:
		for a in waypoint_ground_arrows: a.visible=false
		return
	var to=waypoint_pos-player.global_position; to.y=0.0
	var dist=to.length()
	if dist<3.0:
		waypoint_active=false
		for a in waypoint_ground_arrows: a.visible=false
		return
	var dir=to.normalized()
	for i in waypoint_ground_arrows.size():
		var a=waypoint_ground_arrows[i]; var d=minf(5.0+float(i)*6.0,dist-1.0)
		if d<=0.0: a.visible=false; continue
		var pos=player.global_position+dir*d; pos.y=height_at(pos.x,pos.z)+.07
		a.visible=true; a.global_position=pos; a.rotation.y=atan2(-dir.x,-dir.z)

func _update_navigation_ui():
	if player==null: return
	_update_waypoint_ground_arrow()
	var compass="↑"
	var ang=atan2(player_facing.x,-player_facing.z)
	if absf(ang)>PI*.75: compass="↓"
	elif ang>PI*.25: compass="→"
	elif ang<-PI*.25: compass="←"
	if facing_label: facing_label.text="%s  BAKIS" % compass
	if not waypoint_active:
		if waypoint_label: waypoint_label.text=("✈ UCUS" if fly_mode else "")
		if map_hint: map_hint.text="Haritaya dokunarak hedef sec"
		return
	var to=waypoint_pos-player.global_position; var dist=Vector2(to.x,to.z).length()
	var target_ang=atan2(to.x,-to.z); var rel=wrapf(target_ang-ang,-PI,PI)
	var arrow="↑"
	if absf(rel)>PI*.75: arrow="↓"
	elif rel>PI*.25: arrow="→"
	elif rel<-PI*.25: arrow="←"
	if waypoint_label: waypoint_label.text="%s HEDEF  %.0f m%s" % [arrow,dist,("  •  ✈" if fly_mode else "")]
	if map_hint: map_hint.text="HEDEF: %.0f m  •  %s" % [dist,arrow]
