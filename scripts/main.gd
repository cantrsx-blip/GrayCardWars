extends Node3D

const MAP_HALF := 200.0
const PLAYER_HEIGHT := 1.0
const POI_FLAT_RADIUS := 42.0

var gray_cards := 1
var ammo := 40
var enemies: Array[CharacterBody3D] = []
var fort_bosses: Array[CharacterBody3D] = []
var poi_boss_visuals: Array[Node3D] = []
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
var coordinate_label: Label
var message_time := 0.0
var respawn_label: Label
var gather_label: Label
var campfire_pos := Vector3.ZERO
var heal_buffer := 0.0
var inventory_panel: Control
var store_panel: Control
var craft_panel: Control
var hotbar: Control
var selected_tool := ""
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
var cheat_button: Button
var bears: Array[Node3D] = []
var wildlife: Array[Node3D] = []
var human_npcs: Array[Node3D] = []
var animal_ai_timer := 0.0
const ANIMAL_AI_INTERVAL := 0.20
var meteor_nodes: Array[Node3D] = []
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
var viewmodel_root: Node3D
var viewmodel_right_hand: Node3D
var viewmodel_left_hand: Node3D
var day_label: Label
var day_clock := 9.0
var crafting_flash_time := 0.0
var crafting_flash_button: Control
var sfx: Dictionary = {}
var step_timer := 0.0
var hotbar_label: Label
var hotbar_items: Array = ["","","","","","",""]
var hotbar_feedback_token := 0
var hotbar_hidden := false
var hotbar_hold_started: Dictionary = {}
var player_facing := Vector3(0,0,-1)
var player_move_speed := 6.8
var fly_mode := false
var fly_height := 0.0
var fly_button: Button
var fly_down_button: Button
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
var settlement_centers: Array[Vector3] = []
var active_settlement := -1
const SETTLEMENT_GRID := 5
const SETTLEMENT_CELL := 5.0
const SETTLEMENT_SIZE := 25.0
const MAX_BUILD_STOREYS := 4
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
# Full weapon/ammo/armor crafting inventory. Crafted entries use the same 128px shop icons.
var crafted_inventory: Dictionary = {}
var craft_resources: Dictionary = {
	"demir":0,"ip":0,"deri":0,"kulce_demir":0,"metal_boru":0,"celik":0,"celik_boru":0,"barut":0,
	"green_card":0,"blue_card":0,"orange_card":0,"red_card":0
}
var craft_category := "SİLAHLAR"

var pois := [
	{"id":"hospital","name":"Terk Edilmis Hastane","pos":Vector3(-130,0,130),"asset":"res://abandoned hospital 3d model.glb","size":24.0},
	{"id":"watchtower","name":"Gozetleme Kulesi","pos":Vector3(0,0,160),"asset":"res://rusted watchtower 3d model.glb","size":14.0},
	{"id":"plane_wreck","name":"Ucak Enkazi","pos":Vector3(140,0,130),"asset":"res://airplane wreckage 3d model.glb","size":22.0},
	{"id":"tank_site","name":"Terk Edilmis Tank","pos":Vector3(170,0,0),"asset":"res://battle tank 3d model.glb","size":9.0},
	{"id":"factory","name":"Terk Edilmis Fabrika","pos":Vector3(140,0,-130),"asset":"res://industrial ruin 3d model.glb","size":25.0},
	{"id":"junkyard","name":"Arac Hurdaligi","pos":Vector3(0,0,-160),"asset":"res://post-apocalyptic car junkyard 3d model.glb","size":24.0},
	{"id":"military_post","name":"Terk Edilmis Askeri Karakol","pos":Vector3(-130,0,-130),"asset":"res://ruined military base 3d model.glb","size":23.0},
	{"id":"bunker","name":"Yeralti Siginagi","pos":Vector3(-170,0,0),"asset":"res://bunker entrance 3d model.glb","size":16.0},
	{"id":"gas_station","name":"Terk Edilmis Benzin Istasyonu","pos":Vector3(-160,0,80),"asset":"res://rusted gas station 3d model.glb","size":22.0},
	{"id":"graveyard","name":"Yipranmis Mezarlik","pos":Vector3(160,0,80),"asset":"res://graveyard ruins 3d model.glb","size":22.0}
]

var pits := [
	Vector3(48, 0, -36),
	Vector3(-62, 0, 44),
	Vector3(88, 0, 72),
	Vector3(-90, 0, -70),
	Vector3(20, 0, 95),
	Vector3(-30, 0, -110)
]

func _process(_delta:float) -> void:
	pass

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
	# Build the ten boss/POI regions before heavy resource spawning so they are visible immediately on mobile.
	# Restore the ten heavyweight 3D boss/POI region models.
	await get_tree().process_frame
	_build_weather_system()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	# Animals remain removed.
	# Humans/NPCs removed from world spawning.
	# Grass pickups, wheat and mushrooms are removed. Tree code/assets are preserved but hidden for now.
	# Raiders and bosses intentionally disabled for the KARA KIYI rebuild.
	zone_label.text=""

func height_at(_x: float, _z: float) -> float:
	return 0.0

func _near_poi(x: float, z: float) -> bool:
	for b in pois:
		if Vector2(x - b.pos.x, z - b.pos.z).length() < POI_FLAT_RADIUS:
			return true
	return false

func _near_settlement(x:float,z:float,margin:float=19.0)->bool:
	var centers=[
		Vector2(-105,-165),Vector2(-55,-165),Vector2(55,-165),Vector2(105,-165),
		Vector2(-105,-100),Vector2(-50,-100),Vector2(20,-105),Vector2(75,-100),
		Vector2(-100,-35),Vector2(-45,-35),Vector2(20,-40),Vector2(80,-35),
		Vector2(-100,35),Vector2(-45,35),Vector2(20,35),Vector2(80,35),
		Vector2(-95,95),Vector2(-35,100),Vector2(35,95),Vector2(95,95),Vector2(0,0)
	]
	for p in centers:
		if absf(x-p.x)<margin and absf(z-p.y)<margin: return true
	return false

func _terrain_slope(x:float,z:float)->float:
	var d=1.5
	var hx=absf(height_at(x+d,z)-height_at(x-d,z))/(d*2.0)
	var hz=absf(height_at(x,z+d)-height_at(x,z-d))/(d*2.0)
	return maxf(hx,hz)

func _terrain_transition(x:float,z:float,r:float=4.0)->bool:
	var h=height_at(x,z)
	var base=_terrain_texture_index(x,z,h)
	var samples=[Vector2(r,0),Vector2(-r,0),Vector2(0,r),Vector2(0,-r)]
	for o in samples:
		if _terrain_texture_index(x+o.x,z+o.y,height_at(x+o.x,z+o.y))!=base:
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

func _find_animation_player(node:Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found:=_find_animation_player(child)
		if found!=null:
			return found
	return null

func _find_animation_name(player_node:AnimationPlayer, wanted:String) -> StringName:
	var wanted_lower:=wanted.to_lower()
	for library_name in player_node.get_animation_library_list():
		var library:=player_node.get_animation_library(library_name)
		if library==null:
			continue
		for animation_name in library.get_animation_list():
			if str(animation_name).to_lower()==wanted_lower:
				return animation_name
	return &""

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
	if h < -1.5: return Color(.29,.22,.14)
	if h < .4: return Color(.42,.34,.20)
	if h > 6.0: return Color(.43,.40,.32)
	return Color(.48,.43,.27)

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
	if ymin<INF: n.global_position.y+=height_at(x,z)-ymin-.48

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

func _terrain_texture_index(x:float,z:float,h:float)->int:
	# 15-texture natural-neighbour chain. Nearby cells can only drift to nearby
	# visual families, avoiding harsh dry-to-green jumps across the 6.25 m grid.
	var chain=[0,1,2,3,9,8,7,12,6,4,5,10,11,13,14]
	var field=sin(x*.012)+cos(z*.014)+sin((x+z)*.007)*.72+cos((x-z)*.009)*.55
	var detail=sin(x*.031+z*.023)*.28+cos(x*.019-z*.027)*.22
	var t=clampf((field+detail+2.77)/5.54,0.0,1.0)
	var pos=int(round(t*float(chain.size()-1)))
	return chain[clampi(pos,0,chain.size()-1)]

func _terrain_visual_mesh(cells:int)->ArrayMesh:
	return _terrain_surface(cells)

func _terrain_material(path:String)->StandardMaterial3D:
	var mat=StandardMaterial3D.new()
	mat.albedo_color=Color.WHITE; mat.roughness=.96; mat.vertex_color_use_as_albedo=false
	mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mat.texture_repeat=true
	if ResourceLoader.exists(path):
		var tex=ResourceLoader.load(path)
		if tex is Texture2D: mat.albedo_texture=tex
	return mat

func _build_center_settlement_mound() -> void:
	var body=StaticBody3D.new(); body.name="CenterSettlementMound"; body.position=Vector3(0,0.18,0); add_child(body)
	var mesh=MeshInstance3D.new(); var cylinder=CylinderMesh.new(); cylinder.top_radius=18.0; cylinder.bottom_radius=19.0; cylinder.height=0.36; cylinder.radial_segments=64; mesh.mesh=cylinder
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.46,.40,.32); mat.roughness=1.0; mesh.material_override=mat; body.add_child(mesh)
	var cs=CollisionShape3D.new(); var shape=CylinderShape3D.new(); shape.radius=19.0; shape.height=0.36; cs.shape=shape; body.add_child(cs)

func _build_world_environment() -> void:
	if world_env != null:
		return
	world_env=WorldEnvironment.new()
	var env=Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=Color(.25,.66,.96)
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=Color(.92,.95,1.0)
	env.ambient_light_energy=1.0
	env.tonemap_mode=Environment.TONE_MAPPER_LINEAR
	env.fog_enabled=false
	world_env.environment=env
	add_child(world_env)

func _build_world_light() -> void:
	if get_node_or_null("WorldSun") != null:
		return
	var sun=DirectionalLight3D.new()
	sun.name="WorldSun"
	sun.rotation_degrees=Vector3(-52,-28,0)
	sun.light_energy=1.35
	sun.shadow_enabled=not OS.has_feature("mobile")
	sun.directional_shadow_max_distance=95
	add_child(sun)

func _build_world_base():
	_build_world_environment()
	_build_world_light()
	_build_terrain_mesh()
	_build_center_settlement_mound()
	_build_map_edge_mountains()

func _build_corner_settlements() -> void:
	# All 20 settlements are distributed in the free interior. No four-corner lock.
	# Centers stay away from POIs and the +/-198 mountain border.
	var centers=[
		Vector3(-105,0,-165), Vector3(-55,0,-165), Vector3(55,0,-165), Vector3(105,0,-165),
		Vector3(-105,0,-100), Vector3(-50,0,-100), Vector3(20,0,-105), Vector3(75,0,-100),
		Vector3(-100,0,-35), Vector3(-45,0,-35), Vector3(20,0,-40), Vector3(80,0,-35),
		Vector3(-100,0,35), Vector3(-45,0,35), Vector3(20,0,35), Vector3(80,0,35),
		Vector3(-95,0,95), Vector3(-35,0,100), Vector3(35,0,95), Vector3(95,0,95)
	]
	var placed:Array[Vector3]=[]
	for center in centers:
		if not _settlement_position_safe(center,placed):
			continue
		_build_settlement_pad(center+Vector3(10,0,10),-1.0,-1.0)
		placed.append(center)
	# 20th settlement: fixed at the marked central empty area. Existing 19 positions stay unchanged.
	_build_settlement_pad(Vector3(10,0,10),-1.0,-1.0)

func _settlement_position_safe(center:Vector3,placed:Array[Vector3]) -> bool:
	# A 25x25 pad needs margin from mountains and named POI/boss areas.
	if absf(center.x)>170.0 or absf(center.z)>170.0: return false
	for poi in pois:
		if Vector2(center.x-poi.pos.x,center.z-poi.pos.z).length()<42.0: return false
	for other in placed:
		# 25m pad + at least 20m clear space.
		if absf(center.x-other.x)<45.0 and absf(center.z-other.z)<45.0: return false
	return true

func _build_settlement_pad(start:Vector3,x_dir:float,z_dir:float) -> void:
	for row in 5:
		for col in 5:
			var p=Vector3(start.x+x_dir*float(col)*5.0,.10,start.z+z_dir*float(row)*5.0)
			_add_settlement_concrete_tile(p)

func _build_settlement_houses() -> void:
	# Ready-made houses are a removable layer. The central settlement stays empty for the player.
	var centers=[
		Vector3(-105,0,-165),Vector3(-55,0,-165),Vector3(55,0,-165),Vector3(105,0,-165),
		Vector3(-105,0,-100),Vector3(-50,0,-100),Vector3(20,0,-105),Vector3(75,0,-100),
		Vector3(-100,0,-35),Vector3(-45,0,-35),Vector3(20,0,-40),Vector3(80,0,-35),
		Vector3(-100,0,35),Vector3(-45,0,35),Vector3(20,0,35),Vector3(80,0,35),
		Vector3(-95,0,95),Vector3(-35,0,100),Vector3(35,0,95),Vector3(95,0,95)
	]
	for i in 19:
		_add_ready_house(centers[i],1+(i%4))

func _house_box(root:Node3D,p:Vector3,size:Vector3,col:Color) -> void:
	var body=StaticBody3D.new(); body.position=p
	var mi=MeshInstance3D.new(); var box=BoxMesh.new(); box.size=size; mi.mesh=box; mi.material_override=_simple_mat(col); body.add_child(mi)
	var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=size; cs.shape=sh; body.add_child(cs); root.add_child(body)

func _add_ready_house(center:Vector3,storeys:int) -> void:
	var root=Node3D.new(); root.name="SettlementHouse"; root.position=Vector3(center.x,0,center.z); root.set_meta("removable_settlement_house",true); add_child(root)
	var wall_col=Color(.43,.34,.24); var floor_col=Color(.30,.25,.20)
	for level in storeys:
		var y=.2+float(level)*3.0
		_house_box(root,Vector3(0,y,0),Vector3(16,.25,16),floor_col)
		_house_box(root,Vector3(-7.8,y+1.5,0),Vector3(.35,3,16),wall_col)
		_house_box(root,Vector3(7.8,y+1.5,0),Vector3(.35,3,16),wall_col)
		_house_box(root,Vector3(0,y+1.5,7.8),Vector3(16,3,.35),wall_col)
		# Front wall leaves a central doorway.
		_house_box(root,Vector3(-5,y+1.5,-7.8),Vector3(6,3,.35),wall_col)
		_house_box(root,Vector3(5,y+1.5,-7.8),Vector3(6,3,.35),wall_col)
		if level<storeys-1:
			for step in 7:
				_house_box(root,Vector3(-3.5+float(step),y+.25+float(step)*.42,1.5),Vector3(1.2,.28,3.2),floor_col)
	_house_box(root,Vector3(0,.2+float(storeys)*3.0,0),Vector3(16,.3,16),Color(.24,.20,.17))

func remove_settlement_houses() -> void:
	# Removes only ready-made houses; all 20 concrete settlement pads remain.
	for child in get_children():
		if child is Node3D and child.get_meta("removable_settlement_house",false):
			child.queue_free()

func _add_settlement_concrete_tile(p:Vector3) -> void:
	var body=StaticBody3D.new(); body.position=p
	var mi=MeshInstance3D.new(); var box=BoxMesh.new(); box.size=Vector3(5.0,.20,5.0); mi.mesh=box
	mi.material_override=_simple_mat(Color(.47,.47,.45)); body.add_child(mi)
	var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=Vector3(5.0,.20,5.0); cs.shape=sh; body.add_child(cs)
	add_child(body)



func _build_map_edge_mountains() -> void:
	# #301 flat interior stays untouched. Mountains form only the four X/Z +/-198 borders.
	var edge:=198.0
	var gate_half:=5.0 # 10m / two-foundation-wide visual gate opening.
	var step:=8.0
	for side in [-1.0,1.0]:
		var x:=-198.0
		while x<=198.0:
			if absf(x)>gate_half:
				_add_edge_mountain(Vector3(x,0,side*edge),x,side*edge)
			x+=step
		var z:=-198.0
		while z<=198.0:
			if absf(z)>gate_half:
				_add_edge_mountain(Vector3(side*edge,0,z),side*edge,z)
			z+=step
	# Closed, collidable gates at the exact midpoint of each edge.
	_add_edge_gate(Vector3(0,0, edge),0.0)
	_add_edge_gate(Vector3(0,0,-edge),0.0)
	_add_edge_gate(Vector3( edge,0,0),90.0)
	_add_edge_gate(Vector3(-edge,0,0),90.0)

func _add_edge_mountain(p:Vector3,sx:float,sz:float) -> void:
	var body=StaticBody3D.new(); body.position=p
	var mesh_i=MeshInstance3D.new(); var cyl=CylinderMesh.new()
	var variation=absf(sin(sx*.071+sz*.113))
	cyl.top_radius=2.0+variation*1.8; cyl.bottom_radius=6.0+variation*2.2; cyl.height=11.0+variation*6.0
	mesh_i.mesh=cyl; mesh_i.position.y=cyl.height*.5
	mesh_i.material_override=_simple_mat(Color(.27,.26,.22)); body.add_child(mesh_i)
	var cs=CollisionShape3D.new(); var sh=CylinderShape3D.new()
	sh.radius=cyl.bottom_radius; sh.height=cyl.height; cs.shape=sh; cs.position.y=cyl.height*.5; body.add_child(cs)
	add_child(body)

func _add_edge_gate(p:Vector3,yaw:float) -> void:
	var gate=StaticBody3D.new(); gate.position=p+Vector3(0,2.0,0); gate.rotation_degrees.y=yaw
	var mi=MeshInstance3D.new(); var box=BoxMesh.new(); box.size=Vector3(9.6,4.0,.55); mi.mesh=box
	mi.material_override=_simple_mat(Color(.24,.12,.045)); gate.add_child(mi)
	var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=Vector3(9.6,4.0,.55); cs.shape=sh; gate.add_child(cs)
	# Simple old-plank relief makes the sealed exit read as a wooden door from a distance.
	for i in 5:
		var plank=MeshInstance3D.new(); var pb=BoxMesh.new(); pb.size=Vector3(1.65,3.65,.16); plank.mesh=pb
		plank.position=Vector3(-3.4+i*1.7,0,.34); plank.material_override=_simple_mat(Color(.31,.17,.07)); gate.add_child(plank)
	add_child(gate)


func _build_settlement_areas() -> void:
	# Yerleşim alanı görselleri kaldırıldı. #295'in diğer sistemleri korunuyor.
	return

func _settlement_index_at(p:Vector3) -> int:
	for i in settlement_centers.size():
		var c=settlement_centers[i]
		if absf(p.x-c.x)<=SETTLEMENT_SIZE*.5 and absf(p.z-c.z)<=SETTLEMENT_SIZE*.5: return i
	return -1

func _settlement_build_allowed(p:Vector3) -> bool:
	var idx=_settlement_index_at(p)
	if idx<0: return false
	return active_settlement<0 or idx==active_settlement

func _claim_settlement(p:Vector3) -> void:
	if active_settlement<0: active_settlement=_settlement_index_at(p)

func _build_storey_allowed(p:Vector3) -> bool:
	var idx=_settlement_index_at(p)
	if idx<0: return false
	var ground=settlement_centers[idx].y
	return p.y-ground < float(MAX_BUILD_STOREYS)*3.0+.75


func _resource_spawn_safe(x:float,z:float) -> bool:
	# Resources may be very close, but never overlap named POIs or 5x5 settlement pads.
	for poi in pois:
		if Vector2(x-poi.pos.x,z-poi.pos.z).length()<15.0: return false
	var settlement_centers_local=[
		Vector3(-105,0,-165),Vector3(-55,0,-165),Vector3(55,0,-165),Vector3(105,0,-165),
		Vector3(-105,0,-100),Vector3(-50,0,-100),Vector3(20,0,-105),Vector3(75,0,-100),
		Vector3(-100,0,-35),Vector3(-45,0,-35),Vector3(20,0,-40),Vector3(80,0,-35),
		Vector3(-100,0,35),Vector3(-45,0,35),Vector3(20,0,35),Vector3(80,0,35),
		Vector3(-95,0,95),Vector3(-35,0,100),Vector3(35,0,95),Vector3(95,0,95),Vector3(0,0,0)
	]
	for sc in settlement_centers_local:
		if absf(x-sc.x)<13.5 and absf(z-sc.z)<13.5: return false
	return true

func _animal_remember_target(animal:Node3D,target_id:int) -> void:
	var history:Array=animal.get_meta("target_history",[])
	if target_id>=0 and not history.has(target_id):
		history.append(target_id)
	while history.size()>5:
		history.pop_front()
	animal.set_meta("target_history",history)

func _animal_target_recent(animal:Node3D,target_id:int) -> bool:
	var history:Array=animal.get_meta("target_history",[])
	return history.has(target_id)

func _make_human_visual(parent:Node3D) -> void:
	var visual=Node3D.new()
	visual.name="AnimalVisual"
	parent.add_child(visual)
	var scene=load("res://assets/characters/enemies/raider.glb")
	if scene is PackedScene:
		var model=scene.instantiate()
		model.name="Body"
		model.rotation_degrees.y=180.0
		model.scale=Vector3.ONE
		visual.add_child(model)
		return
	# Lightweight human fallback if the character GLB is unavailable.
	var skin=_simple_mat(Color(.58,.43,.32))
	var cloth=_simple_mat(Color(.16,.18,.20))
	var body=MeshInstance3D.new()
	body.name="Body"
	var torso=CapsuleMesh.new()
	torso.radius=.28
	torso.height=1.05
	body.mesh=torso
	body.position=Vector3(0,1.05,0)
	body.material_override=cloth
	visual.add_child(body)
	var head=MeshInstance3D.new()
	var hm=SphereMesh.new()
	hm.radius=.22
	hm.height=.44
	head.mesh=hm
	head.position=Vector3(0,1.72,0)
	head.material_override=skin
	visual.add_child(head)

func _make_wild_animal_visual(parent:Node3D,kind:String,visual_scale:float) -> void:
	var visual=Node3D.new()
	visual.name="AnimalVisual"
	parent.add_child(visual)
	var model_path=""
	if kind=="KURT":
		model_path="res://assets/animals/wolf.glb"
	elif kind=="DOMUZ":
		model_path="res://assets/animals/boar.glb"
	elif kind=="GEYIK":
		model_path="res://assets/animals/deer.glb"
	var scene=load(model_path) if not model_path.is_empty() else null
	if scene is PackedScene:
		var model=scene.instantiate()
		model.name="Body"
		model.rotation_degrees.y=180.0
		model.scale=Vector3.ONE*visual_scale
		visual.add_child(model)
		return
	# Fallback keeps the animal visible if its GLB cannot be imported.
	var body=MeshInstance3D.new()
	body.name="Body"
	var bm=SphereMesh.new()
	bm.radius=1.45
	bm.height=2.6
	body.mesh=bm
	body.scale=Vector3(1.0,.72,1.45)*visual_scale
	body.position=Vector3(0,1.45*visual_scale,0)
	body.material_override=_simple_mat(Color(.42,.38,.32))
	visual.add_child(body)

func _all_animal_avoidance(animal:Node3D,move_dir:Vector3) -> Vector3:
	var nearest:Node3D=null
	var nearest_distance=INF
	for other in bears+wildlife:
		if other==animal or not is_instance_valid(other): continue
		var d=Vector2(animal.global_position.x-other.global_position.x,animal.global_position.z-other.global_position.z).length()
		if d<20.0 and d<nearest_distance:
			nearest=other
			nearest_distance=d
	if nearest==null: return Vector3.ZERO
	var left=Vector3(-move_dir.z,0.0,move_dir.x)
	var right=-left
	var left_pos=animal.position+left*14.0
	var right_pos=animal.position+right*14.0
	left_pos.y=height_at(left_pos.x,left_pos.z)
	right_pos.y=height_at(right_pos.x,right_pos.z)
	var left_gap=Vector2(left_pos.x-nearest.global_position.x,left_pos.z-nearest.global_position.z).length()
	var right_gap=Vector2(right_pos.x-nearest.global_position.x,right_pos.z-nearest.global_position.z).length()
	if not false and left_gap>=right_gap: return left
	if not false: return right
	if not false: return left
	return -move_dir

func _build_hills_and_pits():
	# Terrain heightfield already provides hills and pits. Avoid duplicate cylinder geometry.
	pass

func _rand_map_point(max_r: float) -> Vector3:
	return Vector3(randf_range(-max_r,max_r),0,randf_range(-max_r,max_r))

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
	coordinate_label=Label.new(); coordinate_label.set_anchors_preset(Control.PRESET_TOP_LEFT); coordinate_label.position=Vector2(18,54); coordinate_label.add_theme_font_size_override("font_size",18); coordinate_label.text="X: 0 | Z: 0"; layer.add_child(coordinate_label)
	hud=Label.new(); hud.position=Vector2(176,22); hud.add_theme_font_size_override("font_size",18); layer.add_child(hud)
	joystick_base=ColorRect.new(); joystick_base.set_anchors_preset(Control.PRESET_BOTTOM_LEFT); joystick_base.position=Vector2(24,-224); joystick_base.size=Vector2(200,200); joystick_base.color=Color(.08,.08,.08,.32); layer.add_child(joystick_base)
	joystick_knob=ColorRect.new(); joystick_knob.position=Vector2(64,64); joystick_knob.size=Vector2(72,72); joystick_knob.color=Color(.92,.92,.92,.55); joystick_base.add_child(joystick_knob)
	for item in [["↑",Vector2(88,4)],["↓",Vector2(88,168)],["←",Vector2(8,86)],["→",Vector2(168,86)]]:
		var jl=Label.new(); jl.text=item[0]; jl.position=item[1]; jl.size=Vector2(28,28); jl.add_theme_font_size_override("font_size",22); jl.mouse_filter=Control.MOUSE_FILTER_IGNORE; joystick_base.add_child(jl)
	var actions=[["ENVANTER",_toggle_inventory],["HILE",_toggle_cheat_mode],["UC",_toggle_fly_mode],["ALCAL",_fly_down],["MAĞAZA",_open_store]]
	for i in actions.size():
		var b=Button.new(); b.text=actions[i][0]; b.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		if actions[i][0]=="HILE":
			cheat_button=b
			cheat_button.text="HILE KAPALI"
		elif actions[i][0]=="UC": fly_button=b
		elif actions[i][0]=="ALCAL": fly_down_button=b
		var col=i%2; var row=int(i/2); b.position=Vector2(-300+col*148,12+row*42); b.size=Vector2(140,38); b.add_theme_font_size_override("font_size",15); b.pressed.connect(actions[i][1]); layer.add_child(b)
	_update_fly_button_styles()
	_create_minimap(layer)
	var action_btn=Button.new(); action_btn.text="VUR"; action_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); action_btn.position=Vector2(-250,-215); action_btn.size=Vector2(104,104); action_btn.add_theme_font_size_override("font_size",20)
	var action_style=StyleBoxFlat.new(); action_style.bg_color=Color(1.0,.78,.08,.34); action_style.corner_radius_top_left=52; action_style.corner_radius_top_right=52; action_style.corner_radius_bottom_left=52; action_style.corner_radius_bottom_right=52
	action_btn.add_theme_stylebox_override("normal",action_style); action_btn.add_theme_stylebox_override("pressed",action_style); action_btn.mouse_filter=Control.MOUSE_FILTER_STOP; layer.add_child(action_btn)
	var jump_btn=Button.new(); jump_btn.text="↑ Zıpla"; jump_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); jump_btn.position=Vector2(-238,-310); jump_btn.size=Vector2(92,76); jump_btn.add_theme_font_size_override("font_size",18); jump_btn.pressed.connect(_jump); layer.add_child(jump_btn)
	var scope_btn=Button.new(); scope_btn.text="🔭"; scope_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); scope_btn.position=Vector2(-350,-320); scope_btn.size=Vector2(82,82); scope_btn.add_theme_font_size_override("font_size",28)
	var scope_style=StyleBoxFlat.new(); scope_style.bg_color=Color(.10,.10,.10,.30); scope_style.corner_radius_top_left=41; scope_style.corner_radius_top_right=41; scope_style.corner_radius_bottom_left=41; scope_style.corner_radius_bottom_right=41
	scope_btn.add_theme_stylebox_override("normal",scope_style); scope_btn.add_theme_stylebox_override("pressed",scope_style); scope_btn.pressed.connect(_toggle_scope); layer.add_child(scope_btn)
	crouch_button=Button.new(); crouch_button.text="↓ Çömel"; crouch_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); crouch_button.position=Vector2(-238,-104); crouch_button.size=Vector2(104,80); crouch_button.add_theme_font_size_override("font_size",18)
	var crouch_style=StyleBoxFlat.new(); crouch_style.bg_color=Color(.12,.12,.12,.34); crouch_style.corner_radius_top_left=40; crouch_style.corner_radius_top_right=40; crouch_style.corner_radius_bottom_left=40; crouch_style.corner_radius_bottom_right=40
	crouch_button.add_theme_stylebox_override("normal",crouch_style); crouch_button.add_theme_stylebox_override("pressed",crouch_style); crouch_button.pressed.connect(_toggle_crouch); layer.add_child(crouch_button)
	var aim=Label.new(); aim.text="+"; aim.set_anchors_preset(Control.PRESET_CENTER); aim.position=Vector2(-14,-22); aim.size=Vector2(28,44); aim.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; aim.add_theme_font_size_override("font_size",32); aim.add_theme_color_override("font_color",Color(.95,.08,.06,1)); aim.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(aim)
	_create_survival_clock(layer); _create_damage_effect(layer); _create_cheat_ui(layer)
	facing_label=Label.new(); facing_label.set_anchors_preset(Control.PRESET_TOP_WIDE); facing_label.position=Vector2(0,48); facing_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; facing_label.add_theme_font_size_override("font_size",22); layer.add_child(facing_label)
	waypoint_label=Label.new(); waypoint_label.set_anchors_preset(Control.PRESET_TOP_WIDE); waypoint_label.position=Vector2(0,76); waypoint_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; waypoint_label.add_theme_font_size_override("font_size",20); layer.add_child(waypoint_label)
	_update_cheat_button_style()
	_setup_sfx(); fx_root=Node3D.new(); fx_root.name="Effects"; add_child(fx_root)

func _open_store():
	if store_panel==null:
		_create_store_panel()
	var opening=not store_panel.visible
	if inventory_panel: inventory_panel.visible=false
	if craft_panel: craft_panel.visible=false
	if map_panel: map_panel.visible=false
	store_panel.visible=opening
	_set_modal_lock(_panel_open())

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
	_validate_shop_icons()
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

func _load_item_texture(path:String) -> Texture2D:
	if ResourceLoader.exists(path):
		var t = ResourceLoader.load(path)
		if t is Texture2D:
			return t
	if FileAccess.file_exists(path):
		var img := Image.new()
		if img.load(path) == OK:
			return ImageTexture.create_from_image(img)
	push_warning("MISSING ICON: " + path)
	return null

func _store_detail_path(item:Dictionary) -> String:
	return str(item.path).replace("_128.png","_512.png")

func _store_item_details(item:Dictionary) -> String:
	var rarity_index=["gray","green","blue","orange","red"].find(str(item.rarity))
	var name=str(item.name)
	if name in ["Mızrak","Meşale","Yay","Arbalet","Tabanca","Pompalı","Tüfek","Patlayıcı"]:
		var weapon_damage={"Mızrak":18,"Meşale":12,"Yay":22,"Arbalet":28,"Tabanca":24,"Pompalı":36,"Tüfek":30,"Patlayıcı":40}
		var ammo_name={"Mızrak":"Mızrak Ucu","Meşale":"Yok","Yay":"Ok","Arbalet":"Ok","Tabanca":"Tabanca Mermisi","Pompalı":"Pompalı Mermisi","Tüfek":"Tüfek Mermisi","Patlayıcı":"Patlayıcı"}
		return "HASAR  %d\nMÜHİMMAT  %s\nKALİTE  %s" % [int(weapon_damage[name])+rarity_index*10,ammo_name[name],_store_rarity_name(item.rarity)]
	if "Mermisi" in name or name in ["Ok","Mızrak Ucu"]:
		var effects=["Normal","Keskin","Delici","Yanıcı","Patlayıcı"]
		var weapons={"Tabanca Mermisi":"Tabanca","Pompalı Mermisi":"Pompalı","Tüfek Mermisi":"Tüfek","Ok":"Yay / Arbalet","Mızrak Ucu":"Mızrak"}
		return "TÜR  %s\nETKİ  %s\nKULLANIM  %s\nKALİTE  %s" % [name,effects[rarity_index],weapons[name],_store_rarity_name(item.rarity)]
	var protection=25
	if name.begins_with("Taş"): protection=30
	elif name.begins_with("Metal"): protection=35
	protection+=rarity_index*5
	var part="Zırh"
	if "Kask" in name: part="Baş"
	elif "Göğüslük" in name: part="Gövde"
	elif "Pantolon" in name: part="Bacak"
	elif "Bot" in name: part="Ayak"
	return "KORUMA  %d\nPARÇA  %s\nKALİTE  %s" % [protection,part,_store_rarity_name(item.rarity)]

func _close_store_detail() -> void:
	if store_panel==null: return
	var detail=store_panel.get_node_or_null("ItemDetail")
	if detail: detail.queue_free()

func _open_store_detail(item:Dictionary) -> void:
	if store_panel==null: return
	_close_store_detail()
	var detail=Panel.new()
	detail.name="ItemDetail"
	detail.position=Vector2(90,72)
	detail.size=Vector2(600,470)
	detail.z_index=20
	store_panel.add_child(detail)
	var close=Button.new(); close.text="✕"; close.position=Vector2(536,12); close.size=Vector2(48,38); close.pressed.connect(_close_store_detail); detail.add_child(close)
	var title=Label.new(); title.text="%s  •  %s" % [item.name,_store_rarity_name(item.rarity)]; title.position=Vector2(22,14); title.size=Vector2(500,38); title.add_theme_font_size_override("font_size",24); detail.add_child(title)
	var preview=TextureRect.new(); preview.position=Vector2(24,70); preview.size=Vector2(300,300); preview.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; preview.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; detail.add_child(preview)
	var detail_path=_store_detail_path(item)
	var detail_tex=_load_item_texture(detail_path)
	if detail_tex==null: detail_tex=_load_item_texture(item.path)
	preview.texture=detail_tex
	var info=Label.new(); info.position=Vector2(346,92); info.size=Vector2(225,250); info.text=_store_item_details(item); info.add_theme_font_size_override("font_size",18); detail.add_child(info)
	var hint=Label.new(); hint.text="512px detay görseli"; hint.position=Vector2(24,392); hint.size=Vector2(300,30); hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; detail.add_child(hint)

func _make_store_slot(item:Dictionary) -> Control:
	var button=TextureButton.new()
	button.custom_minimum_size=Vector2(136,104)
	button.tooltip_text="%s • %s" % [item.name,_store_rarity_name(item.rarity)]
	button.ignore_texture_size=true
	button.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	var tex=_load_item_texture(item.path)
	if tex!=null:
		button.texture_normal=tex
	else:
		var missing_style=StyleBoxFlat.new()
		missing_style.bg_color=Color(0,0,0,0)
		missing_style.border_color=Color(1,0,0,1)
		missing_style.set_border_width_all(2)
		var frame=Panel.new(); frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); frame.mouse_filter=Control.MOUSE_FILTER_IGNORE; frame.add_theme_stylebox_override("panel",missing_style); button.add_child(frame)
	button.pressed.connect(_open_store_detail.bind(item))
	return button

func _validate_shop_icons() -> void:
	var missing=0
	for cat in ["SİLAHLAR","MERMİLER","ZIRHLAR"]:
		for item in _store_items(cat):
			if _load_item_texture(item.path)==null:
				missing+=1
				print("MISSING ",item.path)
	print("SHOP ICONS MISSING=",missing)

func _store_category(category:String):
	if store_panel==null: return
	var old=store_panel.get_node_or_null("ItemsScroll")
	if old:
		store_panel.remove_child(old)
		old.queue_free()
	var scroll=ScrollContainer.new()
	scroll.name="ItemsScroll"
	scroll.position=Vector2(20,116)
	scroll.size=Vector2(740,440)
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	store_panel.add_child(scroll)
	var grid=GridContainer.new()
	grid.name="ItemGrid"
	grid.columns=5
	grid.custom_minimum_size=Vector2(720,0)
	grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	for item in _store_items(category):
		grid.add_child(_make_store_slot(item))
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

func _panel_open() -> bool:
	return (inventory_panel != null and inventory_panel.visible) or (craft_panel != null and craft_panel.visible) or (store_panel != null and store_panel.visible) or (map_panel != null and map_panel.visible)

func _is_inside_open_panel(node:Node) -> bool:
	var current=node.get_parent()
	while current:
		if current==inventory_panel or current==craft_panel or current==store_panel or current==map_panel:
			return current.visible
		current=current.get_parent()
	return false

func _set_modal_lock(locked:bool):
	var layers=get_children().filter(func(n): return n is CanvasLayer)
	for layer in layers:
		for node in layer.find_children("*","Button",true,false):
			var button=node as Button
			button.disabled=locked and not _is_inside_open_panel(button)

func _update_cheat_button_style():
	if cheat_button==null: return
	cheat_button.text="HILE ACIK" if cheat_mode else "HILE KAPALI"
	var normal=StyleBoxFlat.new()
	normal.bg_color=Color(.12,.58,.20,.92) if cheat_mode else Color(.72,.10,.10,.92)
	normal.corner_radius_top_left=6
	normal.corner_radius_top_right=6
	normal.corner_radius_bottom_left=6
	normal.corner_radius_bottom_right=6
	cheat_button.add_theme_stylebox_override("normal",normal)
	cheat_button.add_theme_stylebox_override("hover",normal)
	cheat_button.add_theme_stylebox_override("pressed",normal)

func _physics_process(delta):
	if player == null or camera == null or hud == null or zone_label == null:
		return
	if coordinate_label:
		coordinate_label.text="X: %d | Z: %d" % [roundi(player.global_position.x),roundi(player.global_position.z)]
	if _panel_open():
		move_touch=Vector2.ZERO
		player.velocity.x=0.0
		player.velocity.z=0.0
		_update_day_cycle(delta)
		_update_weather(delta)
		_update_map_dot()
		_update_navigation_ui()
		_update_minimap()
		zone_label.text="%s  •  %s" % [("CUKUR" if in_pit else ("TERK EDILMIS BOLGE" if in_dry else "VAHSI")),_nearest_poi()]
		hud.text = "HP %d  Ac %d  Su %d  Kart %d" % [health,int(hunger),int(thirst),gray_cards]
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
	if fly_mode: speed*=6.0
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
	_update_map_dot()
	_update_navigation_ui()
	_update_minimap()
	_update_aim_marker()
	_update_day_cycle(delta)
	_update_weather(delta)
	_update_footsteps(delta)
	_update_damage_effect(delta)
	if health <= 0:
		_death_feedback()
		_respawn()
	var zone = "VAHSI"
	if in_pit:
		zone = "CUKUR"
	elif in_dry:
		zone = "TERK EDILMIS BOLGE"
	zone_label.text="%s  •  %s" % [zone,_nearest_poi()]
	hud.text = "HP %d  Ac %d  Su %d  Kart %d" % [health, int(hunger), int(thirst), gray_cards]

func _build_weather_system():
	# Rain, snow and fog are intentionally disabled.
	weather_root=Node3D.new()
	weather_root.name="LocalWeather"
	add_child(weather_root)
	weather_particles=null
	_set_weather("clear")

func _set_weather(_kind:String):
	# Weather variants are disabled. Keep one permanent clear sunny state.
	weather_state="clear"
	weather_duration=0.0
	weather_timer=999999.0
	if weather_particles: weather_particles.emitting=false
	var env:Environment=world_env.environment if world_env else null
	if env:
		env.background_mode=Environment.BG_COLOR
		env.background_color=Color(.32,.67,.94)
		env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color=Color(.78,.86,.94)
		env.ambient_light_energy=1.0
		env.fog_enabled=false

func _update_weather(_delta:float):
	# KARA KIYI now stays permanently sunny and clear.
	weather_state="clear"
	if weather_particles:
		weather_particles.emitting=false
	var env:Environment=world_env.environment if world_env else null
	if env:
		env.background_color=Color(.32,.67,.94)
		env.ambient_light_color=Color(.78,.86,.94)
		env.ambient_light_energy=1.0
		env.fog_enabled=false

func _toggle_crouch():
	if _panel_open(): return
	if player==null or camera==null: return
	crouched=not crouched
	camera.position.y=.34 if crouched else .72
	player_move_speed=4.8 if crouched else 6.8
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
	if _panel_open(): return
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

func _apply_damage(amount:float):
	damage_buffer += amount
	var whole=int(floor(damage_buffer))
	if whole>0:
		health=max(0,health-whole)
		damage_buffer-=whole

func _add_house_light(roof_pos:Vector3):
	var light=OmniLight3D.new(); light.position=roof_pos+Vector3(0,-1.35,0); light.light_color=Color(1.0,.88,.68); light.light_energy=.85; light.omni_range=7.0; light.shadow_enabled=false; add_child(light)

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

func _minimap_input(event):
	if event is InputEventScreenTouch and event.pressed:
		_toggle_map()

func _toggle_map():
	if map_panel == null: _create_map()
	var opening=not map_panel.visible
	if inventory_panel: inventory_panel.visible=false
	if craft_panel: craft_panel.visible=false
	if store_panel: store_panel.visible=false
	map_panel.visible=opening
	_set_modal_lock(_panel_open())

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
	# Real Meshy boss/POI model. Normalize from model-local bounds so arbitrary GLB origins
	# cannot push the visible geometry underground or tens of metres away from the POI marker.
	var base:Vector3=b.pos
	var root=Node3D.new()
	root.name="POI_"+str(b.id)
	root.position=Vector3(base.x,height_at(base.x,base.z),base.z)
	root.set_meta("poi_id",str(b.id))
	add_child(root)

	var model=_load_asset(str(b.asset))
	if model==null:
		push_error("POI LOAD FAILED: "+str(b.asset))
		return
	root.add_child(model)

	var bounds:=AABB()
	var has_bounds:=false
	var stack:Array[Node]=[model]
	var model_inv:Transform3D=model.global_transform.affine_inverse()
	while not stack.is_empty():
		var cur=stack.pop_back()
		if cur is MeshInstance3D and cur.mesh!=null:
			# Convert every mesh AABB back into the model root's LOCAL space.
			var rel:Transform3D=model_inv * cur.global_transform
			var box:AABB=rel * cur.mesh.get_aabb()
			if not has_bounds:
				bounds=box
				has_bounds=true
			else:
				bounds=bounds.merge(box)
		for child in cur.get_children():
			stack.append(child)

	if not has_bounds:
		push_error("POI HAS NO MESH: "+str(b.asset))
		return

	var longest=maxf(bounds.size.x,maxf(bounds.size.y,bounds.size.z))
	if longest<=0.001:
		push_error("POI INVALID BOUNDS: "+str(b.asset))
		return

	var s=float(b.size)/longest
	model.scale=Vector3.ONE*s
	# Centre X/Z on the boss marker and put the model's true lowest point on terrain.
	var center_x=bounds.position.x+bounds.size.x*.5
	var center_z=bounds.position.z+bounds.size.z*.5
	model.position=Vector3(-center_x*s,-bounds.position.y*s,-center_z*s)

	# Collision follows the exact imported meshes. Open entrances remain traversable.
	stack=[model]
	while not stack.is_empty():
		var cur=stack.pop_back()
		if cur is MeshInstance3D and cur.mesh!=null:
			var body=StaticBody3D.new()
			body.name="POICollision"
			var cs=CollisionShape3D.new()
			cs.shape=cur.mesh.create_trimesh_shape()
			body.add_child(cs)
			cur.add_child(body)
		for child in cur.get_children():
			if child is StaticBody3D and child.name=="POICollision":
				continue
			stack.append(child)

func _simple_mat(c:Color)->StandardMaterial3D:
	var m=StandardMaterial3D.new(); m.albedo_color=c; m.roughness=.75; return m


func _toggle_inventory():
	if inventory_panel==null: _create_inventory()
	var opening=not inventory_panel.visible
	if craft_panel: craft_panel.visible=false
	if store_panel: store_panel.visible=false
	if map_panel: map_panel.visible=false
	inventory_panel.visible=opening
	if inventory_panel.visible: _refresh_inventory()
	_set_modal_lock(_panel_open())

func _create_inventory():
	inventory_panel=Panel.new(); inventory_panel.set_anchors_preset(Control.PRESET_CENTER); inventory_panel.position=Vector2(-360,-290); inventory_panel.size=Vector2(720,580)
	var title=Label.new(); title.text="ENVANTER"; title.position=Vector2(24,14); title.add_theme_font_size_override("font_size",26); inventory_panel.add_child(title)
	var close=Button.new(); close.text="✕"; close.position=Vector2(650,12); close.size=Vector2(48,42); close.pressed.connect(_toggle_inventory); inventory_panel.add_child(close)
	var scroll=ScrollContainer.new(); scroll.name="InvScroll"; scroll.position=Vector2(20,58); scroll.size=Vector2(680,500); inventory_panel.add_child(scroll)
	var grid=GridContainer.new(); grid.name="Grid"; grid.columns=5; grid.custom_minimum_size=Vector2(650,0); grid.add_theme_constant_override("h_separation",2); grid.add_theme_constant_override("v_separation",6); scroll.add_child(grid)
	var layers=get_children().filter(func(n): return n is CanvasLayer); if layers.size()>0: layers[-1].add_child(inventory_panel)
	inventory_panel.visible=false

func _inventory_item_cell(key:String,title:String,count:int,texture:Texture2D=null)->Control:
	var cell=VBoxContainer.new()
	cell.custom_minimum_size=Vector2(128,142)
	cell.add_theme_constant_override("separation",4)
	var image_button=TextureButton.new()
	image_button.custom_minimum_size=Vector2(128,104)
	image_button.ignore_texture_size=true
	image_button.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	image_button.texture_normal=texture
	image_button.tooltip_text=title
	image_button.pressed.connect(_open_inventory_item_actions.bind(key,title))
	cell.add_child(image_button)
	var name_button=Button.new()
	name_button.custom_minimum_size=Vector2(128,34)
	name_button.text=title
	name_button.clip_text=true
	name_button.add_theme_font_size_override("font_size",_inventory_name_font_size(title))
	name_button.pressed.connect(_open_inventory_item_actions.bind(key,title))
	cell.add_child(name_button)
	return cell

func _inventory_name_font_size(title:String) -> int:
	var n=title.length()
	if n>=24: return 8
	if n>=19: return 9
	if n>=15: return 10
	return 12

func _close_inventory_item_actions() -> void:
	if inventory_panel==null: return
	var old=inventory_panel.get_node_or_null("ItemActions")
	if old: old.queue_free()

func _open_inventory_item_actions(key:String,title:String) -> void:
	if inventory_panel==null: return
	_close_inventory_item_actions()
	var actions=Panel.new(); actions.name="ItemActions"; actions.position=Vector2(210,185); actions.size=Vector2(300,150); actions.z_index=30
	var panel_style=StyleBoxFlat.new(); panel_style.bg_color=Color(.20,.21,.22,.96); panel_style.border_width_left=1; panel_style.border_width_top=1; panel_style.border_width_right=1; panel_style.border_width_bottom=1; panel_style.border_color=Color(.55,.55,.55,.8); panel_style.corner_radius_top_left=8; panel_style.corner_radius_top_right=8; panel_style.corner_radius_bottom_left=8; panel_style.corner_radius_bottom_right=8
	actions.add_theme_stylebox_override("panel",panel_style); inventory_panel.add_child(actions)
	var name_label=Label.new(); name_label.text=title; name_label.position=Vector2(18,15); name_label.size=Vector2(210,34); name_label.add_theme_font_size_override("font_size",18); actions.add_child(name_label)
	var close=Button.new(); close.text="✕"; close.position=Vector2(238,8); close.size=Vector2(52,48); close.mouse_filter=Control.MOUSE_FILTER_STOP; close.z_index=31; actions.add_child(close); close.button_down.connect(_close_inventory_item_actions)
	var equip=Button.new(); equip.text="KUŞAN"; equip.position=Vector2(45,72); equip.size=Vector2(210,55); equip.pressed.connect(_equip_inventory_item.bind(key)); actions.add_child(equip)

func _inventory_is_stackable(name:String,rarity:String) -> bool:
	for item in _store_items("MERMİLER"):
		if str(item.name)==name and str(item.rarity)==rarity: return true
	return false

func _refresh_inventory():
	if inventory_panel==null: return
	_close_inventory_item_actions()
	var grid=inventory_panel.get_node("InvScroll/Grid")
	for child in grid.get_children(): child.queue_free()
	var shown:=0
	for key in crafted_inventory:
		var count=int(crafted_inventory[key])
		if count<=0: continue
		var parts=key.split("|")
		if parts.size()<2: continue
		var name=str(parts[0]); var rarity=str(parts[1])
		var tex=null
		var title="%s %s" % [_store_rarity_name(rarity),name]
		var stackable=_inventory_is_stackable(name,rarity)
		var remaining=count
		while remaining>0 and shown<25:
			var amount=mini(100,remaining) if stackable else 1
			grid.add_child(_inventory_item_cell(key,title+"  "+str(amount)+"x",amount,tex))
			remaining-=amount
			shown+=1
		if shown>=25: break

func _build_blocks_respawn(p:Vector3)->bool:
	# Check the actual placed structure nodes instead of one old build_origin point.
	for n in get_children():
		if not (n is Node3D) or not is_instance_valid(n): continue
		if not n.has_meta("build_piece"): continue
		var q:Vector3=n.global_position
		if Vector2(p.x-q.x,p.z-q.z).length()<3.6: return true
	if fire_built and Vector2(p.x-campfire_pos.x,p.z-campfire_pos.z).length()<3.0: return true
	return false

func _rarity_list() -> Array:
	return ["gray","green","blue","orange","red"]

func _armor_recipe(name:String) -> Dictionary:
	if name.begins_with("Ahşap"):
		return {"cat":"ZIRHLAR","mat":{"wood":2,"deri":2,"ip":1}}
	if name.begins_with("Taş"):
		return {"cat":"ZIRHLAR","mat":{"stone":3,"deri":2,"ip":1}}
	return {"cat":"ZIRHLAR","mat":{"demir":4,"kulce_demir":2,"deri":2,"ip":1}}

func _resource_amount(key:String)->int:
	match key:
		"wood": return wood
		"stone": return stone
		"demir": return metal_parts
		"gray_card": return gray_cards
		_:
			if key.begins_with("item:"): return int(crafted_inventory.get(key.trim_prefix("item:"),0))
			return int(craft_resources.get(key,0))

func _take_resource(key:String,amount:int)->void:
	if cheat_mode: return
	match key:
		"wood": wood-=amount
		"stone": stone-=amount
		"demir": metal_parts-=amount
		"gray_card": gray_cards-=amount
		_:
			if key.begins_with("item:"):
				var item_key=key.trim_prefix("item:")
				crafted_inventory[item_key]=maxi(0,int(crafted_inventory.get(item_key,0))-amount)
			else: craft_resources[key]=maxi(0,int(craft_resources.get(key,0))-amount)

func _create_hotbar(layer:CanvasLayer):
	hotbar=HBoxContainer.new()
	hotbar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hotbar.position=Vector2(-476,-116)
	hotbar.size=Vector2(952,106)
	hotbar.alignment=BoxContainer.ALIGNMENT_CENTER
	for i in 7:
		var b=TextureButton.new()
		b.name="HotbarSlot_%d" % i
		b.custom_minimum_size=Vector2(132,100)
		b.ignore_texture_size=true
		b.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		b.tooltip_text=""
		b.pressed.connect(_select_hotbar.bind(i))
		b.button_down.connect(_hotbar_hold_start.bind(i))
		b.button_up.connect(_hotbar_hold_cancel.bind(i))
		hotbar.add_child(b)
	layer.add_child(hotbar)
	var eye=Button.new()
	eye.name="HotbarEye"
	eye.text="👁"
	eye.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	eye.position=Vector2(-476,-146)
	eye.size=Vector2(34,28)
	eye.add_theme_font_size_override("font_size",13)
	eye.pressed.connect(_toggle_hotbar_visibility.bind(eye))
	layer.add_child(eye)
	hotbar_label=Label.new()
	hotbar_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hotbar_label.position=Vector2(-220,-148)
	hotbar_label.size=Vector2(440,30)
	hotbar_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	hotbar_label.add_theme_font_size_override("font_size",16)
	hotbar_label.text=""
	layer.add_child(hotbar_label)
func _hotbar_item_title(key:String) -> String:
	if key.is_empty(): return ""
	if "|" in key:
		var parts=key.split("|"); return "%s %s" % [_store_rarity_name(str(parts[1])),str(parts[0])]
	return key

func _refresh_hotbar() -> void:
	if hotbar==null: return
	for i in range(mini(7,hotbar.get_child_count())):
		var b=hotbar.get_child(i) as TextureButton
		if b==null: continue
		var key=str(hotbar_items[i])
		b.texture_normal=null
		b.tooltip_text=_hotbar_item_title(key)
		b.visible=not hotbar_hidden
		for child in b.get_children(): child.queue_free()
		if "|" in key:
			var parts=key.split("|")
			b.texture_normal=null
		if not key.is_empty() and _hotbar_item_title(key)==selected_tool:
			var selected=Panel.new()
			selected.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			selected.mouse_filter=Control.MOUSE_FILTER_IGNORE
			var st=StyleBoxFlat.new()
			st.bg_color=Color(.10,.75,.25,.28)
			st.border_color=Color(.25,1.0,.40,.85)
			st.set_border_width_all(3)
			selected.add_theme_stylebox_override("panel",st)
			b.add_child(selected)
func _equip_inventory_item(key:String) -> void:
	if key.is_empty(): return
	var existing=hotbar_items.find(key)
	var target=existing
	if target<0:
		for i in range(hotbar_items.size()):
			if str(hotbar_items[i]).is_empty():
				target=i
				break
	if target<0: target=0
	hotbar_items[target]=key
	_select_hotbar(target)
	_close_inventory_item_actions()


func _toggle_hotbar_visibility(eye:Button) -> void:
	hotbar_hidden=not hotbar_hidden
	eye.text="👁" if not hotbar_hidden else "👁̸"
	eye.add_theme_color_override("font_color",Color.WHITE if not hotbar_hidden else Color.RED)
	if hotbar_label: hotbar_label.visible=not hotbar_hidden
	_refresh_hotbar()

func _hotbar_hold_start(slot:int) -> void:
	if hotbar_hidden or slot<0 or slot>=hotbar_items.size(): return
	var key=str(hotbar_items[slot])
	if key.is_empty(): return
	var token=Time.get_ticks_msec()
	hotbar_hold_started[slot]=token
	_hotbar_drop_countdown(slot,key,token)

func _hotbar_hold_cancel(slot:int) -> void:
	hotbar_hold_started.erase(slot)
	if hotbar_label and hotbar_label.text=="Ürün bırakılıyor...": hotbar_label.text=""

func _hotbar_drop_countdown(slot:int,key:String,token:int) -> void:
	if hotbar_label: hotbar_label.text="Ürün bırakılıyor..."
	var b=hotbar.get_child(slot) as TextureButton
	var overlay=ProgressBar.new()
	overlay.name="DropProgress"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
	overlay.min_value=0; overlay.max_value=3; overlay.value=0
	overlay.show_percentage=false
	var bg=StyleBoxFlat.new(); bg.bg_color=Color(0,0,0,0)
	var fill=StyleBoxFlat.new(); fill.bg_color=Color(.85,.08,.08,.55)
	overlay.add_theme_stylebox_override("background",bg); overlay.add_theme_stylebox_override("fill",fill)
	b.add_child(overlay)
	var elapsed:=0.0
	while elapsed<3.0:
		await get_tree().process_frame
		if not hotbar_hold_started.has(slot) or int(hotbar_hold_started[slot])!=token:
			if is_instance_valid(overlay): overlay.queue_free()
			return
		elapsed=(Time.get_ticks_msec()-token)/1000.0
		overlay.value=minf(elapsed,3.0)
	hotbar_hold_started.erase(slot)
	if is_instance_valid(overlay): overlay.queue_free()
	_drop_hotbar_stack(slot,key)

func _drop_hotbar_stack(slot:int,key:String) -> void:
	var amount=int(crafted_inventory.get(key,0))
	if amount<=0: return
	crafted_inventory.erase(key)
	hotbar_items[slot]=""
	selected_tool=""
	if hotbar_label: hotbar_label.text=""
	_spawn_dropped_item(key,amount)
	_refresh_hotbar()
	_refresh_inventory()

func _spawn_dropped_item(key:String,amount:int) -> void:
	if player==null: return
	var parts=key.split("|")
	if parts.size()<2: return
	var root=Node3D.new(); root.name="Dropped_"+str(parts[0])
	var drop_pos=player.position+player_facing.normalized()*2.0
	drop_pos.y=height_at(drop_pos.x,drop_pos.z)+0.38
	root.position=drop_pos
	add_child(root)
	var sprite=Sprite3D.new()
	sprite.texture=null
	sprite.pixel_size=.006
	sprite.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	root.add_child(sprite)
	var qty=Label3D.new(); qty.text=str(amount)+"x"; qty.position=Vector3(0,-.65,0); qty.font_size=48; qty.billboard=BaseMaterial3D.BILLBOARD_ENABLED; root.add_child(qty)


func _select_hotbar(slot:int):
	if slot<0 or slot>=hotbar_items.size(): return
	var key=str(hotbar_items[slot])
	if key.is_empty(): return
	selected_tool=_hotbar_item_title(key)
	if hotbar_label:
		hotbar_label.text=selected_tool
	hotbar_feedback_token+=1
	var token=hotbar_feedback_token
	_hide_hotbar_feedback_later(token)
	var held_slot:=0
	var legacy={"BALTA":1,"KAZMA":2,"SILAH":3,"YAPI CEKICI":4}
	held_slot=int(legacy.get(key,0))
	# Crafted/store weapons use keys such as "Tabanca|gray"; map their real item name to an FPS grip.
	if "|" in key:
		var item_name=str(key.split("|")[0])
		if item_name in ["Tabanca"]: held_slot=5
		elif item_name in ["Tüfek","Pompalı","Arbalet"]: held_slot=3
		elif item_name in ["Mızrak","Meşale","Yay"]: held_slot=6

	build_mode=key=="YAPI CEKICI"
	if build_preview: build_preview.visible=false
	_refresh_hotbar()


func _hide_hotbar_feedback_later(token:int) -> void:
	await get_tree().create_timer(4.0).timeout
	if token!=hotbar_feedback_token: return
	if hotbar_label: hotbar_label.text=""
	selected_tool=""
	_refresh_hotbar()


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

func _foundation_top_y(x:float,z:float)->float:
	var corners=[Vector2(-2.5,-2.5),Vector2(2.5,-2.5),Vector2(-2.5,2.5),Vector2(2.5,2.5)]
	var top=-INF
	for off in corners: top=maxf(top,height_at(x+off.x,z+off.y))
	return top+.35

func _add_frame_box(root:Node3D,size:Vector3,pos:Vector3):
	var mi=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=size; mi.mesh=bm; mi.position=pos; mi.material_override=_simple_mat(Color(.42,.23,.08)); root.add_child(mi)
	var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=size; cs.shape=sh; cs.position=pos; root.add_child(cs)

func _use_nearest_interior():
	if _panel_open(): return
	var best: Node3D; var dist=3.0
	for n in get_tree().get_nodes_in_group("interior_interactable"):
		var d=player.global_position.distance_to(n.global_position)
		if d<dist: dist=d; best=n
	if best==null: return
	var kind=str(best.get_meta("interior",""))
	if kind=="bed":
		bed_spawn=best.global_position+Vector3(0,1,1.5); has_bed_spawn=true; _update_bed_minimap(); _flash_message("YENIDEN DOGMA NOKTASI AYARLANDI")
	elif kind=="stove": hunger=min(100.0,hunger+20.0); _flash_message("YEMEK PISIRILDI +20 ACLIK")

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


func _toggle_scope():
	if _panel_open(): return
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


func _fps_asset_for_selected(slot:int) -> String:
	var item=selected_tool.to_lower()
	if "tabanca" in item:
		if "gri" in item: return "res://assets/pistol_gray.glb"
		if "yeşil" in item or "yesil" in item: return "res://assets/pistol_green.glb"
		if "mavi" in item: return "res://assets/pistol_blue.glb"
		if "turuncu" in item: return "res://assets/pistol_orange.glb"
		if "kırmızı" in item or "kirmizi" in item: return "res://assets/pistol_red.glb"
		return "res://assets/pistol.glb"
	if "pompal" in item: return "res://assets/shotgun.glb"
	if "tüfek" in item or "tufek" in item: return "res://assets/rifle.glb"
	if "arbalet" in item: return "res://assets/crossbow.glb"
	if "mızrak" in item or "mizrak" in item: return "res://assets/spear.glb"
	if "meşale" in item or "mesale" in item: return "res://assets/torch.glb"
	if "yay" in item: return "res://assets/bow.glb"
	if slot==1 or "balta" in item: return "res://assets/stone_axe.glb"
	if slot==2 or "kazma" in item: return "res://assets/stone_pickaxe.glb"
	if slot==4 or "çekiç" in item or "cekic" in item: return "res://assets/building_hammer.glb"
	return ""

func _create_survival_clock(layer:CanvasLayer):
	day_label=Label.new(); day_label.set_anchors_preset(Control.PRESET_TOP_RIGHT); day_label.position=Vector2(-245,12); day_label.size=Vector2(210,32); day_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT; day_label.text="09:00  ☀"; day_label.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(day_label)

func _update_day_cycle(delta:float):
	day_clock=fmod(day_clock+delta*.035,24.0)
	var hour=int(floor(day_clock)); var minute=int(floor((day_clock-hour)*60.0))
	if day_label: day_label.text="%02d:%02d  %s" % [hour,minute,("☀" if hour>=6 and hour<19 else "☾")]
	var night=hour<6 or hour>=19
	var env:Environment=world_env.environment if world_env else null
	if env:
		env.ambient_light_energy=move_toward(env.ambient_light_energy,.28 if night else .72,delta*.08)


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
	if _panel_open(): return
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

func _create_cheat_ui(layer:CanvasLayer):
	cheat_label=Label.new(); cheat_label.position=Vector2(510,10); cheat_label.size=Vector2(260,34); cheat_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; cheat_label.text=""; cheat_label.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(cheat_label)

func _toggle_cheat_mode():
	if _panel_open(): return
	cheat_mode = !cheat_mode
	if cheat_label:
		cheat_label.text = ("HILE ACIK" if cheat_mode else "HILE KAPALI")
	if creative_panel:
		creative_panel.visible = false
	_update_cheat_button_style()
	_flash_message("HILE ACIK" if cheat_mode else "HILE KAPALI")

func _create_creative_menu(layer:CanvasLayer):
	if creative_panel:
		creative_panel.visible = false

func _creative_give(item:String):
	return

func _toggle_fly_mode():
	if _panel_open(): return
	if player==null: return
	var ground=height_at(player.position.x,player.position.z)+PLAYER_HEIGHT
	if not fly_mode:
		fly_mode=true
		player.position.y=maxf(player.position.y,ground)+3.0
	else:
		player.position.y+=3.0
	fly_height=player.position.y
	_update_fly_button_styles()
	_flash_message("UCUS: 1 KADEME YUKSELDI")

func _fly_down():
	if _panel_open(): return
	if not fly_mode or player==null: return
	var ground=height_at(player.position.x,player.position.z)+PLAYER_HEIGHT
	player.position.y=maxf(ground,player.position.y-3.0)
	fly_height=player.position.y
	if player.position.y<=ground+.05:
		player.position.y=ground; fly_mode=false; _update_fly_button_styles(); _flash_message("ZEMINE INILDI")
	else: _flash_message("UCUS: 1 KADEME ALCALDI")

func _update_fly_button_styles() -> void:
	if fly_button:
		var fs=StyleBoxFlat.new()
		fs.bg_color=Color(.12,.58,.20,.92) if fly_mode else Color(.20,.20,.20,.92)
		for k in ["normal","hover","pressed"]: fly_button.add_theme_stylebox_override(k,fs)
	if fly_down_button:
		var ds=StyleBoxFlat.new()
		ds.bg_color=Color(.12,.58,.20,.92) if fly_mode else Color(.20,.20,.20,.92)
		for k in ["normal","hover","pressed"]: fly_down_button.add_theme_stylebox_override(k,ds)

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

func _is_player_loot_allowed(item:Node) -> bool:
	# Boss-only weapons/ammo are internal combat equipment and never enter loot/inventory UI.
	return item==null or not bool(item.get_meta("no_loot_weapon",false))

func metal_scrap() -> int:
	# Placeholder resource hook until scrap loot is added.
	return 9999 if cheat_mode else metal_parts
