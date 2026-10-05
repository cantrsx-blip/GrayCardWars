extends Node3D

const STORE_GRAY_CARD_PNG_B64 := "iVBORw0KGgoAAAANSUhEUgAAAIgAAABoCAYAAAAq/rjQAAAB2ElEQVR42u3SOXJTURiEUe9/AUSEbAEweJasebAkz2YxcDdA/a/q1nPSJzhZR13f2Zev3/7C/5w5AYEgED4pkMPTH4INCOSDYAKhL5CHNiJXHcjjB8EGBPJOMIHQF8i+jchVB3J6J9iAQN4IVgayayNy1YEc3wgmEATCiIFsj68EqwM5vBJMIPQFsmkjcg0I5IVgdSAPLwQTCH2BrNuIXHUg+2eCCYS+QFZtRC6B0BnI7plgZSDL3RPBBIJAGDOQ7RPBykAW20eCCYTOQDaPBCsDmbcRuQYEciKYQOgMZH0iWBnIrI3INSCQI8EEQl8g96sjwQSCQBgzkOWBYGUg0zYil0AQCCMGMlk8EEwgCIQRA7lrI3LVgcz3BBMIAmHEQG5ne4IJhN5AdgQrA7lpI3LVgdzvCCYQegPZEqwM5LqNyFUHMt0STCD0BXI13RCsDmSyIZhAEAgjBnI5WROsDuRuTTCB0BfIRRuRSyB0BnK7IlgZyO82IpdA6AzkZkWwAYEsCVYG8quNyCUQOgO5XhKsDOT8ekEwgSAQxgzkakGwMpCfbUSuAYHMCVYHcjknWBnIjzYil0DoDWRGsDqQixnBykC+txG5BEJvIPcEKwMBgSAQBMIn+Af/KCrcxGyW2QAAAABJRU5ErkJggg=="
const STORE_SLOT_BG := [
	"res://gumus.png",
	"res://zehir.png",
	"res://buz.jpg",
	"res://gunes.png",
	"res://lav.png"
]

func _store_png_texture(path:String) -> Texture2D:
	var loaded = ResourceLoader.load(path)
	if loaded is Texture2D:
		return loaded
	if FileAccess.file_exists(path):
		var bytes := FileAccess.get_file_as_bytes(path)
		if bytes.size() > 0:
			var img := Image.new()
			var err := FAILED
			var low := path.to_lower()
			if low.ends_with(".jpg") or low.ends_with(".jpeg"):
				err = img.load_jpg_from_buffer(bytes)
			else:
				err = img.load_png_from_buffer(bytes)
			if err == OK:
				return ImageTexture.create_from_image(img)
	var img2 := Image.new()
	if img2.load(path) == OK:
		return ImageTexture.create_from_image(img2)
	return null

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
var protection := 100
var health_bar: ProgressBar
var protection_bar: ProgressBar
var health_value_label: Label
var protection_value_label: Label
var hunger := 100.0
var thirst := 100.0
var player: CharacterBody3D
var camera: Camera3D
var player_visual: Node3D
var player_anim: AnimationPlayer
var player_anim_name: StringName = &""
var player_action_locked := false
var player_action_token := 0
var player_action_duration := 0.0
var player_anim_scene: Node3D
var player_anim_cache: Dictionary = {}
var player_skeleton: Skeleton3D
var player_anim_skeleton: Skeleton3D
var camera_yaw := 0.0
var camera_pivot: Node3D
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
var cheat_menu_panel: VBoxContainer
var cheat_weapon_tuner := false
var cheat_muzzle_tuner := false
var cheat_sharpness_tuner := 0
var sharpness_preview_node: Node3D
var sharpness_test_offset := Vector3.ZERO
var sharpness_test_scale := 1.0
var sharpness_test_angle := 0.0
var sharpness1_offsets: Dictionary = {
	"Bıçak":Vector3(0.12,0.03,0.00),"Karambit":Vector3(0.12,0.03,0.00),
	"Katana":Vector3(0.03,-0.06,0.00),"Büyük Kılıç":Vector3(0.03,0.03,0.00),"Kılıç":Vector3(0.06,-0.06,-0.03)
}
var sharpness1_scales: Dictionary = {"Bıçak":1.0,"Karambit":1.0,"Katana":0.90,"Büyük Kılıç":0.90,"Kılıç":1.20}
var sharpness1_angles: Dictionary = {"Bıçak":-100.0,"Karambit":-100.0,"Katana":-80.0,"Büyük Kılıç":-80.0,"Kılıç":-90.0}
var sharpness2_offsets: Dictionary = {
	"Bıçak":Vector3(-0.15,0.60,0.57),"Karambit":Vector3(-0.15,0.60,0.57),
	"Kılıç":Vector3(-0.15,0.60,0.57),"Büyük Kılıç":Vector3(-0.15,0.60,0.57),"Katana":Vector3(-0.15,0.60,0.57)
}
var sharpness2_scales: Dictionary = {"Bıçak":1.0,"Karambit":1.0,"Kılıç":1.4,"Büyük Kılıç":1.4,"Katana":1.4}
var sharpness2_angle := -90.0
var sharpness_test_label: Label
var sharpness_test_controls: Array[Control] = []
var cheat_infinite_weapons := false
var cheat_infinite_gj := false
var cheat_infinite_power := false
var muzzle_preview_node: Node3D
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
var player_weapon_node: Node3D
var weapon_test_rotation := Vector3.ZERO
var weapon_test_position := Vector3.ZERO
var weapon_test_label: Label
var weapon_test_controls: Array[Control] = []
var muzzle_test_offset := Vector3.ZERO
var muzzle_test_scale := 0.38
var muzzle_calibration_frozen := false
var muzzle_offsets: Dictionary = {
	"Pompalı Tüfek":Vector3(0.48,0.06,0.00),
	"Çift Namlulu Pompalı":Vector3(0.50,0.04,0.00),
	"Keskin Nişancı Tüfeği":Vector3(0.54,0.00,0.04)
}
var muzzle_scales: Dictionary = {
	"Pompalı Tüfek":0.68,
	"Çift Namlulu Pompalı":0.73,
	"Keskin Nişancı Tüfeği":0.73
}
var muzzle_test_label: Label
var muzzle_test_controls: Array[Control] = []
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
var look_sensitivity := 0.060
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
var sword_attack_buttons: Array[Button] = []
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

var pois := []

var pits := [
	Vector3(48, 0, -36),
	Vector3(-62, 0, 44),
	Vector3(88, 0, 72),
	Vector3(-90, 0, -70),
	Vector3(20, 0, 95),
	Vector3(-30, 0, -110)
]

# Meteor + level-1 boss encounter
var meteor_node: Node3D
var meteor_hits := 0
var meteor_damage_total := 0
var meteor_hp := 2000
var meteor_hp_label: Label3D
var gj_balance := 0
var gj_drops: Array[Node3D] = []
var meteor_card_drops: Array[Node3D] = []
var collect_button: Button
var meteor_reward_thresholds_claimed: Dictionary = {}
var weapon_levels: Dictionary = {
	"Bıçak":1,"Karambit":1,"Kılıç":1,"Büyük Kılıç":1,"Katana":1,
	"Pompalı Tüfek":1,"Çift Namlulu Pompalı":1,"Keskin Nişancı Tüfeği":1
}
const REWARD_GRID_SIZE := 6.25
var meteor_boss_spawn_count := 0
var meteor_bosses: Array[CharacterBody3D] = []
var boss_attack_cooldowns: Dictionary = {}
const METEOR_DAMAGE_PER_BOSS := 40
const METEOR_HIT_RANGE := 7.0
const BOSS_SPEED := 2.6
const BOSS_ATTACK_RANGE := 1.8
const BOSS_ATTACK_COOLDOWN := 1.0
const BOSS_METEOR_HIT_DAMAGE := 1
const METEOR_ARENA_RADIUS := 17.0
const CENTER_FORBIDDEN_HALF := 4.0
const BOSS_SPAWN_DISTANCE := 15.0
const GOD_WATCHER_DISTANCE := 230.0
const GOD_WATCHER_VISIBLE_HEIGHT := 65.0
var god_watchers: Array[Node3D] = []

# 20 perimeter spawn pads: one human player + 19 harmless combat bots.
var spawn_points: Array[Vector3] = []
var combat_bots: Array[CharacterBody3D] = []
var bot_attack_cooldowns: Dictionary = {}
var bot_anim_players: Dictionary = {}
var bot_weapon_types: Dictionary = {}
var bot_weapon_keys: Dictionary = {}
var bot_weapon_nodes: Dictionary = {}
var bot_visual_skeletons: Dictionary = {}
var bot_anim_scenes: Dictionary = {}
var bot_anim_skeletons: Dictionary = {}
var bot_anim_names: Dictionary = {}
var bot_hp: Dictionary = {}
var bot_loot: Dictionary = {}
var bot_aggro_player: Dictionary = {}
var bot_spawn_index: Dictionary = {}
var bot_roles: Dictionary = {}
var bot_wander_targets: Dictionary = {}
var bot_survivor_ids: Dictionary = {}
var boss_targets: Dictionary = {}
var foundation_position_labels: Array[Label] = []
var cheat_foundation_place := false
var cheat_foundation_remove := false
const BOT_SPEED := 3.4
const BOT_ATTACK_RANGE := 2.2
const BOT_ATTACK_COOLDOWN := 0.55
const BOT_METEOR_RANGE := 4.0
const PLAYER_COMBAT_DAMAGE := 50
const NPC_COMBAT_DAMAGE := 15
const BOSS_COMBAT_DAMAGE := 5
const COMBAT_MAX_HP := 100
const BOSS_MAX_HP := 30

func _ready():
	# Keep scene entry light on Android: show the camera/HUD first, then build the
	# expensive world over several frames instead of blocking the first render.
	_build_player()
	_build_world_environment()
	_build_world_light()
	_build_hud()
	var lobby_cfg=ConfigFile.new()
	if lobby_cfg.load("user://player.cfg")==OK:
		cheat_mode=bool(lobby_cfg.get_value("game","cheat",false))
		var saved_inventory=lobby_cfg.get_value("inventory","crafted",{})
		if saved_inventory is Dictionary: crafted_inventory=saved_inventory
		gj_balance=int(lobby_cfg.get_value("wallet","gj",0))
		var saved_levels=lobby_cfg.get_value("weapons","levels",{})
		if saved_levels is Dictionary:
			for weapon_name in saved_levels:
				if weapon_levels.has(weapon_name): weapon_levels[weapon_name]=clampi(int(saved_levels[weapon_name]),1,100)
		var saved_hotbar=lobby_cfg.get_value("inventory","hotbar",[])
		if saved_hotbar is Array:
			for i in range(mini(6,saved_hotbar.size())): hotbar_items[i]=str(saved_hotbar[i])
	_restore_owned_weapons_to_inventory()
	_sync_cheat_weapons()
	_save_player_inventory()
	_refresh_hotbar()
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

func _spawn_site_vectors() -> Array[Vector2]:
	var edge:=164.0
	var lanes=[-132.0,-66.0,0.0,66.0,132.0]
	var sites:Array[Vector2]=[]
	for x in lanes: sites.append(Vector2(x,-edge))
	for z in lanes: sites.append(Vector2(edge,z))
	for x in lanes: sites.append(Vector2(-x,edge))
	for z in lanes: sites.append(Vector2(-edge,-z))
	return sites

func _trench_cut_amount(x:float,z:float) -> float:
	# Real terrain cut: flat-ish 5.2 m floor plus broad sloped shoulders.
	# The shoulders deliberately stay walkable so player/NPC can leave a trench sideways anywhere.
	var p:=Vector2(x,z)
	var best:float=0.0
	for site in _spawn_site_vectors():
		var radial:=site.length()
		if radial<1.0: continue
		var inward:=(-site).normalized()
		var end:=inward*(METEOR_ARENA_RADIUS+1.5)
		var seg:=end-site
		var len2:=seg.length_squared()
		if len2<=0.001: continue
		var t:=clampf((p-site).dot(seg)/len2,0.0,1.0)
		var closest:=site+seg*t
		var side_dist:=p.distance_to(closest)
		# 2.6 m half-floor, then 4.4 m of gentle bank on each side.
		var cross:float=1.0-smoothstep(2.6,7.0,side_dist)
		# Spawn side enters gently. Meteor side climbs back to natural ground well
		# before the separate black platform. No added ramp meshes: terrain itself
		# is the solid, collision-backed ramp, so there is no hollow space below it.
		var spawn_ramp:float=smoothstep(0.0,.055,t)
		var meteor_ramp:float=1.0-smoothstep(.72,.86,t)
		var along:float=spawn_ramp*meteor_ramp
		best=maxf(best,cross*along)
	return best

func height_at(_x: float, _z: float) -> float:
	var h:=0.0
	var sites:=_spawn_site_vectors()
	var here:=Vector2(_x,_z)
	for site in sites:
		var d:=here.distance_to(site)
		# Smooth bowl in the middle, then an irregular natural earth ring around it.
		if d<15.0:
			var bowl:float=-2.2*(1.0-smoothstep(0.0,9.0,d))
			var ring:float=0.0
			if d>7.0:
				var rt:float=1.0-absf(d-11.0)/4.0
				ring=maxf(0.0,rt)*(1.15+0.35*sin(_x*.31+_z*.23))
			h+=bowl+ring
	# Cut the actual terrain, not a hidden floor under an unchanged surface.
	h-=2.15*_trench_cut_amount(_x,_z)
	return h

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

func _weapon_glb_path(key:String) -> String:
	if "|" not in key: return ""
	var parts=key.split("|")
	if parts.size()<2: return ""
	var item=str(parts[0]); var rarity=str(parts[1])
	# Store/inventory uses "yesil" internally; the final 3D weapon files use "zehir".
	if rarity=="yesil": rarity="zehir"
	var names={
		"Bıçak":"bicak","Karambit":"karambit","Kılıç":"kilic","Büyük Kılıç":"buyuk_kilic","Katana":"katana",
		"Pompalı Tüfek":"pompali","Çift Namlulu Pompalı":"cift_pompali","Keskin Nişancı Tüfeği":"nisanci"
	}
	if not names.has(item): return ""
	return "res://assets/weapons3d/%s_%s.glb" % [rarity,str(names[item])]

func _right_hand_attachment(skeleton:Skeleton3D) -> BoneAttachment3D:
	if skeleton==null: return null
	var old=skeleton.get_node_or_null("WeaponRightHand")
	if old is BoneAttachment3D: return old
	var bone_name:=""
	for candidate in ["mixamorig_RightHand","RightHand","right_hand","hand_r","Hand.R"]:
		if skeleton.find_bone(candidate)>=0: bone_name=candidate; break
	if bone_name.is_empty(): return null
	var attachment=BoneAttachment3D.new()
	attachment.name="WeaponRightHand"
	attachment.bone_name=bone_name
	skeleton.add_child(attachment)
	return attachment

func _attach_weapon_to_skeleton(skeleton:Skeleton3D,key:String,use_live_tuner:bool=false) -> Node3D:
	var path:=_weapon_glb_path(key)
	if path.is_empty() or not ResourceLoader.exists(path): return null
	var attachment:=_right_hand_attachment(skeleton)
	if attachment==null: return null
	for child in attachment.get_children(): child.queue_free()
	var weapon:=_load_asset(path)
	if weapon==null: return null
	attachment.add_child(weapon)
	var item=str(key.split("|")[0])
	var grip={
		"Bıçak":{"length":0.62,"pos":Vector3(0.02,-0.01,-0.01),"rot":Vector3(0,90,-90)},
		"Karambit":{"length":0.58,"pos":Vector3(0.015,-0.005,-0.015),"rot":Vector3(0,90,-90)},
		"Kılıç":{"length":1.18,"pos":Vector3(0.03,-0.035,-0.055),"rot":Vector3(0,90,-90)},
		"Büyük Kılıç":{"length":1.38,"pos":Vector3(0.03,-0.045,-0.075),"rot":Vector3(0,90,-90)},
		"Katana":{"length":1.24,"pos":Vector3(0.025,-0.035,-0.06),"rot":Vector3(0,90,-90)},
		"Pompalı Tüfek":{"length":1.02,"pos":Vector3(0.02,-0.055,-0.13),"rot":Vector3(0,-90,-90)},
		"Çift Namlulu Pompalı":{"length":1.00,"pos":Vector3(0.02,-0.055,-0.13),"rot":Vector3(0,-90,-90)},
		"Keskin Nişancı Tüfeği":{"length":1.16,"pos":Vector3(0.02,-0.06,-0.15),"rot":Vector3(0,-90,-90)}
	}
	var calibrated={
		"Bıçak":{"pos":Vector3(0.10,0.20,0.02),"rot":Vector3(-150,30,0)},
		"Karambit":{"pos":Vector3(0.10,0.20,0.02),"rot":Vector3(-150,30,0)},
		"Kılıç":{"pos":Vector3(-0.04,0.46,0.06),"rot":Vector3(-180,30,0)},
		"Büyük Kılıç":{"pos":Vector3(0.02,0.50,0.08),"rot":Vector3(-180,-60,0)},
		"Katana":{"pos":Vector3(0.02,0.50,0.08),"rot":Vector3(-180,-60,0)},
		"Pompalı Tüfek":{"pos":Vector3(-0.10,0.48,0.16),"rot":Vector3(-180,45,0)},
		"Çift Namlulu Pompalı":{"pos":Vector3(0.04,0.42,0.14),"rot":Vector3(-180,75,0)},
		"Keskin Nişancı Tüfeği":{"pos":Vector3(0.02,0.42,0.12),"rot":Vector3(-180,120,0)}
	}
	var g=grip.get(item,{"length":0.9,"pos":Vector3.ZERO,"rot":Vector3.ZERO})
	# Normalize every GLB by its real visual bounds first. This keeps all five rarities
	# of a weapon type consistent even when their source exports use different units.
	var wb=_node_visual_bounds(weapon)
	var longest=maxf(wb.size.x,maxf(wb.size.y,wb.size.z))
	var scale_value=float(g.length)/longest if longest>0.001 else 0.5
	weapon.scale=Vector3.ONE*scale_value
	var cal=calibrated.get(item,{"pos":Vector3.ZERO,"rot":Vector3.ZERO})
	weapon.position=g.pos-(wb.get_center()*scale_value)+cal.pos
	weapon.rotation_degrees=g.rot+cal.rot
	if use_live_tuner and cheat_mode and cheat_weapon_tuner:
		weapon.position+=weapon_test_position
		weapon.rotation_degrees+=weapon_test_rotation
	return weapon

func _weapon_test_rotate(delta_rotation:Vector3) -> void:
	weapon_test_rotation+=delta_rotation
	weapon_test_rotation.x=fposmod(weapon_test_rotation.x+180.0,360.0)-180.0
	weapon_test_rotation.y=fposmod(weapon_test_rotation.y+180.0,360.0)-180.0
	weapon_test_rotation.z=fposmod(weapon_test_rotation.z+180.0,360.0)-180.0
	_update_weapon_test_label()
	_refresh_player_weapon_model()

func _weapon_test_move(delta_position:Vector3) -> void:
	weapon_test_position+=delta_position
	_update_weapon_test_label()
	_refresh_player_weapon_model()

func _update_weapon_test_label() -> void:
	if weapon_test_label:
		weapon_test_label.text="SİLAH TEST X:%d° Y:%d° Z:%d°  KONUM X:%.2f Y:%.2f Z:%.2f" % [roundi(weapon_test_rotation.x),roundi(weapon_test_rotation.y),roundi(weapon_test_rotation.z),weapon_test_position.x,weapon_test_position.y,weapon_test_position.z]

func _refresh_player_weapon_model() -> void:
	if player_skeleton==null: return
	var key:=""
	for hotkey in hotbar_items:
		if _hotbar_item_title(str(hotkey))==selected_tool:
			key=str(hotkey); break
	var attachment:=_right_hand_attachment(player_skeleton)
	if attachment:
		for child in attachment.get_children(): child.queue_free()
	player_weapon_node=_attach_weapon_to_skeleton(player_skeleton,key,true) if not key.is_empty() else null
	_load_muzzle_calibration()
	_preview_muzzle_flash()
	_preview_sharpness()

func _find_skeleton(node:Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child in node.get_children():
		var found:=_find_skeleton(child)
		if found!=null: return found
	return null

func _copy_ybot_pose() -> void:
	if player_skeleton==null or player_anim_skeleton==null: return
	for i in range(player_skeleton.get_bone_count()):
		var bone_name:=player_skeleton.get_bone_name(i)
		var source_i:=player_anim_skeleton.find_bone(bone_name)
		if source_i<0: continue
		player_skeleton.set_bone_pose_position(i,player_anim_skeleton.get_bone_pose_position(source_i))
		player_skeleton.set_bone_pose_rotation(i,player_anim_skeleton.get_bone_pose_rotation(source_i))
		player_skeleton.set_bone_pose_scale(i,player_anim_skeleton.get_bone_pose_scale(source_i))
	_apply_crouch_pose()

func _process(_delta:float) -> void:
	_copy_ybot_pose()
	_update_collect_button_visibility()

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

func _ground_color(h:float, z:float=0.0, x:float=0.0)->Color:
	var cut:=_trench_cut_amount(x,z)
	if cut>0.08:
		return Color.WHITE.lerp(Color(.34,.21,.10),clampf(cut,0.0,1.0))
	# Keep z13.jpg as the terrain texture, but tint the whole map with broad,
	# softly blended earth patches so the ground is not one flat color.
	var broad:=sin(x*.031+sin(z*.017)*1.7)+cos(z*.027-x*.011)
	var detail:=sin((x+z)*.071)*.45+cos((x-z)*.053)*.35
	var v:=clampf((broad+detail+2.5)/5.0,0.0,1.0)
	var earth_a:=Color(.72,.64,.49)
	var earth_b:=Color(.53,.48,.38)
	var tint:=earth_a.lerp(earth_b,v)
	var strength:=.16+.10*absf(sin(x*.014)*cos(z*.018))
	return Color.WHITE.lerp(tint,strength)

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
			st.set_color(_ground_color(a.y,a.z,a.x)); st.set_uv(Vector2(x0/8.0,z0/8.0)); st.add_vertex(a)
			st.set_color(_ground_color(b.y,b.z,b.x)); st.set_uv(Vector2(x1/8.0,z0/8.0)); st.add_vertex(b)
			st.set_color(_ground_color(cc.y,cc.z,cc.x)); st.set_uv(Vector2(x1/8.0,z1/8.0)); st.add_vertex(cc)
			st.set_color(_ground_color(a.y,a.z,a.x)); st.set_uv(Vector2(x0/8.0,z0/8.0)); st.add_vertex(a)
			st.set_color(_ground_color(cc.y,cc.z,cc.x)); st.set_uv(Vector2(x1/8.0,z1/8.0)); st.add_vertex(cc)
			st.set_color(_ground_color(d.y,d.z,d.x)); st.set_uv(Vector2(x0/8.0,z1/8.0)); st.add_vertex(d)
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
	mat.albedo_color=Color.WHITE; mat.roughness=.96; mat.vertex_color_use_as_albedo=true
	mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mat.texture_repeat=true
	if ResourceLoader.exists(path):
		var tex=ResourceLoader.load(path)
		if tex is Texture2D: mat.albedo_texture=tex
	return mat

func _build_terrain_mesh() -> void:
	var mesh=_terrain_visual_mesh(128)
	var terrain_material=_terrain_material("res://z13.jpg")
	if mesh.get_surface_count()>0: mesh.surface_set_material(0,terrain_material)
	var terrain=MeshInstance3D.new(); terrain.name="Terrain"; terrain.mesh=mesh; add_child(terrain)
	var collision_mesh=_terrain_surface(128)
	var body=StaticBody3D.new(); body.name="TerrainCollision"
	var cs=CollisionShape3D.new(); cs.shape=collision_mesh.create_trimesh_shape(); body.add_child(cs); add_child(body)

func _build_center_settlement_mound() -> void:
	var body=StaticBody3D.new(); body.name="CenterSettlementMound"; body.position=Vector3(0,0.18,0); add_child(body)
	var mesh=MeshInstance3D.new(); var cylinder=CylinderMesh.new(); cylinder.top_radius=18.0; cylinder.bottom_radius=19.0; cylinder.height=0.36; cylinder.radial_segments=64; mesh.mesh=cylinder
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.015,.015,.018); mat.roughness=1.0; mesh.material_override=mat; body.add_child(mesh)
	var cs=CollisionShape3D.new(); var shape=CylinderShape3D.new(); shape.radius=19.0; shape.height=0.36; cs.shape=shape; body.add_child(cs)

func _build_meteor_encounter() -> void:
	if meteor_node!=null and is_instance_valid(meteor_node): return
	meteor_node=_load_asset("res://meteor.glb")
	if meteor_node==null: return
	meteor_node.name="MeteorEncounter"
	add_child(meteor_node)
	meteor_node.position=Vector3(0,0.36,0)
	meteor_hp=2000; meteor_damage_total=0
	_ground_asset_to_terrain(meteor_node,0,0)
	# Restore the previous meteor scale.
	var bounds:=_node_visual_bounds(meteor_node)
	if bounds.size.y>0.001:
		var target_h:=PLAYER_HEIGHT*8.0
		meteor_node.scale*=target_h/bounds.size.y
		_ground_asset_to_terrain(meteor_node,0,0)
	# HP label is a world-space sibling, not a child of the scaled meteor model.
	# This keeps its height/size stable and visible from normal ground-level play.
	var scaled_bounds:=_node_visual_bounds(meteor_node)
	meteor_hp_label=Label3D.new()
	meteor_hp_label.name="MeteorHP"
	meteor_hp_label.position=Vector3(meteor_node.position.x,scaled_bounds.position.y+scaled_bounds.size.y+1.25,meteor_node.position.z)
	meteor_hp_label.font_size=42
	meteor_hp_label.outline_size=7
	meteor_hp_label.pixel_size=.008
	meteor_hp_label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
	add_child(meteor_hp_label)
	_update_meteor_hp_label()
	# Solid meteor collision: player and CharacterBody3D bosses cannot pass through it.
	var solid=StaticBody3D.new()
	solid.name="MeteorSolidCollision"
	var cs=CollisionShape3D.new()
	var shape=CylinderShape3D.new()
	var final_bounds:=_node_visual_bounds(meteor_node)
	# One solid safety volume around the complete meteor footprint. The player stops
	# before the visual mesh, so the camera can never enter and expose back faces.
	var meteor_radius:=maxf(final_bounds.size.x,final_bounds.size.z)*0.62
	shape.radius=maxf(2.0,meteor_radius)
	shape.height=maxf(2.0,final_bounds.size.y*1.05)
	cs.shape=shape
	cs.position=Vector3(0,shape.height*0.5,0)
	solid.add_child(cs)
	solid.position=meteor_node.global_position
	add_child(solid)


func _node_visual_bounds(root:Node3D) -> AABB:
	var first:=true
	var result:=AABB()
	var stack:Array[Node]=[root]
	while not stack.is_empty():
		var n=stack.pop_back()
		if n is MeshInstance3D and n.mesh!=null:
			var b:AABB=n.mesh.get_aabb()
			var t:Transform3D=root.global_transform.affine_inverse()*n.global_transform
			b=t*b
			result=b if first else result.merge(b); first=false
		for c in n.get_children(): stack.append(c)
	return result

func _finish_attack_animation(_delay:float=.65) -> void:
	player_action_token+=1
	var attack_token:=player_action_token
	player_action_locked=true
	var real_duration:=maxf(player_action_duration,0.10)
	await get_tree().create_timer(real_duration).timeout
	if player_action_token==attack_token:
		player_action_locked=false
		player_anim_name=&""

func _is_sword_equipped() -> bool:
	var item:=selected_tool.to_lower()
	return ("kılıç" in item or "kilic" in item or "katana" in item)

func _sword_attack(anim_name:String) -> void:
	if _panel_open() or player==null or not _is_sword_equipped(): return
	_play_ybot_anim(anim_name)
	_spawn_melee_sharpness(_selected_weapon_key())
	_meteor_strike()
	_finish_attack_animation(.75)

func _sword_attack_1() -> void: _sword_attack("Great Sword Slash (1)")
func _sword_attack_2() -> void: _sword_attack("Great Sword Slash")
func _sword_attack_3() -> void: _sword_attack("Sword Fight One")

func _update_sword_attack_buttons(show_buttons:bool) -> void:
	for button in sword_attack_buttons:
		if is_instance_valid(button): button.visible=show_buttons

func _player_attack() -> void:
	if _panel_open() or player==null: return
	if build_mode or (cheat_mode and cheat_foundation_place):
		var place_pos:Vector3=player.global_position+player_facing.normalized()*5.0
		place_pos.y=height_at(place_pos.x,place_pos.z)
		var layers=get_children().filter(func(n): return n is CanvasLayer)
		if layers.size()>0:
			_register_ground_foundation(place_pos,layers[-1])
			_flash_message("TEMEL %d  X:%.1f Y:%.1f Z:%.1f" % [built_floors.size(),place_pos.x,place_pos.y,place_pos.z])
		return
	if cheat_mode and cheat_foundation_remove:
		var best:Node3D=null
		var best_d:float=7.0
		var aim:Vector3=player.global_position+player_facing.normalized()*5.0
		for foundation in built_floors:
			if not is_instance_valid(foundation): continue
			var d:float=Vector2(foundation.global_position.x-aim.x,foundation.global_position.z-aim.z).length()
			if d<best_d: best_d=d; best=foundation
		if best:
			built_floors.erase(best); best.queue_free()
			var layers=get_children().filter(func(n): return n is CanvasLayer)
			if layers.size()>0: _refresh_foundation_position_labels(layers[-1])
			_flash_message("TEMEL KALDIRILDI")
		else: _flash_message("KALDIRILACAK TEMEL YAKINDA DEĞİL")
		return
	var item:=selected_tool.to_lower()
	var firearm=("pompal" in item or "tüfek" in item or "tufek" in item or "nişancı" in item or "nisanci" in item)
	var knife=("bıçak" in item or "bicak" in item or "karambit" in item)
	var sword=("kılıç" in item or "kilic" in item or "katana" in item)
	if (knife or sword) and cheat_mode and cheat_sharpness_tuner>0:
		if muzzle_calibration_frozen:
			muzzle_calibration_frozen=false; player_action_locked=false; player_anim_name=&""
			if player_anim and is_instance_valid(player_anim): player_anim.play()
		else:
			_play_ybot_anim("Stabbing" if knife else "Stable Sword Outward Slash")
			player_action_token+=1; player_action_locked=true; muzzle_calibration_frozen=true
			await get_tree().create_timer(maxf(.08,minf(player_action_duration*.42,.28))).timeout
			if player_anim and is_instance_valid(player_anim): player_anim.pause()
		_update_sharpness_label(); _preview_sharpness()
		return
	if firearm and cheat_mode and cheat_muzzle_tuner:
		if muzzle_calibration_frozen:
			muzzle_calibration_frozen=false; player_action_locked=false; player_anim_name=&""
		else:
			_play_ybot_anim("Firing Rifle")
			player_action_token+=1; player_action_locked=true; muzzle_calibration_frozen=true
			await get_tree().create_timer(maxf(.08,minf(player_action_duration*.42,.28))).timeout
			if player_anim and is_instance_valid(player_anim):
				player_anim.pause()
		_update_muzzle_test_label(); _preview_muzzle_flash()
		return
	if firearm:
		_play_ybot_anim("Firing Rifle"); _play_sfx("gun"); _muzzle_flash()
	elif knife:
		_play_ybot_anim("Stabbing"); _spawn_melee_sharpness(_selected_weapon_key())
	elif sword:
		_play_ybot_anim("Stable Sword Outward Slash"); _spawn_melee_sharpness(_selected_weapon_key())
	else: _play_ybot_anim("Stabbing")
	_meteor_strike()
	_finish_attack_animation(.30)

func _weapon_level(item:String) -> int:
	var selected_key:=_selected_weapon_key()
	if not selected_key.is_empty() and str(selected_key.split("|")[0])==item and weapon_levels.has(selected_key):
		return clampi(int(weapon_levels.get(selected_key,1)),1,100)
	return clampi(int(weapon_levels.get(item,1)),1,100)

func _weapon_level_for_key(key:String) -> int:
	if key.is_empty(): return 1
	if weapon_levels.has(key): return clampi(int(weapon_levels.get(key,1)),1,100)
	var item:=str(key.split("|")[0])
	return clampi(int(weapon_levels.get(item,1)),1,100)

func _melee_total_damage(item:String) -> int:
	var base:Dictionary={"Bıçak":10,"Karambit":15,"Kılıç":20,"Büyük Kılıç":25,"Katana":30}
	var level:=100 if cheat_mode and cheat_infinite_power else _weapon_level(item)
	var milestone:=level/5
	return int(base.get(item,10))+milestone*2

func _melee_range(item:String) -> float:
	var ranges:Dictionary={"Bıçak":1.50,"Karambit":1.65,"Kılıç":1.90,"Büyük Kılıç":2.20,"Katana":2.50}
	return float(ranges.get(item,1.50))

func _distance_table_value(item:String,distance:float) -> int:
	var values:Array
	if item=="Keskin Nişancı Tüfeği":
		if scope_stage<=1: values=[15,17,19,20,22,23]
		elif scope_stage==2: values=[25,29,31,33,36,38]
		else: values=[50,57,62,66,71,75]
	elif item=="Çift Namlulu Pompalı":
		values=[7,13,20,32,50,70]
	else:
		values=[5,10,15,25,40,55]
	var max_value:int
	if distance>=483.0: max_value=int(values[0])
	elif distance>=350.0: max_value=int(values[1])
	elif distance>=250.0: max_value=int(values[2])
	elif distance>=150.0: max_value=int(values[3])
	elif distance>=50.0: max_value=int(values[4])
	else: max_value=int(values[5])
	var level:=100 if cheat_mode and cheat_infinite_power else _weapon_level(item)
	var band:=level/5
	if level<5: band=0
	if level>=100: return max_value
	# Damage only changes at 5/10/15... milestones. Level 95-99 is the penultimate band.
	var factor:=float(band+1)/21.0
	return maxi(1,roundi(float(max_value)*factor))

func _firearm_pool_damage(item:String,distance:float) -> int:
	return _distance_table_value(item,distance)

func _firearm_target_hit(item:String) -> void:
	if camera==null or player==null: return
	var center=get_viewport().get_visible_rect().size*.5
	var origin=camera.project_ray_origin(center)
	var dir=camera.project_ray_normal(center)
	var q=PhysicsRayQueryParameters3D.create(origin,origin+dir*600.0)
	q.exclude=[player]
	var hit=get_world_3d().direct_space_state.intersect_ray(q)
	if hit.is_empty(): return
	var collider:Node=hit.get("collider",null)
	if collider==null: return
	var distance:=origin.distance_to(hit.position)
	var pool_damage:=_firearm_pool_damage(item,distance)
	var total_damage:=pool_damage*2
	if collider in combat_bots:
		_damage_combat_bot(collider,total_damage,true)
		_show_hit_marker()
	elif collider in meteor_bosses:
		var hp:int=int(collider.get_meta("hp",BOSS_MAX_HP))-total_damage
		collider.set_meta("hp",hp); boss_targets[collider.get_instance_id()]=player; _show_hit_marker()
		if hp<=0:
			_spawn_local_kill_sharpness(); boss_targets.erase(collider.get_instance_id()); meteor_bosses.erase(collider); boss_attack_cooldowns.erase(collider.get_instance_id()); collider.queue_free()

func _meteor_is_under_crosshair() -> bool:
	if camera==null or meteor_node==null or not is_instance_valid(meteor_node): return false
	var center:=get_viewport().get_visible_rect().size*.5
	var origin:=camera.project_ray_origin(center)
	var dir:=camera.project_ray_normal(center)
	var to_meteor:Vector3=meteor_node.global_position-origin
	var forward:float=to_meteor.dot(dir)
	if forward<0.0 or forward>600.0: return false
	# Use the meteor's physical footprint instead of its pivot point. The old 55 px
	# center test could reject a shot even while the visible meteor filled the crosshair.
	var closest:Vector3=origin+dir*forward
	var bounds:=_node_visual_bounds(meteor_node)
	var hit_radius:float=maxf(3.0,maxf(bounds.size.x,bounds.size.z)*.58)
	return closest.distance_to(meteor_node.global_position)<=hit_radius

func _meteor_strike() -> void:
	if _panel_open() or player==null: return
	var key:=_selected_weapon_key()
	var item:=str(key.split("|")[0]) if not key.is_empty() else ""
	var firearm:=item in ["Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
	if firearm:
		_firearm_target_hit(item)
	else:
		_hit_nearby_combat_bot()
		_hit_nearby_meteor_boss()
	if meteor_node==null or not is_instance_valid(meteor_node): return
	var distance:=player.global_position.distance_to(meteor_node.global_position)
	if firearm:
		if distance>600.0 or not _meteor_is_under_crosshair(): return
	else:
		# Meteor is physically much wider than its center pivot. Give melee the visible
		# meteor surface radius plus the weapon reach, instead of measuring to the center.
		var meteor_bounds:=_node_visual_bounds(meteor_node)
		var meteor_radius:float=maxf(2.0,maxf(meteor_bounds.size.x,meteor_bounds.size.z)*.50)
		if distance>meteor_radius+_melee_range(item): return
	meteor_hits+=1
	var damage:=_current_meteor_damage()
	_apply_meteor_damage(damage)
	if gather_label:
		gather_label.text="METEOR %d/2000 HP  •  +%d GJ" % [meteor_hp,damage]
		gather_label.visible=true; message_time=1.2

func _current_meteor_damage() -> int:
	var key:=_selected_weapon_key()
	if key.is_empty(): return 1
	var item:=str(key.split("|")[0])
	if item in ["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana"]:
		return maxi(1,_melee_total_damage(item))
	var distance:=player.global_position.distance_to(meteor_node.global_position) if player and meteor_node else 566.0
	return maxi(1,_firearm_pool_damage(item,distance)*2)

func _apply_meteor_damage(amount:int) -> void:
	if amount<=0: return
	var actual:=mini(amount,meteor_hp)
	var before:=meteor_damage_total
	meteor_hp-=actual
	meteor_damage_total+=actual
	_spawn_gj_drop(actual)
	_process_meteor_card_rewards(before,meteor_damage_total)
	var old_wave:=before/METEOR_DAMAGE_PER_BOSS
	var new_wave:=meteor_damage_total/METEOR_DAMAGE_PER_BOSS
	for i in range(old_wave,new_wave): _spawn_meteor_boss()
	_update_meteor_hp_label()
	if meteor_hp<=0:
		meteor_hp=2000
		meteor_damage_total=0
		meteor_reward_thresholds_claimed.clear()
		_update_meteor_hp_label()

func _spawn_gj_drop(amount:int) -> void:
	if amount<=0 or meteor_node==null: return
	var root=Node3D.new(); root.name="GJDrop_%d" % Time.get_ticks_msec(); add_child(root)
	var angle:=randf()*TAU
	var radius:=randf_range(METEOR_ARENA_RADIUS*.55,METEOR_ARENA_RADIUS*.92)
	root.global_position=meteor_node.global_position+Vector3(cos(angle)*radius,1.0,sin(angle)*radius)
	root.set_meta("gj_amount",amount)
	var coin=MeshInstance3D.new(); var mesh=CylinderMesh.new(); mesh.top_radius=.28; mesh.bottom_radius=.28; mesh.height=.10; coin.mesh=mesh; coin.rotation_degrees.x=90; root.add_child(coin)
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.45,.45,.48); mat.metallic=.85; mat.roughness=.25; coin.material_override=mat
	var label=Label3D.new(); label.text="%d GJ" % amount; label.position=Vector3(0,.55,0); label.font_size=48; label.outline_size=8; label.billboard=BaseMaterial3D.BILLBOARD_ENABLED; root.add_child(label)
	gj_drops.append(root)

func _spawn_card_drop(item:String,rarity:String,amount:int=1) -> void:
	if meteor_node==null or amount<=0: return
	var root=Node3D.new(); root.name="CardDrop_%s_%s" % [item,rarity]; add_child(root)
	var angle:=randf()*TAU
	var radius:=randf_range(METEOR_ARENA_RADIUS*.55,METEOR_ARENA_RADIUS*.92)
	root.global_position=meteor_node.global_position+Vector3(cos(angle)*radius,.55,sin(angle)*radius)
	var card_key:="%s|%s" % [item,rarity] if item=="Kart" else "Kart:%s|%s" % [item,rarity]
	root.set_meta("card_key",card_key); root.set_meta("card_amount",amount)
	var mesh_node=MeshInstance3D.new(); var mesh=BoxMesh.new(); mesh.size=Vector3(.42,.58,.06); mesh_node.mesh=mesh; root.add_child(mesh_node)
	var colors:Dictionary={"gumus":Color(.78,.82,.86),"yesil":Color(.12,.82,.24),"buz":Color(.18,.58,1.0),"gunes":Color(1.0,.72,.08),"lav":Color(.95,.08,.04)}
	var mat=StandardMaterial3D.new(); mat.albedo_color=colors.get(rarity,Color.WHITE); mat.metallic=.35; mesh_node.material_override=mat
	var label=Label3D.new(); label.text="%s x%d" % [item,amount]; label.position=Vector3(0,.48,0); label.font_size=34; label.outline_size=6; label.billboard=BaseMaterial3D.BILLBOARD_ENABLED; root.add_child(label)
	meteor_card_drops.append(root)

func _drop_five_rarity_cards(item:String,amount_each:int=1) -> void:
	for rarity in ["gumus","yesil","buz","gunes","lav"]: _spawn_card_drop(item,rarity,amount_each)

func _process_meteor_card_rewards(before:int,after:int) -> void:
	var rewards:Dictionary={400:"Bıçak",600:"Karambit",800:"Kılıç",1000:"Büyük Kılıç",1200:"Katana",1400:"Pompalı Tüfek",1600:"Çift Namlulu Pompalı",1800:"Keskin Nişancı Tüfeği"}
	for threshold in [200,400,600,800,1000,1200,1400,1600,1800,2000]:
		if before<threshold and after>=threshold and not meteor_reward_thresholds_claimed.has(threshold):
			meteor_reward_thresholds_claimed[threshold]=true
			if threshold==200:
				for rarity in ["gumus","yesil","buz","gunes","lav"]: _spawn_card_drop("Kart",rarity,1)
			elif threshold==2000:
				for weapon_name in ["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]:
					_drop_five_rarity_cards(weapon_name,1)
			else:
				_drop_five_rarity_cards(str(rewards[threshold]),1)

func _same_reward_square(a:Vector3,b:Vector3) -> bool:
	return floori(a.x/REWARD_GRID_SIZE)==floori(b.x/REWARD_GRID_SIZE) and floori(a.z/REWARD_GRID_SIZE)==floori(b.z/REWARD_GRID_SIZE)

func _reward_in_player_square() -> bool:
	if player==null: return false
	for drop in gj_drops:
		if is_instance_valid(drop) and _same_reward_square(player.global_position,drop.global_position): return true
	for drop in meteor_card_drops:
		if is_instance_valid(drop) and _same_reward_square(player.global_position,drop.global_position): return true
	return false

func _update_collect_button_visibility() -> void:
	if collect_button: collect_button.visible=_reward_in_player_square()

func _collect_reward_square() -> void:
	if player==null: return
	var gj_collected:=0; var cards_collected:=0
	for drop in gj_drops.duplicate():
		if is_instance_valid(drop) and _same_reward_square(player.global_position,drop.global_position):
			gj_collected+=int(drop.get_meta("gj_amount",0)); gj_drops.erase(drop); drop.queue_free()
	for drop in meteor_card_drops.duplicate():
		if is_instance_valid(drop) and _same_reward_square(player.global_position,drop.global_position):
			var key:=str(drop.get_meta("inventory_key",drop.get_meta("card_key",""))); var amount:=int(drop.get_meta("card_amount",1))
			if not key.is_empty(): crafted_inventory[key]=int(crafted_inventory.get(key,0))+amount; cards_collected+=amount
			meteor_card_drops.erase(drop); drop.queue_free()
	gj_balance+=gj_collected
	_save_player_inventory()
	_flash_message("TOPLANDI  +%d GJ  +%d KART" % [gj_collected,cards_collected])

func _update_meteor_hp_label() -> void:
	if meteor_hp_label==null: return
	meteor_hp_label.text="METEOR  %d / 2000 HP" % meteor_hp
	var ratio:float=clampf(float(meteor_hp)/2000.0,0.0,1.0)
	if ratio>0.75: meteor_hp_label.modulate=Color(.10,.55,1.0)
	elif ratio>0.50: meteor_hp_label.modulate=Color(.20,.85,1.0)
	elif ratio>0.25: meteor_hp_label.modulate=Color(1.0,.85,.08)
	elif ratio>0.10: meteor_hp_label.modulate=Color(1.0,.38,.04)
	else: meteor_hp_label.modulate=Color(1.0,.04,.04)

func _spawn_meteor_boss() -> void:
	var model=_load_asset("res://1.sv.boss.glb")
	if model==null: return
	var boss=CharacterBody3D.new(); boss.name="MeteorBoss_%d" % (meteor_boss_spawn_count+1)
	# Keep N/S/E/W order, but fan repeated spawns sideways so bosses never stack inside each other.
	var direction_index:int=meteor_boss_spawn_count%4
	var wave:int=meteor_boss_spawn_count/4
	var lateral:float=0.0
	if wave>0:
		var step:int=(wave+1)/2
		lateral=float(step)*3.5*(1.0 if wave%2==1 else -1.0)
	var base_positions=[
		Vector3(0,PLAYER_HEIGHT,-BOSS_SPAWN_DISTANCE),
		Vector3(0,PLAYER_HEIGHT,BOSS_SPAWN_DISTANCE),
		Vector3(BOSS_SPAWN_DISTANCE,PLAYER_HEIGHT,0),
		Vector3(-BOSS_SPAWN_DISTANCE,PLAYER_HEIGHT,0)
	]
	var spawn_pos:Vector3=base_positions[direction_index]
	if direction_index<2: spawn_pos.x+=lateral
	else: spawn_pos.z+=lateral
	boss.position=spawn_pos
	meteor_boss_spawn_count+=1
	var cs=CollisionShape3D.new(); var shape=CapsuleShape3D.new(); shape.radius=.55; shape.height=1.9; cs.shape=shape; boss.add_child(cs)
	boss.add_child(model); model.position=Vector3.ZERO
	model.rotation_degrees.y=180.0
	var bounds=_node_visual_bounds(model)
	if bounds.size.y>0.001: model.scale*=2.0/bounds.size.y
	boss.set_meta("hp",BOSS_MAX_HP); add_child(boss); meteor_bosses.append(boss)
	boss_attack_cooldowns[boss.get_instance_id()]=0.0
	boss_targets[boss.get_instance_id()]=null
	_play_boss_anim(boss,"Idle")

func _play_boss_anim(boss:Node3D,wanted:String) -> void:
	var ap=_find_animation_player(boss)
	if ap==null: return
	var anim=_find_animation_name(ap,wanted)
	if anim!=&"" and ap.current_animation!=str(anim): ap.play(anim)

func _update_meteor_bosses(delta:float) -> void:
	if player==null: return
	for boss in meteor_bosses.duplicate():
		if not is_instance_valid(boss): meteor_bosses.erase(boss); continue
		var id:int=boss.get_instance_id()
		var cd:float=maxf(0.0,float(boss_attack_cooldowns.get(id,0.0))-delta); boss_attack_cooldowns[id]=cd
		# Bosses are hostile to everyone currently inside the meteor arena.
		# Re-evaluate every frame instead of permanently locking onto the player or first attacker.
		var target:Node3D=null
		var best:float=INF
		var player_flat:=Vector2(player.global_position.x,player.global_position.z)
		if player_flat.length()<=METEOR_ARENA_RADIUS:
			best=boss.global_position.distance_to(player.global_position); target=player
		for candidate in combat_bots:
			if not is_instance_valid(candidate): continue
			var cf:=Vector2(candidate.global_position.x,candidate.global_position.z)
			if cf.length()>METEOR_ARENA_RADIUS: continue
			var d_to:float=boss.global_position.distance_to(candidate.global_position)
			if d_to<best: best=d_to; target=candidate
		boss_targets[id]=target
		if target==null:
			boss.velocity=Vector3.ZERO; _play_boss_anim(boss,"Idle"); continue
		var d:Vector3=target.global_position-boss.global_position; d.y=0.0
		var dist:float=d.length()
		if dist>0.01: boss.look_at(Vector3(target.global_position.x,boss.global_position.y,target.global_position.z),Vector3.UP)
		if dist>BOSS_ATTACK_RANGE:
			boss.velocity=d.normalized()*BOSS_SPEED if dist>0.01 else Vector3.ZERO
			boss.velocity.y=0.0; boss.move_and_slide()
			var arena_pos:=Vector2(boss.global_position.x,boss.global_position.z)
			if arena_pos.length()>METEOR_ARENA_RADIUS:
				arena_pos=arena_pos.normalized()*METEOR_ARENA_RADIUS
				boss.global_position.x=arena_pos.x; boss.global_position.z=arena_pos.y
			_play_boss_anim(boss,"Run" if dist>6.0 else "Walk")
		else:
			boss.velocity=Vector3.ZERO; _play_boss_anim(boss,"Attack")
			if cd<=0.0:
				if target==player: _apply_damage(BOSS_COMBAT_DAMAGE)
				elif target in combat_bots: _damage_combat_bot(target,BOSS_COMBAT_DAMAGE)
				boss_attack_cooldowns[id]=BOSS_ATTACK_COOLDOWN

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
	_build_meteor_encounter()
	_build_spawn_system()
	_build_map_edge_mountains()
	_build_god_watchers()

func _build_spawn_system() -> void:
	if not spawn_points.is_empty(): return
	# Five pads per side, kept inside the mountain boundary and spread evenly.
	var edge:=164.0
	var lanes=[-132.0,-66.0,0.0,66.0,132.0]
	for x in lanes: spawn_points.append(Vector3(x,0,-edge))
	for z in lanes: spawn_points.append(Vector3(edge,0,z))
	for x in lanes: spawn_points.append(Vector3(-x,0,edge))
	for z in lanes: spawn_points.append(Vector3(-edge,0,-z))
	for i in spawn_points.size():
		var p:=spawn_points[i]
		p.y=height_at(p.x,p.z)
		spawn_points[i]=p
		# Concrete is only the spawn floor. The hollow and surrounding cover come from the terrain itself.
		_add_static_box(p+Vector3(0,-.18,0),Vector3(8.0,.36,8.0),Color(.38,.39,.40))
		var inward:=Vector3(-p.x,0,-p.z).normalized()
		var side:=Vector3(-inward.z,0,inward.x)
		# Two wooden sight-blocking walls, angled toward the map center.
		var wall_center:=p+inward*1.7
		var wall_yaw:=atan2(inward.x,inward.z)
		for s in [-1.0,1.0]:
			var wall=StaticBody3D.new()
			wall.position=wall_center+side*(s*2.05)+Vector3(0,1.25,0)
			wall.rotation.y=wall_yaw
			var mi=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=Vector3(3.6,2.5,.28); mi.mesh=bm
			var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.38,.23,.11); mat.roughness=1.0; mi.material_override=mat; wall.add_child(mi)
			var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=bm.size; cs.shape=sh; wall.add_child(cs)
			add_child(wall)
	# Human starts on pad 1. Bots occupy the remaining 19 pads.
	if player:
		var pp:=spawn_points[0]; player.position=Vector3(pp.x,pp.y+PLAYER_HEIGHT+.38,pp.z)
	for i in range(1,spawn_points.size()): _spawn_combat_bot(spawn_points[i],i)

func _spawn_combat_bot(p:Vector3,index:int) -> void:
	var bot=CharacterBody3D.new()
	bot.name="CombatBot_%02d" % index
	bot.position=Vector3(p.x,p.y+PLAYER_HEIGHT+.38,p.z)
	var cs=CollisionShape3D.new(); var cap=CapsuleShape3D.new(); cap.radius=.42; cap.height=1.7; cs.shape=cap; bot.add_child(cs)
	var model=_load_asset("res://Y Bot.fbx")
	if model:
		bot.add_child(model)
		var b:=_node_visual_bounds(model)
		if b.size.y>0.001: model.scale*=1.75/b.size.y
		model.position=Vector3(0,-PLAYER_HEIGHT,0); model.rotation_degrees.y=180.0
	add_child(bot)
	bot.set_meta("harmless_to_player",true)
	# Professional 19-NPC mission roster. Index 1..19 is stable across respawns.
	var weapon_name:String="Pompalı Tüfek"
	var rarity:String="gumus"
	var role:String="meteor7"
	match index:
		1: weapon_name="Pompalı Tüfek"; rarity="gumus"; role="meteor7"
		2: weapon_name="Çift Namlulu Pompalı"; rarity="yesil"; role="meteor7"
		3: weapon_name="Keskin Nişancı Tüfeği"; rarity="buz"; role="meteor7"
		4: weapon_name="Kılıç"; rarity="buz"; role="meteor7"
		5: weapon_name="Büyük Kılıç"; rarity="gunes"; role="meteor7"
		6: weapon_name="Katana"; rarity="lav"; role="meteor7"
		7: weapon_name="Karambit"; rarity="yesil"; role="meteor7"
		8: weapon_name="Keskin Nişancı Tüfeği"; rarity="gumus"; role="sniper_meteor_boss"
		9: weapon_name="Keskin Nişancı Tüfeği"; rarity="lav"; role="sniper_npc"
		10: weapon_name="Pompalı Tüfek"; rarity="buz"; role="close_all"
		11: weapon_name="Pompalı Tüfek"; rarity="gunes"; role="shotgun_free"
		12: weapon_name="Çift Namlulu Pompalı"; rarity="gumus"; role="shotgun_free"
		13: weapon_name="Çift Namlulu Pompalı"; rarity="lav"; role="shotgun_free"
		14: weapon_name="Kılıç"; rarity="buz"; role="sword_boss"
		15: weapon_name="Büyük Kılıç"; rarity="gunes"; role="sword_boss"
		16: weapon_name="Katana"; rarity="lav"; role="sword_boss"
		17: weapon_name="Bıçak"; rarity="gumus"; role="knife_sniper_hunter"
		18: weapon_name="Karambit"; rarity="yesil"; role="karambit_duel_meteor"
		19: weapon_name="Karambit"; rarity="lav"; role="karambit_duel_meteor"
	var weapon_key:String="%s|%s" % [weapon_name,rarity]
	var weapon_type:int=0 if weapon_name in ["Bıçak","Karambit"] else (1 if weapon_name in ["Kılıç","Büyük Kılıç","Katana"] else 2)
	var bid:int=bot.get_instance_id()
	bot_weapon_types[bid]=weapon_type; bot_weapon_keys[bid]=weapon_key
	if model:
		var sk:=_find_skeleton(model)
		if sk:
			bot_visual_skeletons[bid]=sk
			var wn:=_attach_weapon_to_skeleton(sk,weapon_key)
			if wn: bot_weapon_nodes[bid]=wn
	combat_bots.append(bot)
	bot_hp[bid]=COMBAT_MAX_HP; bot_loot[bid]={"gj":0,"items":{}}
	bot_aggro_player[bid]=false; bot_spawn_index[bid]=index; bot_roles[bid]=role
	bot_wander_targets[bid]=Vector3.ZERO; bot_attack_cooldowns[bid]=randf_range(0.0,BOT_ATTACK_COOLDOWN)
	if index==7: bot_survivor_ids[bid]=true

func _nearest_bot_target(bot:CharacterBody3D,filter_role:String="") -> Node3D:
	var target:Node3D=null; var best:float=INF
	for other in combat_bots:
		if other==bot or not is_instance_valid(other): continue
		if not filter_role.is_empty() and str(bot_roles.get(other.get_instance_id(),""))!=filter_role: continue
		var d:float=bot.global_position.distance_to(other.global_position)
		if d<best: best=d; target=other
	return target

func _nearest_boss(bot:CharacterBody3D) -> Node3D:
	var target:Node3D=null; var best:float=INF
	for boss in meteor_bosses:
		if not is_instance_valid(boss): continue
		var d:float=bot.global_position.distance_to(boss.global_position)
		if d<best: best=d; target=boss
	return target

func _update_combat_bots(delta:float) -> void:
	if combat_bots.is_empty(): return
	var boss_active:bool=not meteor_bosses.is_empty()
	for bot in combat_bots.duplicate():
		if not is_instance_valid(bot): combat_bots.erase(bot); continue
		var id:int=bot.get_instance_id()
		var index:int=int(bot_spawn_index.get(id,0))
		var role:String=str(bot_roles.get(id,"roam"))
		var weapon_type:int=int(bot_weapon_types.get(id,0))
		var cd:float=maxf(0.0,float(bot_attack_cooldowns.get(id,0.0))-delta); bot_attack_cooldowns[id]=cd
		var target:Node3D=null
		var flee_from:Node3D=null
		if role=="meteor7":
			if boss_active:
				if index<=3: flee_from=_nearest_boss(bot)
				else: target=_nearest_boss(bot)
			elif meteor_node and is_instance_valid(meteor_node): target=meteor_node
		elif role=="sniper_meteor_boss":
			target=_nearest_boss(bot) if boss_active else meteor_node
		elif role=="sniper_npc":
			target=_nearest_bot_target(bot)
		elif role=="close_all" or role=="shotgun_free":
			# Free shotgun team may attack player, NPC, boss or meteor; choose nearest.
			var candidates:Array[Node3D]=[]
			if player: candidates.append(player)
			if meteor_node and is_instance_valid(meteor_node): candidates.append(meteor_node)
			var nb:=_nearest_bot_target(bot); if nb: candidates.append(nb)
			var bb:=_nearest_boss(bot); if bb: candidates.append(bb)
			var best:float=INF
			for c in candidates:
				var d:float=bot.global_position.distance_to(c.global_position)
				if d<best: best=d; target=c
		elif role=="sword_boss":
			target=_nearest_boss(bot)
		elif role=="knife_sniper_hunter":
			target=_nearest_bot_target(bot,"sniper_npc")
			if target==null: target=_nearest_bot_target(bot,"sniper_meteor_boss")
		elif role=="karambit_duel_meteor":
			for other in combat_bots:
				if other!=bot and is_instance_valid(other) and str(bot_roles.get(other.get_instance_id(),""))=="karambit_duel_meteor": target=other; break
			if target==null and meteor_node and is_instance_valid(meteor_node): target=meteor_node
		if target==null and flee_from==null:
			var wp:Vector3=bot_wander_targets.get(id,Vector3.ZERO)
			if wp==Vector3.ZERO or bot.global_position.distance_to(wp)<3.0:
				wp=Vector3(randf_range(-145.0,145.0),0,randf_range(-145.0,145.0)); wp.y=height_at(wp.x,wp.z)+PLAYER_HEIGHT; bot_wander_targets[id]=wp
			var wd:Vector3=wp-bot.global_position; wd.y=0.0; _bot_move_smart(bot,wd,weapon_type,delta); continue
		if flee_from!=null:
			var fd:Vector3=bot.global_position-flee_from.global_position; fd.y=0.0; _bot_move_smart(bot,fd,weapon_type,delta); continue
		var dir:Vector3=target.global_position-bot.global_position; dir.y=0.0
		var weapon_key:String=str(bot_weapon_keys.get(id,""))
		var weapon_name:String=str(weapon_key.split("|")[0]) if "|" in weapon_key else ""
		var sniper:bool=weapon_name=="Keskin Nişancı Tüfeği"
		var attack_range:float=600.0 if sniper else (BOT_METEOR_RANGE if target==meteor_node else BOT_ATTACK_RANGE)
		if dir.length()>attack_range:
			if sniper: bot.velocity=Vector3.ZERO; _bot_play_animation(bot,"Rifle Aiming Idle"); _bot_copy_pose(bot)
			else: _bot_move_smart(bot,dir,weapon_type,delta)
			continue
		bot.velocity=Vector3.ZERO
		_bot_play_animation(bot,"Rifle Aiming Idle" if weapon_type==2 else ("Great Sword Idle" if weapon_type==1 else "Knife Idle")); _bot_copy_pose(bot)
		if cd>0.0: continue
		if weapon_type==2: _bot_play_animation(bot,"Firing Rifle"); _npc_muzzle_flash(bot)
		elif weapon_type==1:
			var sword_moves:Array[String]=["Great Sword Slash (1)","Great Sword Slash","Sword Fight One","Stable Sword Outward Slash"]
			_bot_play_animation(bot,sword_moves[randi_range(0,3)]); _spawn_npc_melee_sharpness(bot)
		else: _bot_play_animation(bot,"Stabbing"); _spawn_npc_melee_sharpness(bot)
		bot_attack_cooldowns[id]=BOT_ATTACK_COOLDOWN+randf_range(0.0,.16)
		var npc_damage:int=_npc_level10_damage(bot,target)
		if target==player:
			if not (cheat_mode and weapon_name in ["Pompalı Tüfek","Çift Namlulu Pompalı"]): _apply_damage(npc_damage)
		elif target in meteor_bosses:
			boss_targets[target.get_instance_id()]=bot
			var hp:int=int(target.get_meta("hp",BOSS_MAX_HP))-npc_damage; target.set_meta("hp",hp)
			if hp<=0: boss_targets.erase(target.get_instance_id()); meteor_bosses.erase(target); boss_attack_cooldowns.erase(target.get_instance_id()); target.queue_free()
		elif target==meteor_node:
			meteor_hits+=1; _apply_meteor_damage(npc_damage)
		elif target in combat_bots: _damage_combat_bot(target,npc_damage)

func _npc_level10_damage(bot:Node3D,target:Node3D) -> int:
	var key:String=str(bot_weapon_keys.get(bot.get_instance_id(),""))
	var item:String=str(key.split("|")[0]) if "|" in key else "Bıçak"
	if item in ["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana"]:
		var base:Dictionary={"Bıçak":10,"Karambit":15,"Kılıç":20,"Büyük Kılıç":25,"Katana":30}
		return int(base.get(item,10))+4
	var distance:float=bot.global_position.distance_to(target.global_position) if target else 50.0
	var max_values:Dictionary={"Pompalı Tüfek":55,"Çift Namlulu Pompalı":70,"Keskin Nişancı Tüfeği":75}
	var max_damage:int=int(max_values.get(item,55))
	if distance>=483.0: max_damage=maxi(5,roundi(max_damage*.28))
	elif distance>=350.0: max_damage=maxi(7,roundi(max_damage*.38))
	elif distance>=250.0: max_damage=maxi(9,roundi(max_damage*.50))
	elif distance>=150.0: max_damage=maxi(12,roundi(max_damage*.66))
	elif distance>=50.0: max_damage=maxi(15,roundi(max_damage*.82))
	return maxi(1,roundi(float(max_damage)*3.0/21.0))

func _bot_move_smart(bot:CharacterBody3D,dir:Vector3,weapon_type:int,delta:float) -> void:
	if dir.length()<0.05: return
	var desired:=dir.normalized()
	# Gravity plus a small automatic hop lets bots climb low lips around the meteor arena.
	if not bot.is_on_floor(): bot.velocity.y-=18.0*delta
	elif bot.velocity.y<0.0: bot.velocity.y=0.0
	# Keep NPCs inside the playable terrain and reject moves that would cut through
	# the steep mountain ring. Ground them to the terrain after movement as a safety net.
	var before:Vector3=bot.global_position
	var probe:Vector3=before+desired*BOT_SPEED*delta
	var safe_limit:float=MAP_HALF-18.0
	var current_ground:float=height_at(before.x,before.z)+PLAYER_HEIGHT
	var probe_ground:float=height_at(probe.x,probe.z)+PLAYER_HEIGHT
	var too_steep:bool=absf(probe_ground-current_ground)>2.2
	var outside:bool=absf(probe.x)>safe_limit or absf(probe.z)>safe_limit
	if too_steep or outside:
		var tangent:=Vector3(-desired.z,0,desired.x)
		if bot.get_instance_id()%2==0: tangent=-tangent
		desired=tangent.normalized()
	bot.velocity.x=desired.x*BOT_SPEED; bot.velocity.z=desired.z*BOT_SPEED
	bot.move_and_slide()
	bot.global_position.x=clampf(bot.global_position.x,-safe_limit,safe_limit)
	bot.global_position.z=clampf(bot.global_position.z,-safe_limit,safe_limit)
	var terrain_y:float=height_at(bot.global_position.x,bot.global_position.z)+PLAYER_HEIGHT
	if bot.global_position.y<terrain_y-.15:
		bot.global_position.y=terrain_y
		bot.velocity.y=0.0
	if bot.get_slide_collision_count()>0:
		var low_block:=false
		for i in range(bot.get_slide_collision_count()):
			var col:=bot.get_slide_collision(i)
			if absf(col.get_normal().y)<0.45: low_block=true
		if low_block and bot.is_on_floor():
			bot.velocity.y=6.0
		else:
			var tangent:=Vector3(-desired.z,0,desired.x)
			if bot.get_instance_id()%2==0: tangent=-tangent
			bot.velocity.x=tangent.x*BOT_SPEED; bot.velocity.z=tangent.z*BOT_SPEED
			bot.move_and_slide()
	bot.look_at(Vector3(bot.global_position.x+desired.x,bot.global_position.y,bot.global_position.z+desired.z),Vector3.UP)
	_bot_play_animation(bot,"Rifle Run" if weapon_type==2 else "Run")
	_bot_copy_pose(bot)

func _drop_half_bot_loot_to_meteor(id:int) -> void:
	var loot:Dictionary=bot_loot.get(id,{})
	var items:Dictionary=loot.get("items",{})
	for key in items.keys():
		var count:int=int(items.get(key,0))
		var dropped:int=int(ceil(float(count)/2.0))
		if dropped>0: _spawn_inventory_drop_at_meteor(str(key),dropped)
	var gj_count:int=int(loot.get("gj",0))
	var gj_drop:int=int(ceil(float(gj_count)/2.0))
	if gj_drop>0: _spawn_gj_drop(gj_drop)

func _damage_combat_bot(bot:Node3D,amount:int,caused_by_player:bool=false) -> void:
	if bot==null or not is_instance_valid(bot): return
	var id:int=bot.get_instance_id()
	if bot_survivor_ids.has(id) and int(bot_hp.get(id,COMBAT_MAX_HP))-amount<=0 and not meteor_bosses.is_empty():
		bot_hp[id]=1
		return
	bot_hp[id]=int(bot_hp.get(id,COMBAT_MAX_HP))-amount
	if int(bot_hp[id])<=0:
		if caused_by_player: _spawn_local_kill_sharpness()
		_respawn_combat_bot(bot as CharacterBody3D)

func _hit_nearby_meteor_boss() -> void:
	if player==null: return
	var key:=_selected_weapon_key(); var item:=str(key.split("|")[0]) if not key.is_empty() else "Bıçak"
	var attack_range:=_melee_range(item); var damage:=_melee_total_damage(item)
	for boss in meteor_bosses.duplicate():
		if not is_instance_valid(boss): continue
		var delta:Vector3=boss.global_position-player.global_position; delta.y=0.0
		if delta.length()<=attack_range:
			var hp:int=int(boss.get_meta("hp",BOSS_MAX_HP))-damage
			boss.set_meta("hp",hp); boss_targets[boss.get_instance_id()]=player
			if hp<=0:
				_spawn_local_kill_sharpness(); boss_targets.erase(boss.get_instance_id()); meteor_bosses.erase(boss); boss_attack_cooldowns.erase(boss.get_instance_id()); boss.queue_free()

func _hit_nearby_combat_bot() -> void:
	if player==null: return
	var key:=_selected_weapon_key(); var item:=str(key.split("|")[0]) if not key.is_empty() else "Bıçak"
	var attack_range:=_melee_range(item); var damage:=_melee_total_damage(item)
	for bot in combat_bots:
		if not is_instance_valid(bot): continue
		var delta:Vector3=bot.global_position-player.global_position; delta.y=0.0
		if delta.length()<=attack_range:
			var id:int=bot.get_instance_id(); bot_aggro_player[id]=true
			_damage_combat_bot(bot,damage,true)

func _respawn_combat_bot(bot:CharacterBody3D) -> void:
	if not is_instance_valid(bot): return
	var old_id:int=bot.get_instance_id()
	var index:int=int(bot_spawn_index.get(old_id,1))
	combat_bots.erase(bot)
	_drop_half_bot_loot_to_meteor(old_id)
	bot_survivor_ids.erase(old_id); bot_attack_cooldowns.erase(old_id); bot_weapon_types.erase(old_id); bot_weapon_keys.erase(old_id); bot_weapon_nodes.erase(old_id); bot_hp.erase(old_id); bot_loot.erase(old_id); bot_aggro_player.erase(old_id); bot_spawn_index.erase(old_id); bot_roles.erase(old_id); bot_wander_targets.erase(old_id)
	bot_anim_players.erase(old_id); bot_visual_skeletons.erase(old_id); bot_anim_skeletons.erase(old_id); bot_anim_names.erase(old_id); bot_anim_scenes.erase(old_id)
	bot.queue_free()
	if index>=0 and index<spawn_points.size(): _spawn_combat_bot(spawn_points[index],index)

func _bot_play_animation(bot:CharacterBody3D,wanted:String) -> void:
	var id:int=bot.get_instance_id()
	if str(bot_anim_names.get(id,""))==wanted and bot_anim_scenes.has(id): return
	var old_scene:Node3D=bot_anim_scenes.get(id,null)
	if old_scene and is_instance_valid(old_scene): old_scene.queue_free()
	bot_anim_scenes.erase(id); bot_anim_skeletons.erase(id); bot_anim_players.erase(id)
	var path:=_ybot_anim_source(wanted)
	if path.is_empty() or not ResourceLoader.exists(path): return
	var carrier:=_load_asset(path)
	if carrier==null: return
	carrier.visible=false
	bot.add_child(carrier)
	var ap:=_find_animation_player(carrier)
	var sk:=_find_skeleton(carrier)
	if ap==null or sk==null:
		carrier.queue_free(); return
	var chosen:StringName=&""
	for lib_name in ap.get_animation_library_list():
		var lib:=ap.get_animation_library(lib_name)
		if lib:
			for an in lib.get_animation_list():
				if str(an).to_lower()!="reset": chosen=an; break
		if chosen!=&"": break
	if chosen==&"": carrier.queue_free(); return
	var animation:=ap.get_animation(chosen)
	if animation and wanted not in ["Firing Rifle","Stabbing","Great Sword Slash","Great Sword Slash (1)","Stable Sword Outward Slash","Sword Fight One"]:
		animation.loop_mode=Animation.LOOP_LINEAR
	bot_anim_scenes[id]=carrier; bot_anim_skeletons[id]=sk; bot_anim_players[id]=ap; bot_anim_names[id]=wanted
	ap.play(chosen,0.05)

func _bot_copy_pose(bot:CharacterBody3D) -> void:
	var id:int=bot.get_instance_id()
	var dst:Skeleton3D=bot_visual_skeletons.get(id,null)
	var src:Skeleton3D=bot_anim_skeletons.get(id,null)
	if dst==null or src==null: return
	for i in range(dst.get_bone_count()):
		var source_i:=src.find_bone(dst.get_bone_name(i))
		if source_i<0: continue
		dst.set_bone_pose_position(i,src.get_bone_pose_position(source_i))
		dst.set_bone_pose_rotation(i,src.get_bone_pose_rotation(source_i))
		dst.set_bone_pose_scale(i,src.get_bone_pose_scale(source_i))

func _build_god_watchers() -> void:
	if not god_watchers.is_empty(): return
	var positions=[
		Vector3(0,0,-GOD_WATCHER_DISTANCE),
		Vector3(0,0,GOD_WATCHER_DISTANCE),
		Vector3(GOD_WATCHER_DISTANCE,0,0),
		Vector3(-GOD_WATCHER_DISTANCE,0,0)
	]
	for i in positions.size():
		var model=_load_asset("res://1.sv.tanri.glb")
		if model==null: return
		var root=Node3D.new()
		root.name="GodWatcher_%d" % (i+1)
		root.position=positions[i]
		add_child(root)
		root.add_child(model)
		var bounds:=_node_visual_bounds(model)
		if bounds.size.y>0.001:
			model.scale*=GOD_WATCHER_VISIBLE_HEIGHT/bounds.size.y
		# Sink the lower half behind the map-edge mountains so only torso/head is visible.
		var scaled_bounds:=_node_visual_bounds(model)
		model.position.y=-scaled_bounds.size.y*0.62
		god_watchers.append(root)
	_update_god_watchers()

func _update_god_watchers() -> void:
	if player==null: return
	for watcher in god_watchers:
		if not is_instance_valid(watcher): continue
		var target=Vector3(player.global_position.x,watcher.global_position.y,player.global_position.z)
		if watcher.global_position.distance_to(target)>0.01:
			watcher.look_at(target,Vector3.UP)
			# Imported god model faces the opposite local direction: turn it 180 degrees
			# so its face/chest, never its back, points toward the player.
			watcher.rotate_y(PI)

func _clear_meteor_bosses() -> void:
	for boss in meteor_bosses.duplicate():
		if is_instance_valid(boss): boss.queue_free()
	meteor_bosses.clear()
	boss_attack_cooldowns.clear()

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
	# Dense Tripo mountain chain around all four edges. No gates/openings.
	var edge:=198.0
	var step:=18.0
	for side in [-1.0,1.0]:
		var x:=-198.0
		while x<=198.0:
			_add_edge_mountain(Vector3(x,0,side*edge),x,side*edge)
			x+=step
		var z:=-198.0
		while z<=198.0:
			_add_edge_mountain(Vector3(side*edge,0,z),side*edge,z)
			z+=step

func _add_edge_mountain(p:Vector3,sx:float,sz:float) -> void:
	var model=_load_asset("res://mountain range 3d model.glb")
	if model==null: return
	model.name="EdgeMountain"
	model.position=p
	add_child(model)
	var bounds:=_node_visual_bounds(model)
	if bounds.size.y<=0.001: return
	var variation=absf(sin(sx*.071+sz*.113))
	var old_height=11.0+variation*6.0
	# Raise the new range substantially above the previous 66% test.
	var target_height=old_height*1.5333
	var uniform_scale=target_height/bounds.size.y
	model.scale=Vector3.ONE*uniform_scale
	if absf(p.z)>=absf(p.x):
		model.rotation_degrees.y=180.0 if p.z>0.0 else 0.0
	else:
		model.rotation_degrees.y=90.0 if p.x<0.0 else -90.0
	_ground_asset_to_terrain(model,p.x,p.z)

	# Invisible vertical barrier on the playable side. It blocks walking, jumping
	# and climbing through/on top of the decorative mountain meshes.
	var barrier=StaticBody3D.new()
	barrier.name="MountainBarrier"
	var cs=CollisionShape3D.new()
	var sh=BoxShape3D.new()
	if absf(p.z)>=absf(p.x):
		sh.size=Vector3(20.0,40.0,3.0)
	else:
		sh.size=Vector3(3.0,40.0,20.0)
	cs.shape=sh
	cs.position=Vector3(0,20.0,0)
	barrier.add_child(cs)
	barrier.position=p
	add_child(barrier)


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

	# Third-person Y Bot test character.
	player_visual=_load_asset("res://Y Bot.fbx")
	if player_visual:
		player_visual.name="YBotVisual"
		player.add_child(player_visual)
		var bounds:=_node_visual_bounds(player_visual)
		if bounds.size.y>0.001:
			player_visual.scale*=1.75/bounds.size.y
		# Mixamo Y Bot pivot is at the feet. Keep it fixed to the CharacterBody ground level.
		player_visual.position=Vector3(0,-PLAYER_HEIGHT,0)
		player_visual.rotation_degrees=Vector3(0,180,0)
		player_anim=_find_animation_player(player_visual)
		player_skeleton=_find_skeleton(player_visual)
		if player_anim: player_anim.stop()
		player_visual.set_meta("anim_source","res://Y Bot.fbx")

	# Real third-person shoulder rig. The pivot rotates around the player so the
	# camera stays behind the Y Bot instead of behaving like the old FPS camera.
	camera_pivot=Node3D.new()
	camera_pivot.name="ThirdPersonPivot"
	camera_pivot.position=Vector3(0,.72,0)
	player.add_child(camera_pivot)
	camera = Camera3D.new()
	camera.name = "ThirdPersonCamera"
	camera.position = Vector3(.25,.62,2.20)
	camera.rotation_degrees=Vector3.ZERO
	camera.fov = 72
	camera.current = true
	camera_pivot.add_child(camera)
	camera_yaw=0.0
	look_pitch=-5.0
	camera_pivot.rotation_degrees=Vector3(look_pitch,camera_yaw,0)

func _ybot_anim_source(anim_name:String)->String:
	var files={
		"Standing Idle":"Standing Idle.fbx","Walking":"Walking.fbx","Run":"Run.fbx",
		"Walking Backwards":"Walking Backwards.fbx","Left Strafe Walk":"Left Strafe Walk.fbx",
		"Right Strafe Walking":"Right Strafe Walking.fbx","Jump":"Jump.fbx",
		"Falling Idle":"Falling Idle.fbx","Falling To Landing":"Falling To Landing.fbx",
		"Rifle Idle":"Rifle Idle.fbx","Rifle Walk":"Rifle Walk.fbx","Rifle Run":"Rifle Run.fbx",
		"Backwards Rifle Walk":"Backwards Rifle Walk.fbx","Rifle Side Step":"Rifle Side Step.fbx",
		"Rifle Aiming Idle":"Rifle Aiming Idle.fbx","Firing Rifle":"Firing Rifle.fbx","Reloading":"Reloading.fbx",
		"Knife Idle":"Knife Idle.fbx","Stabbing":"Stabbing.fbx","Great Sword Idle":"Great Sword Idle.fbx",
		"Great Sword Slash":"Great Sword Slash.fbx","Great Sword Slash (1)":"Great Sword Slash (1).fbx",
		"Stable Sword Outward Slash":"Stable Sword Outward Slash.fbx","Sword Fight One":"Sword Fight One.fbx"
	}
	return "res://"+str(files.get(anim_name,""))

func _play_ybot_anim(wanted:String)->void:
	if player_visual==null: return
	var path:=_ybot_anim_source(wanted)
	if path.is_empty() or not ResourceLoader.exists(path): return
	var one_shot_attack=wanted in ["Firing Rifle","Stabbing","Great Sword Slash","Great Sword Slash (1)","Stable Sword Outward Slash","Sword Fight One"]
	if StringName(wanted)==player_anim_name and player_anim_scene!=null and not one_shot_attack: return
	# Mixamo animation FBXs are animation carriers. Keep the visible Y Bot mesh,
	# hide carrier meshes, and play their compatible skeleton tracks.
	if player_anim_scene and is_instance_valid(player_anim_scene):
		player_anim_scene.queue_free()
		player_anim_scene=null
		player_anim_skeleton=null
	var carrier=_load_asset(path)
	if carrier==null: return
	carrier.name="YBotAnimationCarrier"
	carrier.position=player_visual.position
	carrier.scale=player_visual.scale
	carrier.rotation=player_visual.rotation
	player.add_child(carrier)
	var stack:Array[Node]=[carrier]
	while not stack.is_empty():
		var n=stack.pop_back()
		if n is MeshInstance3D: (n as MeshInstance3D).visible=false
		for child in n.get_children(): stack.append(child)
	var ap=_find_animation_player(carrier)
	if ap==null:
		carrier.queue_free()
		return
	var anims:Array[StringName]=[]
	for lib_name in ap.get_animation_library_list():
		var lib=ap.get_animation_library(lib_name)
		if lib:
			for an in lib.get_animation_list(): anims.append(an)
	if anims.is_empty():
		carrier.queue_free()
		return
	player_anim_scene=carrier
	player_anim=ap
	player_anim_skeleton=_find_skeleton(carrier)
	if player_anim_skeleton==null:
		carrier.queue_free()
		player_anim_scene=null
		return
	player_anim_name=StringName(wanted)
	var chosen:=anims[0]
	for candidate in anims:
		if str(candidate).to_lower()!="reset":
			chosen=candidate
			break
	var animation:=ap.get_animation(chosen)
	if animation and wanted not in ["Jump","Falling To Landing","Firing Rifle","Stabbing","Great Sword Slash","Great Sword Slash (1)","Stable Sword Outward Slash","Sword Fight One","Reloading"]:
		animation.loop_mode=Animation.LOOP_LINEAR
	player_action_duration=animation.length if animation else 0.75
	ap.play(chosen,0.05)


func _update_ybot_animation(v:Vector2,dir:Vector3)->void:
	if player_visual==null: return
	if player_action_locked or muzzle_calibration_frozen: return
	var item=selected_tool.to_lower()
	var firearm=("pompal" in item or "tüfek" in item or "tufek" in item or "nişancı" in item or "nisanci" in item)
	var knife=("bıçak" in item or "bicak" in item or "karambit" in item)
	var great_sword=("büyük kılıç" in item or "buyuk kilic" in item)
	var sword=(great_sword or "kılıç" in item or "kilic" in item or "katana" in item)
	_update_sword_attack_buttons(sword)
	var wanted="Rifle Idle" if firearm else ("Knife Idle" if knife else ("Great Sword Idle" if sword else "Standing Idle"))
	if fly_mode:
		wanted="Falling Idle"
	elif not player.is_on_floor() and player.velocity.y>0.25:
		wanted="Rifle Idle" if firearm else ("Knife Idle" if knife else ("Great Sword Idle" if sword else "Jump"))
	elif not player.is_on_floor() and player.velocity.y<-.25:
		wanted="Rifle Idle" if firearm else ("Knife Idle" if knife else ("Great Sword Idle" if sword else "Falling Idle"))
	elif v.length()>0.10:
		if firearm:
			if v.y>0.35: wanted="Backwards Rifle Walk"
			elif absf(v.x)>.62 and absf(v.y)<.45: wanted="Rifle Side Step"
			elif v.length()>.72: wanted="Rifle Run"
			else: wanted="Rifle Walk"
		else:
			if v.y>0.35: wanted="Walking Backwards"
			elif absf(v.x)>.62 and absf(v.y)<.45: wanted="Right Strafe Walking" if v.x>0 else "Left Strafe Walk"
			elif v.length()>.72: wanted="Run"
			else: wanted="Walking"
	if StringName(wanted)!=player_anim_name: _play_ybot_anim(wanted)

func _return_to_lobby() -> void:
	_save_player_inventory()
	get_tree().change_scene_to_file.call_deferred("res://scenes/Intro.tscn")

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
	var actions=[["ENVANTER",_toggle_inventory],["HILE",_toggle_cheat_mode]]
	for i in actions.size():
		var b=Button.new(); b.text=actions[i][0]; b.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		if actions[i][0]=="HILE":
			cheat_button=b
			cheat_button.text="HILE KAPALI"
		elif actions[i][0]=="UC": fly_button=b
		elif actions[i][0]=="ALCAL": fly_down_button=b
		var col=i%2; var row=int(i/2); b.position=Vector2(-300+col*148,12+row*42); b.size=Vector2(140,38); b.add_theme_font_size_override("font_size",15)
		b.pressed.connect(actions[i][1]); layer.add_child(b)
	_update_fly_button_styles()
	cheat_menu_panel=VBoxContainer.new(); cheat_menu_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT); cheat_menu_panel.position=Vector2(-300,56); cheat_menu_panel.size=Vector2(288,286); cheat_menu_panel.visible=false; layer.add_child(cheat_menu_panel)
	var cheat_items=[
		["SİLAH KONUMU",_toggle_weapon_tuner],
		["NAMLU ATEŞİ KONUMU",_toggle_muzzle_tuner],
		["KESKİNLİK 1",_toggle_sharpness_1],
		["KESKİNLİK 2",_toggle_sharpness_2],
		["UÇMA MODU",_toggle_cheat_fly],
		["ALÇAL",_fly_down],
		["SINIRSIZ SİLAH",_toggle_infinite_weapons],
		["SINIRSIZ GJ",_toggle_infinite_gj],
		["SONSUZ GÜÇ",_toggle_infinite_power],
		["ZEMİNE TEMEL",_toggle_cheat_foundation_place],
		["TEMEL KALDIR",_toggle_cheat_foundation_remove]
	]
	for ci in cheat_items.size():
		var entry=cheat_items[ci]
		var row=HBoxContainer.new(); row.custom_minimum_size=Vector2(288,32); cheat_menu_panel.add_child(row)
		var cb=Button.new(); cb.text=str(ci+1); cb.custom_minimum_size=Vector2(46,32); cb.add_theme_font_size_override("font_size",13); row.add_child(cb)
		var name_label=Label.new(); name_label.text=str(entry[0]); name_label.custom_minimum_size=Vector2(226,32); name_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; name_label.add_theme_font_size_override("font_size",12); name_label.visible=false; row.add_child(name_label)
		cb.pressed.connect(func():
			name_label.visible=not name_label.visible
			if name_label.visible: entry[1].call()
		)
	var lobby_btn=Button.new(); lobby_btn.text="LOBİYE DÖN"; lobby_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT); lobby_btn.position=Vector2(-448,12); lobby_btn.size=Vector2(140,38); lobby_btn.add_theme_font_size_override("font_size",15); lobby_btn.pressed.connect(_return_to_lobby); layer.add_child(lobby_btn)
	# Live weapon tuner stays available: rotation plus grip-position nudging.
	weapon_test_label=Label.new(); weapon_test_label.set_anchors_preset(Control.PRESET_TOP_LEFT); weapon_test_label.position=Vector2(176,52); weapon_test_label.size=Vector2(620,30); weapon_test_label.add_theme_font_size_override("font_size",14); layer.add_child(weapon_test_label); weapon_test_controls.append(weapon_test_label)
	var axis_buttons=[["X-",Vector3(-15,0,0)],["X+",Vector3(15,0,0)],["Y-",Vector3(0,-15,0)],["Y+",Vector3(0,15,0)],["Z-",Vector3(0,0,-15)],["Z+",Vector3(0,0,15)]]
	for ai in axis_buttons.size():
		var ab=Button.new(); ab.text=axis_buttons[ai][0]; ab.set_anchors_preset(Control.PRESET_TOP_LEFT); ab.position=Vector2(176+ai*58,84); ab.size=Vector2(54,36); ab.add_theme_font_size_override("font_size",14); ab.pressed.connect(_weapon_test_rotate.bind(axis_buttons[ai][1])); layer.add_child(ab); weapon_test_controls.append(ab)
	var position_buttons=[["SOL",Vector3(-0.02,0,0)],["SAĞ",Vector3(0.02,0,0)],["YUKARI",Vector3(0,0.02,0)],["AŞAĞI",Vector3(0,-0.02,0)],["UZAK",Vector3(0,0,-0.02)],["YAKIN",Vector3(0,0,0.02)]]
	for pi in position_buttons.size():
		var pb=Button.new(); pb.text=position_buttons[pi][0]; pb.set_anchors_preset(Control.PRESET_TOP_LEFT); pb.position=Vector2(176+pi*70,124); pb.size=Vector2(66,36); pb.add_theme_font_size_override("font_size",11); pb.pressed.connect(_weapon_test_move.bind(position_buttons[pi][1])); layer.add_child(pb); weapon_test_controls.append(pb)
	_update_weapon_test_label()
	muzzle_test_label=Label.new(); muzzle_test_label.set_anchors_preset(Control.PRESET_TOP_LEFT); muzzle_test_label.position=Vector2(176,164); muzzle_test_label.size=Vector2(520,28); muzzle_test_label.add_theme_font_size_override("font_size",13); layer.add_child(muzzle_test_label); muzzle_test_controls.append(muzzle_test_label)
	var muzzle_buttons=[["M SOL",Vector3(-0.02,0,0)],["M SAĞ",Vector3(0.02,0,0)],["M YUKARI",Vector3(0,0.02,0)],["M AŞAĞI",Vector3(0,-0.02,0)],["M GERİ",Vector3(0,0,-0.02)],["M İLERİ",Vector3(0,0,0.02)]]
	for mi in muzzle_buttons.size():
		var mb=Button.new(); mb.text=muzzle_buttons[mi][0]; mb.set_anchors_preset(Control.PRESET_TOP_LEFT); mb.position=Vector2(176+mi*76,194); mb.size=Vector2(72,34); mb.add_theme_font_size_override("font_size",10); mb.pressed.connect(_muzzle_test_move.bind(muzzle_buttons[mi][1])); layer.add_child(mb); muzzle_test_controls.append(mb)
	var muzzle_size_buttons=[["BOYUT -",-0.05],["BOYUT +",0.05]]
	for si in muzzle_size_buttons.size():
		var sb=Button.new(); sb.text=muzzle_size_buttons[si][0]; sb.set_anchors_preset(Control.PRESET_TOP_LEFT); sb.position=Vector2(176+si*110,232); sb.size=Vector2(104,34); sb.add_theme_font_size_override("font_size",11); sb.pressed.connect(_muzzle_test_resize.bind(float(muzzle_size_buttons[si][1]))); layer.add_child(sb); muzzle_test_controls.append(sb)
	sharpness_test_label=Label.new(); sharpness_test_label.set_anchors_preset(Control.PRESET_TOP_LEFT); sharpness_test_label.position=Vector2(176,270); sharpness_test_label.size=Vector2(620,28); sharpness_test_label.add_theme_font_size_override("font_size",12); layer.add_child(sharpness_test_label); sharpness_test_controls.append(sharpness_test_label)
	var sharp_move=[["K SOL",Vector3(-0.03,0,0)],["K SAĞ",Vector3(0.03,0,0)],["K YUKARI",Vector3(0,0.03,0)],["K AŞAĞI",Vector3(0,-0.03,0)],["K GERİ",Vector3(0,0,-0.03)],["K İLERİ",Vector3(0,0,0.03)]]
	for ki in sharp_move.size():
		var kb=Button.new(); kb.text=sharp_move[ki][0]; kb.set_anchors_preset(Control.PRESET_TOP_LEFT); kb.position=Vector2(176+ki*76,300); kb.size=Vector2(72,32); kb.add_theme_font_size_override("font_size",9); kb.pressed.connect(_sharpness_move.bind(sharp_move[ki][1])); layer.add_child(kb); sharpness_test_controls.append(kb)
	var sharp_ops=[["BOYUT -",-0.10,0],["BOYUT +",0.10,0],["AÇI -",0,-10],["AÇI +",0,10]]
	for oi in sharp_ops.size():
		var ob=Button.new(); ob.text=sharp_ops[oi][0]; ob.set_anchors_preset(Control.PRESET_TOP_LEFT); ob.position=Vector2(176+oi*100,336); ob.size=Vector2(94,32); ob.add_theme_font_size_override("font_size",10); ob.pressed.connect(_sharpness_adjust.bind(float(sharp_ops[oi][1]),float(sharp_ops[oi][2]))); layer.add_child(ob); sharpness_test_controls.append(ob)
	_update_sharpness_label()
	_update_muzzle_test_label()
	_update_cheat_button_style()
	_create_minimap(layer)
	var action_btn=Button.new(); action_btn.text="VUR"; action_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); action_btn.position=Vector2(-250,-215); action_btn.size=Vector2(104,104); action_btn.add_theme_font_size_override("font_size",20)
	var action_style=StyleBoxFlat.new(); action_style.bg_color=Color(1.0,.78,.08,.34); action_style.corner_radius_top_left=52; action_style.corner_radius_top_right=52; action_style.corner_radius_bottom_left=52; action_style.corner_radius_bottom_right=52
	action_btn.add_theme_stylebox_override("normal",action_style); action_btn.add_theme_stylebox_override("pressed",action_style); action_btn.mouse_filter=Control.MOUSE_FILTER_STOP; action_btn.pressed.connect(_player_attack); layer.add_child(action_btn)
	var sword_actions=[["1",_sword_attack_1,Vector2(-430,-199)],["2",_sword_attack_2,Vector2(-340,-199)],["3",_sword_attack_3,Vector2(-136,-199)]]
	for sword_action in sword_actions:
		var sword_btn=Button.new(); sword_btn.text=sword_action[0]; sword_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); sword_btn.position=sword_action[2]; sword_btn.size=Vector2(72,72); sword_btn.add_theme_font_size_override("font_size",22)
		var sword_style=StyleBoxFlat.new(); sword_style.bg_color=Color(.72,.72,.72,.30); sword_style.corner_radius_top_left=36; sword_style.corner_radius_top_right=36; sword_style.corner_radius_bottom_left=36; sword_style.corner_radius_bottom_right=36
		sword_btn.add_theme_stylebox_override("normal",sword_style); sword_btn.add_theme_stylebox_override("pressed",sword_style); sword_btn.mouse_filter=Control.MOUSE_FILTER_STOP; sword_btn.pressed.connect(sword_action[1]); sword_btn.visible=false; layer.add_child(sword_btn); sword_attack_buttons.append(sword_btn)
	var jump_btn=Button.new(); jump_btn.text="↑ Zıpla"; jump_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); jump_btn.position=Vector2(-238,-310); jump_btn.size=Vector2(92,76); jump_btn.add_theme_font_size_override("font_size",18); jump_btn.pressed.connect(_jump); layer.add_child(jump_btn)
	var scope_btn=Button.new(); scope_btn.text="🔭"; scope_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); scope_btn.position=Vector2(-350,-320); scope_btn.size=Vector2(82,82); scope_btn.add_theme_font_size_override("font_size",28)
	var scope_style=StyleBoxFlat.new(); scope_style.bg_color=Color(.10,.10,.10,.30); scope_style.corner_radius_top_left=41; scope_style.corner_radius_top_right=41; scope_style.corner_radius_bottom_left=41; scope_style.corner_radius_bottom_right=41
	scope_btn.add_theme_stylebox_override("normal",scope_style); scope_btn.add_theme_stylebox_override("pressed",scope_style); scope_btn.pressed.connect(_toggle_scope); layer.add_child(scope_btn)
	collect_button=Button.new(); collect_button.text="TOPLA"; collect_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); collect_button.position=Vector2(-455,-310); collect_button.size=Vector2(92,62); collect_button.add_theme_font_size_override("font_size",17); collect_button.pressed.connect(_collect_reward_square); collect_button.visible=false; layer.add_child(collect_button)
	crouch_button=Button.new(); crouch_button.text="↓ Çömel"; crouch_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); crouch_button.position=Vector2(-238,-104); crouch_button.size=Vector2(104,80); crouch_button.add_theme_font_size_override("font_size",18)
	var crouch_style=StyleBoxFlat.new(); crouch_style.bg_color=Color(.12,.12,.12,.34); crouch_style.corner_radius_top_left=40; crouch_style.corner_radius_top_right=40; crouch_style.corner_radius_bottom_left=40; crouch_style.corner_radius_bottom_right=40
	crouch_button.add_theme_stylebox_override("normal",crouch_style); crouch_button.add_theme_stylebox_override("pressed",crouch_style); crouch_button.pressed.connect(_toggle_crouch); layer.add_child(crouch_button)
	var aim=Label.new(); aim.text="+"; aim.set_anchors_preset(Control.PRESET_CENTER); aim.position=Vector2(-14,-22); aim.size=Vector2(28,44); aim.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; aim.add_theme_font_size_override("font_size",32); aim.add_theme_color_override("font_color",Color(.95,.08,.06,1)); aim.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(aim)
	_create_survival_clock(layer); _create_damage_effect(layer); _create_cheat_ui(layer)
	facing_label=Label.new(); facing_label.set_anchors_preset(Control.PRESET_TOP_WIDE); facing_label.position=Vector2(0,48); facing_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; facing_label.add_theme_font_size_override("font_size",22); layer.add_child(facing_label)
	waypoint_label=Label.new(); waypoint_label.set_anchors_preset(Control.PRESET_TOP_WIDE); waypoint_label.position=Vector2(0,76); waypoint_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; waypoint_label.add_theme_font_size_override("font_size",20); layer.add_child(waypoint_label)
	_update_cheat_button_style()
	_create_hotbar(layer)
	_refresh_hotbar()
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
	var title=Label.new()
	title.text="MAĞAZA"
	title.position=Vector2(20,12)
	title.size=Vector2(620,38)
	title.add_theme_font_size_override("font_size",26)
	store_panel.add_child(title)
	var close=Button.new()
	close.text="✕"
	close.position=Vector2(712,10)
	close.size=Vector2(50,38)
	close.pressed.connect(_open_store)
	store_panel.add_child(close)
	# Yeni mağaza kategori çubuğu.
	var categories=["TÜMÜ","SİLAH","ZIRH","KARTLAR"]
	for i in categories.size():
		var category_btn=Button.new()
		category_btn.name="Category_"+str(i)
		category_btn.text=categories[i]
		category_btn.position=Vector2(20+i*185,68)
		category_btn.size=Vector2(170,48)
		category_btn.add_theme_font_size_override("font_size",18)
		category_btn.pressed.connect(_show_store_category.bind(categories[i]))
		store_panel.add_child(category_btn)
	_show_store_category("TÜMÜ")
	store_panel.visible=true

var last_store_tex_err := "none"
var last_store_tex_w := 0
var last_store_tex_h := 0

func _store_card_texture() -> Texture2D:
	last_store_tex_err = "none"
	last_store_tex_w = 0
	last_store_tex_h = 0
	var raw := Marshalls.base64_to_raw(STORE_GRAY_CARD_PNG_B64)
	if raw.is_empty():
		last_store_tex_err = "b64_empty"
	else:
		var img := Image.new()
		var err := img.load_png_from_buffer(raw)
		last_store_tex_err = str(err)
		if err == OK:
			last_store_tex_w = img.get_width()
			last_store_tex_h = img.get_height()
			if last_store_tex_w > 0 and last_store_tex_h > 0:
				return ImageTexture.create_from_image(img)
			last_store_tex_err = "decode_ok_but_zero_size"
	var fallback := Image.create(136, 104, false, Image.FORMAT_RGBA8)
	fallback.fill(Color(0.72, 0.75, 0.80, 1.0))
	last_store_tex_w = fallback.get_width()
	last_store_tex_h = fallback.get_height()
	return ImageTexture.create_from_image(fallback)

func _show_store_category(category:String) -> void:
	if store_panel==null: return
	var old=store_panel.get_node_or_null("CategoryItems")
	if old: old.queue_free()
	var scroll=ScrollContainer.new()
	scroll.name="CategoryItems"
	scroll.position=Vector2(20,130)
	scroll.size=Vector2(740,425)
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	store_panel.add_child(scroll)
	var wrap=VBoxContainer.new()
	wrap.custom_minimum_size=Vector2(700,0)
	wrap.add_theme_constant_override("separation",8)
	scroll.add_child(wrap)

	var card_texture := _store_card_texture()
	var status=Label.new()
	status.text="err=%s w=%d h=%d tex=%s" % [last_store_tex_err, last_store_tex_w, last_store_tex_h, str(card_texture!=null)]
	status.add_theme_font_size_override("font_size",18)
	status.add_theme_color_override("font_color", Color(1,0.15,0.15,1))
	wrap.add_child(status)

	var grid=GridContainer.new()
	grid.columns=5
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	wrap.add_child(grid)

	var show_weapon := category == "TÜMÜ" or category == "SİLAH"
	var card_colors = [
		Color(0.75, 0.77, 0.80, 1.0),
		Color(0.02, 0.58, 0.37, 1.0),
		Color(0.55, 0.84, 0.96, 1.0),
		Color(1.00, 0.93, 0.28, 1.0),
		Color(0.86, 0.10, 0.07, 1.0)
	]
	for i in 40:
		var cell=Control.new()
		cell.custom_minimum_size=Vector2(136,104)
		var bg_tex=_store_png_texture(STORE_SLOT_BG[i % STORE_SLOT_BG.size()])
		if bg_tex!=null:
			var bg=TextureRect.new()
			bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			bg.texture=bg_tex
			bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			bg.stretch_mode=TextureRect.STRETCH_SCALE
			bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
			cell.add_child(bg)
		else:
			var bg=ColorRect.new()
			bg.set_anchors_preset(Control.PRESET_FULL_RECT)
			bg.color=Color(0.2,0.2,0.2,1)
			cell.add_child(bg)
		var overlay_tex:Texture2D=null
		if show_weapon:
			var row := int(i / 5)+1
			var variants=["gumus","yesil","buz","gunes","lav"]
			overlay_tex=_store_png_texture("res://weapon%d%s.png" % [row,variants[i % 5]])
		if overlay_tex != null:
			var overlay=TextureRect.new()
			overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
			overlay.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			overlay.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			overlay.texture=overlay_tex
			overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
			cell.add_child(overlay)
		if show_weapon:
			var buy=Button.new()
			buy.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			buy.flat=true
			buy.tooltip_text="Hile açıkken ücretsiz al"
			buy.pressed.connect(_store_take_weapon.bind(int(i / 5),i % 5))
			cell.add_child(buy)
		grid.add_child(cell)

func _store_take_weapon(row:int,col:int) -> void:
	var names=["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
	var variants=["gumus","yesil","buz","gunes","lav"]
	if row<0 or row>=names.size() or col<0 or col>=variants.size(): return
	if not cheat_mode:
		if gather_label:
			gather_label.text="Bu mağaza alımı testte yalnızca HİLE AÇIK iken kullanılabilir."
			gather_label.visible=true; message_time=1.5
		return
	var key="%s|%s" % [names[row],variants[col]]
	crafted_inventory[key]=int(crafted_inventory.get(key,0))+1
	_save_player_inventory()
	if inventory_panel: _refresh_inventory()
	if gather_label:
		gather_label.text="%s envantere eklendi" % _hotbar_item_title(key)
		gather_label.visible=true; message_time=1.5

func _rarity_name(rarity:String) -> String:
	match rarity:
		"gray","gumus": return "Gümüş"
		"green","yesil": return "Zehir"
		"blue","buz": return "Buz"
		"orange","gunes": return "Güneş"
		"red","lav": return "Lav"
	return rarity

func _nearest_poi() -> String:
	return ""

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
	for control in weapon_test_controls:
		if is_instance_valid(control): control.visible=cheat_mode and cheat_weapon_tuner
	for control in muzzle_test_controls:
		if is_instance_valid(control): control.visible=cheat_mode and cheat_muzzle_tuner
	for control in sharpness_test_controls:
		if is_instance_valid(control): control.visible=cheat_mode and cheat_sharpness_tuner>0
	if cheat_menu_panel: cheat_menu_panel.visible=cheat_mode

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
		hud.text = "HP %d  Kart %d" % [health,gray_cards]
		return
	if message_time>0.0:
		message_time-=delta
		if message_time<=0.0:
			if respawn_label: respawn_label.visible=false
			if gather_label: gather_label.visible=false
	if shoot_flash_time>0.0:
		shoot_flash_time-=delta
		if shoot_flash_time<=0.0 and hit_label: hit_label.visible=false
	var v = move_touch
	if muzzle_calibration_frozen:
		v=Vector2.ZERO
	if not muzzle_calibration_frozen and Input.is_key_pressed(KEY_W): v.y = -1
	if not muzzle_calibration_frozen and Input.is_key_pressed(KEY_S): v.y = 1
	if not muzzle_calibration_frozen and Input.is_key_pressed(KEY_A): v.x = -1
	if not muzzle_calibration_frozen and Input.is_key_pressed(KEY_D): v.x = 1
	# Mobile movement follows what the camera/player is facing: up=forward, down=back.
	var forward=Vector3(0,0,-1)
	var right=Vector3(1,0,0)
	if camera_pivot:
		forward=-camera_pivot.global_transform.basis.z; forward.y=0.0; forward=forward.normalized()
		right=camera_pivot.global_transform.basis.x; right.y=0.0; right=right.normalized()
	elif camera:
		forward=-camera.global_transform.basis.z; forward.y=0.0; forward=forward.normalized()
		right=camera.global_transform.basis.x; right.y=0.0; right=right.normalized()
	var dir = right*v.x + forward*(-v.y)
	if dir.length() > 1.0: dir = dir.normalized()
	if dir.length()>0.05:
		# Keep the camera rig independent. Rotating the CharacterBody also rotates its
		# child camera pivot and causes the fast/double-turn feeling on mobile.
		player_facing=forward
		if player_visual:
			var target_visual_yaw=atan2(-forward.x,-forward.z)+PI
			player_visual.rotation.y=lerp_angle(player_visual.rotation.y,target_visual_yaw,clampf(delta*6.0,0.0,1.0))
	var speed = player_move_speed * (.70 if in_pit else 1.0)
	if fly_mode: speed*=6.0
	elif v.length()>0.10 and v.length()<0.72: speed*=0.55
	_update_ybot_animation(v,dir)
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
	# Mountains begin near the map edge: this is the absolute playable boundary.
	# The player can never cross into or through the mountain belt.
	const MOUNTAIN_INNER_LIMIT := 171.0
	player.position.x = clampf(player.position.x, -MOUNTAIN_INNER_LIMIT, MOUNTAIN_INNER_LIMIT)
	player.position.z = clampf(player.position.z, -MOUNTAIN_INNER_LIMIT, MOUNTAIN_INNER_LIMIT)
	# The square at the exact world center is forbidden. Push the player back to the
	# nearest side instead of allowing entry from North/South/East/West.
	if absf(player.position.x)<CENTER_FORBIDDEN_HALF and absf(player.position.z)<CENTER_FORBIDDEN_HALF:
		var ax:=absf(player.position.x)
		var az:=absf(player.position.z)
		if ax>az:
			player.position.x=signf(player.position.x)*CENTER_FORBIDDEN_HALF
		else:
			player.position.z=signf(player.position.z)*CENTER_FORBIDDEN_HALF
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
			if player_visual: player_visual.rotation_degrees.x=0.0
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
	_update_meteor_bosses(delta)
	_update_combat_bots(delta)
	_update_god_watchers()
	if health <= 0:
		_death_feedback()
		_respawn()
	var zone = "VAHSI"
	if in_pit:
		zone = "CUKUR"
	elif in_dry:
		zone = "TERK EDILMIS BOLGE"
	zone_label.text="%s  •  %s" % [zone,_nearest_poi()]
	hud.text = "HP %d  Kart %d" % [health,gray_cards]

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

func _find_bone_fuzzy(skeleton:Skeleton3D, needles:Array[String]) -> int:
	for i in range(skeleton.get_bone_count()):
		var bone_name:=str(skeleton.get_bone_name(i)).to_lower()
		for needle in needles:
			if needle.to_lower() in bone_name: return i
	return -1

func _apply_crouch_pose() -> void:
	if not crouched or player_skeleton==null: return
	var hips:=_find_bone_fuzzy(player_skeleton,["hips"])
	var left_up:=_find_bone_fuzzy(player_skeleton,["leftupleg","left_up_leg"])
	var right_up:=_find_bone_fuzzy(player_skeleton,["rightupleg","right_up_leg"])
	var left_leg:=_find_bone_fuzzy(player_skeleton,["leftleg","left_leg"])
	var right_leg:=_find_bone_fuzzy(player_skeleton,["rightleg","right_leg"])
	if hips>=0:
		var hp:=player_skeleton.get_bone_pose_position(hips)
		hp.y-=.38
		player_skeleton.set_bone_pose_position(hips,hp)
	for bone in [left_up,right_up]:
		if bone>=0:
			var q:=player_skeleton.get_bone_pose_rotation(bone)
			player_skeleton.set_bone_pose_rotation(bone,Quaternion(Vector3.RIGHT,deg_to_rad(-58.0))*q)
	for bone in [left_leg,right_leg]:
		if bone>=0:
			var q:=player_skeleton.get_bone_pose_rotation(bone)
			# Bend the knees backward in the Y Bot local leg axis instead of folding the shins toward the camera.
			player_skeleton.set_bone_pose_rotation(bone,Quaternion(Vector3.RIGHT,deg_to_rad(-72.0))*q)

func _toggle_crouch():
	if _panel_open(): return
	if player==null or camera==null: return
	crouched=not crouched
	if camera_pivot: camera_pivot.position.y=.48 if crouched else .72
	if player_visual: player_visual.position.y=-PLAYER_HEIGHT+.18 if crouched else -PLAYER_HEIGHT
	# Keep the normal movement speed untouched; crouch only changes pose/camera.
	if crouch_button: crouch_button.text="↑ Kalk" if crouched else "↓ Çömel"

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
			camera_yaw-=event.relative.x*look_sensitivity
			look_pitch=clampf(look_pitch-event.relative.y*look_sensitivity,-35.0,25.0)
			if camera_pivot:
				camera_pivot.rotation_degrees=Vector3(look_pitch,camera_yaw,0)
			player_facing=Vector3(-sin(deg_to_rad(camera_yaw)),0,-cos(deg_to_rad(camera_yaw))).normalized()

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
		var protection_damage:=int(ceil(float(whole)*0.5))
		var health_damage:int=whole-protection_damage
		var absorbed:=mini(protection,protection_damage)
		protection-=absorbed
		# Protection's half never spills into health when protection is empty.
		health=max(0,health-health_damage)
		damage_buffer-=whole
		_update_vitals_ui()

func _update_vitals_ui() -> void:
	if health_bar: health_bar.value=health
	if protection_bar: protection_bar.value=protection
	if health_value_label: health_value_label.text="CAN  %d/100" % health
	if protection_value_label: protection_value_label.text="KORUMA  %d/100" % protection

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

func _spawn_inventory_drop_at_meteor(key:String,amount:int) -> void:
	if meteor_node==null or amount<=0: return
	var root=Node3D.new(); root.name="InventoryDrop"; add_child(root)
	var angle:=randf()*TAU; var radius:=randf_range(METEOR_ARENA_RADIUS*.55,METEOR_ARENA_RADIUS*.92)
	root.global_position=meteor_node.global_position+Vector3(cos(angle)*radius,.6,sin(angle)*radius)
	root.set_meta("inventory_key",key); root.set_meta("card_amount",amount)
	var mesh_node=MeshInstance3D.new(); var mesh=BoxMesh.new(); mesh.size=Vector3(.46,.46,.10); mesh_node.mesh=mesh; root.add_child(mesh_node)
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.92,.78,.18); mat.metallic=.4; mesh_node.material_override=mat
	var label=Label3D.new(); label.text="%s x%d" % [str(key.split("|")[0]),amount]; label.position=Vector3(0,.5,0); label.font_size=32; label.outline_size=6; label.billboard=BaseMaterial3D.BILLBOARD_ENABLED; root.add_child(label)
	meteor_card_drops.append(root)

func _drop_half_player_loot_to_meteor() -> void:
	for key in crafted_inventory.keys():
		var count:int=int(crafted_inventory.get(key,0))
		if count<=0: continue
		var dropped:int=int(ceil(float(count)/2.0))
		crafted_inventory[key]=count-dropped
		_spawn_inventory_drop_at_meteor(str(key),dropped)
	if gj_balance>0:
		var gj_drop:int=int(ceil(float(gj_balance)/2.0))
		gj_balance-=gj_drop; _spawn_gj_drop(gj_drop)
	_save_player_inventory()

func _respawn():
	_clear_meteor_bosses()
	_drop_half_player_loot_to_meteor()
	wood /= 2; stone /= 2; grass_n /= 2; wheat_n /= 2; mushroom_n /= 2
	health=100; protection=100; _update_vitals_ui(); hunger=70.0; thirst=80.0; damage_buffer=0.0; player.velocity=Vector3.ZERO
	if not spawn_points.is_empty():
		var pp:=spawn_points[0]; player.position=Vector3(pp.x,pp.y+PLAYER_HEIGHT+.38,pp.z)
	else:
		player.position=Vector3(0,PLAYER_HEIGHT,0)
	if map_panel: map_panel.visible=false
	if respawn_label:
		respawn_label.text="YENIDEN DOGDUN  •  Toplanan ganimetin yarısı meteor alanına düştü"; respawn_label.visible=true; message_time=3.5


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
	var frame=Panel.new()
	frame.custom_minimum_size=Vector2(128,104)
	cell.add_child(frame)
	var key_parts=key.split("|")
	if key_parts.size()>=2:
		var inv_variant=str(key_parts[1])
		var inv_variants=["gumus","yesil","buz","gunes","lav"]
		var inv_col=inv_variants.find(inv_variant)
		if inv_col>=0:
			var bg=TextureRect.new()
			bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			bg.texture=_store_png_texture(STORE_SLOT_BG[inv_col])
			bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			bg.stretch_mode=TextureRect.STRETCH_SCALE
			bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
			frame.add_child(bg)
	if key in hotbar_items:
		var active_style=StyleBoxFlat.new(); active_style.bg_color=Color(.08,.55,.16,.24); active_style.border_color=Color(.18,1.0,.32,.95); active_style.set_border_width_all(3); frame.add_theme_stylebox_override("panel",active_style)
	var image_button=TextureButton.new()
	image_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image_button.custom_minimum_size=Vector2(128,104)
	image_button.ignore_texture_size=true
	image_button.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	image_button.texture_normal=texture
	image_button.tooltip_text=title
	image_button.pressed.connect(_open_inventory_item_actions.bind(key,title))
	frame.add_child(image_button)
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
	var equip=Button.new(); equip.text="KUŞAN"; equip.position=Vector2(8,72); equip.size=Vector2(88,55); equip.pressed.connect(_equip_inventory_item.bind(key)); actions.add_child(equip)
	var upgrade=Button.new(); upgrade.text="YÜKSELT"; upgrade.position=Vector2(102,72); upgrade.size=Vector2(92,55); upgrade.pressed.connect(_upgrade_weapon_with_card.bind(key)); actions.add_child(upgrade)
	var exchange=Button.new(); exchange.text="2→1"; exchange.position=Vector2(200,72); exchange.size=Vector2(88,55); exchange.pressed.connect(_open_card_exchange_choices.bind(key)); actions.add_child(exchange)

func _general_card_cost_for_target_level(target_level:int) -> int:
	# General colour-card cost doubles per target level: Lv2=2, Lv3=4, Lv4=8...
	# Godot integers are signed 64-bit, so saturate only beyond the representable range.
	if target_level<=1: return 0
	if target_level>=63: return 9223372036854775807
	return 1 << (target_level-1)

func _upgrade_weapon_with_card(key:String) -> void:
	_flash_message("SİLAH YÜKSELTME SADECE LOBİDE YAPILIR")
	return
	if "|" not in key: return
	var parts=key.split("|"); var item:=str(parts[0]); var rarity:=str(parts[1])
	if item.begins_with("Kart:"): item=item.trim_prefix("Kart:")
	var store_names=["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
	if item not in store_names: return
	var weapon_key:="%s|%s" % [item,rarity]
	var level:=_weapon_level_for_key(weapon_key)
	if level>=100: _flash_message("SİLAH SEVİYESİ ZATEN 100"); return
	var target_level:=level+1
	var weapon_card_key:="Kart:%s|%s" % [item,rarity]
	var general_card_key:="Kart|%s" % rarity
	var weapon_card_cost:=target_level
	var general_card_cost:=_general_card_cost_for_target_level(target_level)
	var weapon_cards:=int(crafted_inventory.get(weapon_card_key,0))
	var general_cards:=int(crafted_inventory.get(general_card_key,0))
	if weapon_cards<weapon_card_cost:
		_flash_message("SEVİYE %d İÇİN %d %s %s KARTI GEREKİYOR" % [target_level,weapon_card_cost,_rarity_name(rarity),item]); return
	if general_cards<general_card_cost:
		_flash_message("SEVİYE %d İÇİN %d %s GENEL KART GEREKİYOR" % [target_level,general_card_cost,_rarity_name(rarity)]); return
	crafted_inventory[weapon_card_key]=weapon_cards-weapon_card_cost
	crafted_inventory[general_card_key]=general_cards-general_card_cost
	weapon_levels[weapon_key]=target_level
	_save_player_inventory(); _refresh_inventory()
	_flash_message("%s %s  SEVİYE %d" % [_rarity_name(rarity),item,target_level])

func _open_card_exchange_choices(key:String) -> void:
	_flash_message("KART TAKASI SADECE LOBİDE YAPILIR")
	return
	if "|" not in key or inventory_panel==null: return
	var parts=key.split("|"); var item:=str(parts[0]); var source_rarity:=str(parts[1])
	if item!="Kart": _flash_message("2→1 TAKAS GENEL RENK KARTLARI İÇİNDİR"); return
	if int(crafted_inventory.get(key,0))<2: _flash_message("TAKAS İÇİN 2 KART GEREKİYOR"); return
	var actions=inventory_panel.get_node_or_null("ItemActions")
	if actions==null: return
	for child in actions.get_children():
		if child is Button and child.text in ["GÜMÜŞ","ZEHİR","BUZ","GÜNEŞ","LAV"]: child.queue_free()
	actions.size=Vector2(300,215)
	var rarities=["gumus","yesil","buz","gunes","lav"]
	for i in range(rarities.size()):
		var target_rarity:String=str(rarities[i])
		var b=Button.new(); b.text=_rarity_name(target_rarity).to_upper(); b.position=Vector2(8+i*57,140); b.size=Vector2(54,54); b.add_theme_font_size_override("font_size",10)
		b.pressed.connect(_exchange_general_card.bind(source_rarity,target_rarity)); actions.add_child(b)

func _exchange_general_card(source_rarity:String,target_rarity:String) -> void:
	var source_key:="Kart|%s" % source_rarity
	if int(crafted_inventory.get(source_key,0))<2: _flash_message("TAKAS İÇİN 2 KART GEREKİYOR"); return
	crafted_inventory[source_key]=int(crafted_inventory.get(source_key,0))-2
	var target_key:="Kart|%s" % target_rarity
	crafted_inventory[target_key]=int(crafted_inventory.get(target_key,0))+1
	_save_player_inventory(); _refresh_inventory()
	_flash_message("2 %s → 1 %s" % [_rarity_name(source_rarity),_rarity_name(target_rarity)])

func _restore_owned_weapons_to_inventory() -> void:
	# A saved weapon level is ownership evidence. Restore missing legacy weapons
	# without creating map-collected resources in the visible inventory.
	var names:Array[String]=["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
	var rarities:Array[String]=["gumus","yesil","buz","gunes","lav"]
	for name in names:
		var restored:bool=false
		for rarity in rarities:
			var key:String="%s|%s" % [name,rarity]
			if crafted_inventory.has(key) and int(crafted_inventory.get(key,0))>0:
				restored=true
				break
		if restored: continue
		# Prefer a saved color-specific level; otherwise restore legacy owned weapons
		# whose old name-only level is above the default level 1.
		for rarity in rarities:
			var key:String="%s|%s" % [name,rarity]
			if weapon_levels.has(key):
				crafted_inventory[key]=1
				restored=true
				break
		if not restored and int(weapon_levels.get(name,1))>1:
			crafted_inventory["%s|gumus" % name]=1

func _inventory_is_stackable(name:String,rarity:String) -> bool:
	var store_names=["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
	return name in ["Ok","Tabanca Mermisi","Pompalı Mermisi","Tüfek Mermisi","Kart"] or name.begins_with("Kart:") or (name in store_names and rarity in ["gumus","yesil","buz","gunes","lav"])

func _save_player_inventory() -> void:
	var cfg=ConfigFile.new()
	cfg.load("user://player.cfg")
	cfg.set_value("inventory","crafted",crafted_inventory)
	cfg.set_value("weapons","levels",weapon_levels)
	cfg.set_value("wallet","gj",gj_balance)
	cfg.save("user://player.cfg")

func _refresh_inventory():
	_save_player_inventory()
	if inventory_panel==null: return
	_close_inventory_item_actions()
	var grid=inventory_panel.get_node("InvScroll/Grid")
	for child in grid.get_children(): child.queue_free()
	var shown:=0
	var sorted_keys:Array=crafted_inventory.keys()
	var rarity_order=["gumus","yesil","buz","gunes","lav"]
	var weapon_order=["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
	sorted_keys.sort_custom(func(a,b):
		var ap=str(a).split("|"); var bp=str(b).split("|")
		var an=str(ap[0]); var bn=str(bp[0]); var ar=str(ap[1]) if ap.size()>1 else ""; var br=str(bp[1]) if bp.size()>1 else ""
		var acat=-1 if an=="Kart" else (weapon_order.find(an.trim_prefix("Kart:")) if weapon_order.find(an.trim_prefix("Kart:"))>=0 else 99)
		var bcat=-1 if bn=="Kart" else (weapon_order.find(bn.trim_prefix("Kart:")) if weapon_order.find(bn.trim_prefix("Kart:"))>=0 else 99)
		if acat!=bcat: return acat<bcat
		return rarity_order.find(ar)<rarity_order.find(br)
	)
	for key in sorted_keys:
		var count=int(crafted_inventory[key])
		if count<=0: continue
		var parts=key.split("|")
		if parts.size()<2: continue
		var name=str(parts[0]); var rarity=str(parts[1])
		# Raw world resources/loot stay tracked for gameplay/crafting but are hidden
		# from the weapon/card inventory UI.
		var visible_names:Array[String]=["Kart","Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
		if not (name in visible_names or name.begins_with("Kart:")): continue
		var tex=null
		var store_names=["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
		var display_name: String = name.trim_prefix("Kart:") if name.begins_with("Kart:") else name
		var store_row=store_names.find(display_name)+1
		if store_row>0 and rarity in ["gumus","yesil","buz","gunes","lav"]:
			tex=_store_png_texture("res://weapon%d%s.png" % [store_row,rarity])
		var title="%s %s" % [_rarity_name(rarity),display_name]
		if name.begins_with("Kart:"): title+=" KARTI"
		elif name=="Kart": title+=" GENEL KART"
		var stackable=_inventory_is_stackable(name,rarity)
		var remaining=count
		while remaining>0:
			var amount=mini(100,remaining) if stackable else 1
			grid.add_child(_inventory_item_cell(key,title+"  "+str(amount)+"x",amount,tex))
			remaining-=amount
			shown+=1

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
	if cheat_mode: return 999999
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
	hotbar.position=Vector2(-408,-116)
	hotbar.size=Vector2(816,106)
	hotbar.alignment=BoxContainer.ALIGNMENT_CENTER
	for i in 6:
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
	var vitals=VBoxContainer.new(); vitals.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); vitals.position=Vector2(-130,-220); vitals.size=Vector2(260,104); vitals.alignment=BoxContainer.ALIGNMENT_CENTER; layer.add_child(vitals)
	var hp_box=VBoxContainer.new(); hp_box.custom_minimum_size=Vector2(250,50); vitals.add_child(hp_box)
	health_value_label=Label.new(); health_value_label.text="CAN  100/100"; health_value_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; health_value_label.add_theme_color_override("font_color",Color(1.0,.25,.25)); hp_box.add_child(health_value_label)
	health_bar=ProgressBar.new(); health_bar.min_value=0; health_bar.max_value=100; health_bar.value=health; health_bar.show_percentage=false; health_bar.custom_minimum_size=Vector2(250,20)
	var hp_bg=StyleBoxFlat.new(); hp_bg.bg_color=Color(.55,.02,.02,.28); health_bar.add_theme_stylebox_override("background",hp_bg)
	var hp_fill=StyleBoxFlat.new(); hp_fill.bg_color=Color(.72,.02,.02,.98); health_bar.add_theme_stylebox_override("fill",hp_fill); hp_box.add_child(health_bar)
	var armor_box=VBoxContainer.new(); armor_box.custom_minimum_size=Vector2(250,50); vitals.add_child(armor_box)
	protection_value_label=Label.new(); protection_value_label.text="KORUMA  100/100"; protection_value_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; protection_value_label.add_theme_color_override("font_color",Color(.30,.65,1.0)); armor_box.add_child(protection_value_label)
	protection_bar=ProgressBar.new(); protection_bar.min_value=0; protection_bar.max_value=100; protection_bar.value=protection; protection_bar.show_percentage=false; protection_bar.custom_minimum_size=Vector2(250,20)
	var armor_bg=StyleBoxFlat.new(); armor_bg.bg_color=Color(.02,.18,.62,.25); protection_bar.add_theme_stylebox_override("background",armor_bg)
	var armor_fill=StyleBoxFlat.new(); armor_fill.bg_color=Color(.02,.28,.82,.98); protection_bar.add_theme_stylebox_override("fill",armor_fill); armor_box.add_child(protection_bar)
	_update_vitals_ui()
	var eye=Button.new()
	eye.name="HotbarEye"
	eye.text="👁"
	eye.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	eye.position=Vector2(230,-250)
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
		var parts=key.split("|"); return "%s %s" % [_rarity_name(str(parts[1])),str(parts[0])]
	return key

func _refresh_hotbar() -> void:
	if hotbar==null: return
	var variants=["gumus","yesil","buz","gunes","lav"]
	var names=["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
	for i in range(mini(6,hotbar.get_child_count())):
		var b=hotbar.get_child(i) as TextureButton
		if b==null: continue
		var key=str(hotbar_items[i])
		b.texture_normal=null
		b.tooltip_text=_hotbar_item_title(key)
		b.visible=not hotbar_hidden
		for child in b.get_children(): child.queue_free()
		if "|" in key:
			var parts=key.split("|")
			var item_name=str(parts[0])
			var variant=str(parts[1])
			var col=variants.find(variant)
			var row=names.find(item_name)+1
			if col>=0:
				var bg=TextureRect.new()
				bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				bg.texture=_store_png_texture(STORE_SLOT_BG[col])
				bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
				bg.stretch_mode=TextureRect.STRETCH_SCALE
				bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
				b.add_child(bg)
			if row>0 and col>=0:
				var icon=TextureRect.new()
				icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				icon.texture=_store_png_texture("res://weapon%d%s.png" % [row,variant])
				icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
				b.add_child(icon)
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
	_save_hotbar_state()
	_select_hotbar(target)
	_refresh_inventory()
	_close_inventory_item_actions()


func _save_hotbar_state() -> void:
	var cfg=ConfigFile.new(); cfg.load("user://player.cfg"); cfg.set_value("inventory","hotbar",hotbar_items); cfg.save("user://player.cfg")

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
	if hotbar_label and hotbar_label.text=="Envantere gönderiliyor...": hotbar_label.text=""

func _hotbar_drop_countdown(slot:int,key:String,token:int) -> void:
	if hotbar_label: hotbar_label.text="Envantere gönderiliyor..."
	var b=hotbar.get_child(slot) as TextureButton
	var overlay=ProgressBar.new()
	overlay.name="ReturnProgress"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
	overlay.min_value=0; overlay.max_value=1.5; overlay.value=0
	overlay.show_percentage=false
	var bg=StyleBoxFlat.new(); bg.bg_color=Color(0,0,0,0)
	var fill=StyleBoxFlat.new(); fill.bg_color=Color(.20,.72,.28,.55)
	overlay.add_theme_stylebox_override("background",bg); overlay.add_theme_stylebox_override("fill",fill)
	b.add_child(overlay)
	var elapsed:=0.0
	while elapsed<1.5:
		await get_tree().process_frame
		if not hotbar_hold_started.has(slot) or int(hotbar_hold_started[slot])!=token:
			if is_instance_valid(overlay): overlay.queue_free()
			return
		elapsed=(Time.get_ticks_msec()-token)/1000.0
		overlay.value=minf(elapsed,1.5)
	hotbar_hold_started.erase(slot)
	if is_instance_valid(overlay): overlay.queue_free()
	_return_hotbar_to_inventory(slot,key)

func _return_hotbar_to_inventory(slot:int,key:String) -> void:
	if slot<0 or slot>=hotbar_items.size(): return
	if str(hotbar_items[slot])!=key: return
	hotbar_items[slot]=""
	_save_hotbar_state()
	selected_tool=""
	if hotbar_label: hotbar_label.text="Envantere gönderildi"
	_refresh_hotbar()
	_refresh_inventory()

func _drop_hotbar_stack(slot:int,key:String) -> void:
	var amount=int(crafted_inventory.get(key,0))
	if amount<=0: return
	crafted_inventory.erase(key)
	hotbar_items[slot]=""
	_save_hotbar_state()
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
	_refresh_player_weapon_model()
	_refresh_hotbar()


func _hide_hotbar_feedback_later(token:int) -> void:
	await get_tree().create_timer(4.0).timeout
	if token!=hotbar_feedback_token: return
	if hotbar_label: hotbar_label.text=""
	# Keep the equipped item selected; only the temporary name label expires.
	_refresh_hotbar()


func _refresh_foundation_position_labels(layer:CanvasLayer) -> void:
	for label in foundation_position_labels:
		if is_instance_valid(label): label.queue_free()
	foundation_position_labels.clear()
	var number:int=1
	for foundation in built_floors:
		if not is_instance_valid(foundation): continue
		var label=Label.new()
		var p:Vector3=foundation.global_position
		label.text="T%d  X:%.1f Y:%.1f Z:%.1f" % [number,p.x,p.y,p.z]
		label.position=Vector2(18,88+(number-1)*18)
		label.add_theme_font_size_override("font_size",12)
		label.mouse_filter=Control.MOUSE_FILTER_IGNORE
		layer.add_child(label); foundation_position_labels.append(label)
		number+=1

func _register_ground_foundation(pos:Vector3, layer:CanvasLayer) -> Node3D:
	var root=StaticBody3D.new()
	root.name="Temel_%03d" % (built_floors.size()+1)
	root.position=Vector3(pos.x,height_at(pos.x,pos.z),pos.z)
	root.set_meta("build_piece","TEMEL")
	var mi=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=Vector3(5.0,.45,5.0); mi.mesh=bm; mi.position=Vector3(0,.225,0); mi.material_override=_simple_mat(Color(.42,.23,.08)); root.add_child(mi)
	var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=Vector3(5.0,.45,5.0); cs.shape=sh; cs.position=Vector3(0,.225,0); root.add_child(cs)
	add_child(root); built_floors.append(root)
	_refresh_foundation_position_labels(layer)
	return root

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
	scope_stage=(scope_stage+1)%4
	scoped=scope_stage>0
	if camera:
		if scope_stage==1: camera.fov=48.0
		elif scope_stage==2: camera.fov=30.0
		elif scope_stage==3: camera.fov=16.0
		else: camera.fov=72.0
	if scope_overlay: scope_overlay.visible=scoped
	# Firearm scope also drives the Y Bot aiming stance.
	var item:=selected_tool.to_lower()
	var firearm=("pompal" in item or "tüfek" in item or "tufek" in item or "nişancı" in item or "nisanci" in item)
	if firearm:
		if scoped: _play_ybot_anim("Rifle Aiming Idle")
		else: _play_ybot_anim("Rifle Idle")

func _update_aim_marker():
	if aim_marker==null or camera==null: return
	var center=get_viewport().get_visible_rect().size*.5
	var origin=camera.project_ray_origin(center); var dir=camera.project_ray_normal(center)
	var q=PhysicsRayQueryParameters3D.create(origin,origin+dir*600.0)
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
	var standing_on_terrain=player.position.y<=ground_y+0.25 and player.velocity.y<=0.05
	if player.is_on_floor() or standing_on_terrain:
		player.position.y=maxf(player.position.y,ground_y+0.02)
		player.velocity.y=7.2
		if player_visual: player_visual.rotation_degrees.x=-8.0
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


func _make_muzzle_flame(pos:Vector3,key:String,forward:Vector3,persistent:bool=false,flash_scale:float=-1.0) -> Node3D:
	if fx_root==null: return null
	var col=_muzzle_color_for_key(key)
	var flame=Node3D.new(); fx_root.add_child(flame); flame.global_position=pos
	var dir=forward.normalized()
	if dir.length()<0.1: dir=Vector3(0,0,-1)
	# Compact irregular flash. No long cone/arrow geometry.
	var blobs=[
		[Vector3.ZERO,Vector3(.20,.15,.20)],
		[dir*.10+Vector3(.025,.018,0),Vector3(.15,.11,.20)],
		[dir*.18+Vector3(-.018,-.012,0),Vector3(.09,.07,.16)]
	]
	for data in blobs:
		var part=MeshInstance3D.new(); var mesh=SphereMesh.new(); mesh.radius=.5; mesh.height=1.0; part.mesh=mesh; part.position=data[0]; part.scale=data[1]
		var mat=StandardMaterial3D.new(); mat.albedo_color=col; mat.emission_enabled=true; mat.emission=col; mat.emission_energy_multiplier=6.0; part.material_override=mat; flame.add_child(part)
	var core=MeshInstance3D.new(); var cm=SphereMesh.new(); cm.radius=.5; cm.height=1.0; core.mesh=cm; core.scale=Vector3(.10,.08,.10)
	var white=StandardMaterial3D.new(); white.albedo_color=Color.WHITE; white.emission_enabled=true; white.emission=Color.WHITE; white.emission_energy_multiplier=8.0; core.material_override=white; flame.add_child(core)
	var final_scale:=muzzle_test_scale if flash_scale<0.0 else flash_scale
	flame.scale=Vector3.ONE*final_scale
	if not persistent:
		var timer=get_tree().create_timer(.075); timer.timeout.connect(flame.queue_free)
	return flame

func _spawn_shot_visual(pos:Vector3,key:String,forward:Vector3,flash_scale:float=-1.0) -> void:
	if fx_root==null: return
	var col=_muzzle_color_for_key(key)
	_make_muzzle_flame(pos,key,forward,false,flash_scale)
	# Smoke is twice the previous visual size and remains twice as long.
	var smoke=MeshInstance3D.new(); var smoke_mesh=SphereMesh.new(); smoke_mesh.radius=.20; smoke_mesh.height=.40; smoke.mesh=smoke_mesh
	var smoke_mat=StandardMaterial3D.new(); smoke_mat.albedo_color=Color(.35,.35,.35,.42); smoke_mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA; smoke.material_override=smoke_mat
	fx_root.add_child(smoke); smoke.global_position=pos
	var st=create_tween(); st.set_parallel(true); st.tween_property(smoke,"position",smoke.position+Vector3(0,.48,0)+forward.normalized()*.28,.84); st.tween_property(smoke,"scale",Vector3(4.4,4.4,4.4),.84); st.tween_property(smoke_mat,"albedo_color:a",0.0,.84); st.chain().tween_callback(smoke.queue_free)
	for i in 4:
		var spark=MeshInstance3D.new(); var sp=SphereMesh.new(); sp.radius=.018; sp.height=.036; spark.mesh=sp
		var spmat=StandardMaterial3D.new(); spmat.albedo_color=col; spmat.emission_enabled=true; spmat.emission=col; spmat.emission_energy_multiplier=3.0; spark.material_override=spmat
		fx_root.add_child(spark); spark.global_position=pos
		var tw=create_tween(); tw.tween_property(spark,"position",spark.position+forward.normalized()*randf_range(.18,.42)+Vector3(randf_range(-.18,.18),randf_range(-.10,.22),randf_range(-.18,.18)),.13); tw.tween_callback(spark.queue_free)
	# Casings keep the liked ejection side, but land with random spread and sit exactly on terrain.
	var casing=MeshInstance3D.new(); var shell=CylinderMesh.new(); shell.top_radius=.018; shell.bottom_radius=.018; shell.height=.055; casing.mesh=shell
	var shell_mat=StandardMaterial3D.new(); shell_mat.albedo_color=Color(.72,.48,.12); shell_mat.metallic=.75; shell_mat.roughness=.35; casing.material_override=shell_mat
	fx_root.add_child(casing); casing.global_position=pos+Vector3(.08,.02,0)
	var side=Vector3(randf_range(.28,.62),0.0,randf_range(-.18,.30))
	var apex=casing.global_position+side+Vector3(0,randf_range(.18,.30),0)
	var land_x=casing.global_position.x+side.x+randf_range(-.20,.20)
	var land_z=casing.global_position.z+side.z+randf_range(-.20,.20)
	var land=Vector3(land_x,height_at(land_x,land_z)+.035,land_z)
	var ct=create_tween(); ct.tween_property(casing,"global_position",apex,.14); ct.tween_property(casing,"global_position",land,.34); ct.parallel().tween_property(casing,"rotation_degrees",Vector3(randf_range(70,110),randf_range(0,180),randf_range(-25,25)),.34); ct.tween_interval(4.8); ct.tween_callback(casing.queue_free)

func _npc_muzzle_flash(bot:Node3D) -> void:
	if fx_root==null or bot==null or not is_instance_valid(bot): return
	var id:=bot.get_instance_id()
	var key=str(bot_weapon_keys.get(id,""))
	if key.is_empty() or "|" not in key: return
	var item=str(key.split("|")[0])
	var weapon:Node3D=bot_weapon_nodes.get(id,null)
	if weapon==null or not is_instance_valid(weapon): return
	var offset:Vector3=muzzle_offsets.get(item,Vector3.ZERO)
	var shot_scale:float=float(muzzle_scales.get(item,0.68))
	var forward:Vector3=-weapon.global_transform.basis.z
	var pos:Vector3=weapon.to_global(offset)
	_spawn_shot_visual(pos,key,forward,shot_scale)
	var flash=OmniLight3D.new()
	flash.light_color=_muzzle_color_for_key(key); flash.light_energy=4.0; flash.omni_range=3.5
	fx_root.add_child(flash); flash.global_position=pos
	var t=get_tree().create_timer(.14); t.timeout.connect(flash.queue_free)

func _muzzle_weapon_name() -> String:
	var key:=_selected_weapon_key()
	if key.is_empty() or "|" not in key: return ""
	return str(key.split("|")[0])

func _load_muzzle_calibration() -> void:
	var item:=_muzzle_weapon_name()
	if muzzle_offsets.has(item): muzzle_test_offset=muzzle_offsets[item]
	if muzzle_scales.has(item): muzzle_test_scale=float(muzzle_scales[item])
	_update_muzzle_test_label()

func _muzzle_test_move(delta_position:Vector3) -> void:
	if not cheat_mode or not cheat_muzzle_tuner: return
	muzzle_test_offset+=delta_position
	var item:=_muzzle_weapon_name()
	if not item.is_empty(): muzzle_offsets[item]=muzzle_test_offset
	_update_muzzle_test_label()
	_preview_muzzle_flash()

func _muzzle_test_resize(delta_scale:float) -> void:
	if not cheat_mode or not cheat_muzzle_tuner: return
	muzzle_test_scale=clampf(muzzle_test_scale+delta_scale,0.10,1.20)
	var item:=_muzzle_weapon_name()
	if not item.is_empty(): muzzle_scales[item]=muzzle_test_scale
	_update_muzzle_test_label()
	_preview_muzzle_flash()

func _update_muzzle_test_label() -> void:
	if muzzle_test_label:
		muzzle_test_label.text="NAMLU TEST X:%.2f Y:%.2f Z:%.2f  BOYUT:%d%%  %s" % [muzzle_test_offset.x,muzzle_test_offset.y,muzzle_test_offset.z,roundi(muzzle_test_scale*100.0),("DONUK" if muzzle_calibration_frozen else "SERBEST")]

func _selected_weapon_key() -> String:
	for hotkey in hotbar_items:
		if _hotbar_item_title(str(hotkey))==selected_tool: return str(hotkey)
	return ""

func _muzzle_color_for_key(key:String) -> Color:
	var rarity="gumus"
	if "|" in key: rarity=str(key.split("|")[1])
	match rarity:
		"yesil": return Color(0.20,1.0,0.30)
		"buz": return Color(0.20,0.65,1.0)
		"gunes": return Color(1.0,0.78,0.10)
		"lav": return Color(1.0,0.12,0.05)
		_: return Color(0.92,0.95,1.0)

func _spawn_muzzle_light(origin:Node3D,key:String,local_offset:Vector3) -> void:
	if fx_root==null or origin==null or not is_instance_valid(origin): return
	var flash=OmniLight3D.new(); flash.light_color=_muzzle_color_for_key(key); flash.light_energy=5.0; flash.omni_range=3.2
	fx_root.add_child(flash); flash.global_position=origin.to_global(local_offset)
	var timer=get_tree().create_timer(.14); timer.timeout.connect(flash.queue_free)

func _clear_muzzle_preview() -> void:
	if muzzle_preview_node!=null and is_instance_valid(muzzle_preview_node): muzzle_preview_node.queue_free()
	muzzle_preview_node=null

func _preview_muzzle_flash() -> void:
	_clear_muzzle_preview()
	if not cheat_mode or not cheat_muzzle_tuner: return
	var key:=_selected_weapon_key()
	if key.is_empty() or player_weapon_node==null: return
	var item=str(key.split("|")[0])
	if not item in ["Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]: return
	muzzle_preview_node=_make_muzzle_flame(player_weapon_node.to_global(muzzle_test_offset),key,-player_weapon_node.global_transform.basis.z,true)

func _muzzle_flash():
	if fx_root==null or player_weapon_node==null: return
	var key:=_selected_weapon_key()
	_spawn_muzzle_light(player_weapon_node,key,muzzle_test_offset)
	_spawn_shot_visual(player_weapon_node.to_global(muzzle_test_offset),key,-player_weapon_node.global_transform.basis.z,muzzle_test_scale)

func _create_cheat_ui(layer:CanvasLayer):
	cheat_label=Label.new(); cheat_label.position=Vector2(510,10); cheat_label.size=Vector2(260,34); cheat_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; cheat_label.text=""; cheat_label.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(cheat_label)

func _toggle_cheat_mode():
	if _panel_open(): return
	cheat_mode=!cheat_mode
	if not cheat_mode:
		cheat_weapon_tuner=false; cheat_muzzle_tuner=false; cheat_sharpness_tuner=0; cheat_infinite_weapons=false; cheat_infinite_gj=false; cheat_infinite_power=false; cheat_foundation_place=false; cheat_foundation_remove=false; muzzle_calibration_frozen=false; _clear_sharpness_preview(); player_action_locked=false
		if fly_mode: fly_mode=false
		_clear_muzzle_preview()
	if cheat_menu_panel: cheat_menu_panel.visible=cheat_mode
	_sync_cheat_weapons(); _save_player_inventory(); _refresh_hotbar()
	if inventory_panel and inventory_panel.visible: _refresh_inventory()
	_update_cheat_button_style()
	_flash_message("HILE ACIK" if cheat_mode else "HILE KAPALI")

func _toggle_weapon_tuner() -> void:
	if not cheat_mode: return
	cheat_weapon_tuner=!cheat_weapon_tuner
	_update_cheat_button_style()

func _is_melee_key(key:String) -> bool:
	if key.is_empty() or "|" not in key: return false
	return str(key.split("|")[0]) in ["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana"]

func _sharpness_palette(key:String) -> Array[Color]:
	var rarity="gumus"
	if "|" in key: rarity=str(key.split("|")[1])
	match rarity:
		"yesil": return [Color(0.55,1.0,0.62,.18),Color(0.22,1.0,0.38,.30),Color(0.05,.78,.20,.48),Color(0.02,.42,.12,.72),Color(0.01,.16,.06,.95)]
		"buz": return [Color(.72,.96,1.0,.18),Color(.38,.82,1.0,.30),Color(.12,.56,1.0,.48),Color(.04,.27,.72,.72),Color(.01,.08,.30,.95)]
		"gunes": return [Color(1.0,.96,.58,.18),Color(1.0,.82,.20,.30),Color(1.0,.56,.05,.48),Color(.82,.28,.02,.72),Color(.35,.08,.01,.95)]
		"lav": return [Color(1.0,.62,.36,.18),Color(1.0,.28,.12,.30),Color(.92,.07,.04,.48),Color(.55,.015,.025,.72),Color(.20,.005,.012,.95)]
		_: return [Color(1,1,1,.18),Color(.90,.96,1,.30),Color(.70,.78,.86,.48),Color(.38,.45,.54,.72),Color(.12,.15,.20,.95)]

func _make_sharpness_effect(parent:Node3D,key:String,mode:int,persistent:bool=true,effect_offset:Vector3=Vector3(INF,INF,INF),effect_scale:float=-1.0,effect_angle:float=INF) -> Node3D:
	var root=Node3D.new(); parent.add_child(root)
	var palette:=_sharpness_palette(key)
	var length:=1.15 if mode==1 else 2.35
	# Five nested luminous layers create a continuous-looking phosphor-to-dark core,
	# rather than two flat colour bands.
	var widths=[.16,.125,.092,.060,.030]
	var line_count:=1 if mode==1 else 2
	for n in line_count:
		var xoff=0.0 if mode==1 else (-.10 if n==0 else .10)
		var zang=0.0 if mode==1 else (-18.0 if n==0 else -10.0)
		for li in range(5):
			var cut=MeshInstance3D.new(); var mesh=BoxMesh.new()
			mesh.size=Vector3(float(widths[li]),length,0.018+float(li)*.002); cut.mesh=mesh
			var mat=StandardMaterial3D.new(); var col:Color=palette[li]
			mat.albedo_color=col; mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.emission_enabled=true; mat.emission=Color(col.r,col.g,col.b); mat.emission_energy_multiplier=7.0-float(li)*.75
			cut.material_override=mat; cut.position=Vector3(xoff,0.18 if mode==1 else 0.0,float(li)*.001); cut.rotation_degrees.z=zang; root.add_child(cut)
	var use_offset:=sharpness_test_offset if is_inf(effect_offset.x) else effect_offset
	var use_scale:=sharpness_test_scale if effect_scale<0.0 else effect_scale
	var use_angle:=sharpness_test_angle if is_inf(effect_angle) else effect_angle
	root.position=use_offset; root.rotation_degrees.z=use_angle; root.scale=Vector3.ONE*use_scale
	if not persistent:
		if mode==2:
			var timer=get_tree().create_timer(.07); timer.timeout.connect(root.queue_free)
		else:
			var tw=create_tween(); tw.tween_property(root,"scale",root.scale*1.08,.07); tw.tween_property(root,"scale",root.scale*.98,.05); tw.tween_callback(root.queue_free)
	return root

func _clear_sharpness_preview() -> void:
	if sharpness_preview_node and is_instance_valid(sharpness_preview_node): sharpness_preview_node.queue_free()
	sharpness_preview_node=null

func _preview_sharpness() -> void:
	_clear_sharpness_preview()
	if not cheat_mode or cheat_sharpness_tuner<=0: return
	var key:=_selected_weapon_key()
	if not _is_melee_key(key) or player_weapon_node==null: return
	if cheat_sharpness_tuner==1:
		var vals:=_sharpness1_values(key)
		sharpness_preview_node=_make_sharpness_effect(player_weapon_node,key,1,true,vals.offset,vals.scale,vals.angle)
	else:
		var anchor=Node3D.new(); fx_root.add_child(anchor); anchor.global_position=player.global_position+Vector3(0,1.15,0)-player.global_transform.basis.z*1.25; anchor.global_rotation=player.global_rotation
		sharpness_preview_node=_make_sharpness_effect(anchor,key,2,true)

func _sharpness_move(v:Vector3) -> void:
	sharpness_test_offset+=v
	if cheat_sharpness_tuner==1:
		var k1:=_selected_weapon_key()
		if _is_melee_key(k1): sharpness1_offsets[str(k1.split("|")[0])]=sharpness_test_offset
	if cheat_sharpness_tuner==2:
		var key:=_selected_weapon_key()
		if _is_melee_key(key): sharpness2_offsets[str(key.split("|")[0])]=sharpness_test_offset
	_update_sharpness_label(); _preview_sharpness()

func _sharpness_adjust(ds:float,da:float) -> void:
	sharpness_test_scale=clampf(sharpness_test_scale+ds,.2,3.0); sharpness_test_angle=fposmod(sharpness_test_angle+da+180.0,360.0)-180.0
	if cheat_sharpness_tuner==1:
		var k1:=_selected_weapon_key()
		if _is_melee_key(k1):
			var i1:=str(k1.split("|")[0]); sharpness1_scales[i1]=sharpness_test_scale; sharpness1_angles[i1]=sharpness_test_angle
	if cheat_sharpness_tuner==2:
		var key:=_selected_weapon_key()
		if _is_melee_key(key):
			var item:=str(key.split("|")[0]); sharpness2_scales[item]=sharpness_test_scale; sharpness2_angle=sharpness_test_angle
	_update_sharpness_label(); _preview_sharpness()

func _update_sharpness_label() -> void:
	if sharpness_test_label: sharpness_test_label.text="KESKİNLİK %d  X:%.2f Y:%.2f Z:%.2f  BOYUT:%d%% AÇI:%d°" % [cheat_sharpness_tuner,sharpness_test_offset.x,sharpness_test_offset.y,sharpness_test_offset.z,roundi(sharpness_test_scale*100.0),roundi(sharpness_test_angle)]

func _toggle_sharpness_1() -> void:
	if not cheat_mode: return
	cheat_sharpness_tuner=0 if cheat_sharpness_tuner==1 else 1
	if cheat_sharpness_tuner==1:
		var key:=_selected_weapon_key()
		if _is_melee_key(key):
			var item:=str(key.split("|")[0]); sharpness_test_offset=sharpness1_offsets.get(item,Vector3.ZERO); sharpness_test_scale=float(sharpness1_scales.get(item,1.0)); sharpness_test_angle=float(sharpness1_angles.get(item,0.0))
	muzzle_calibration_frozen=false; player_action_locked=false; player_anim_name=&""
	if player_anim and is_instance_valid(player_anim): player_anim.play()
	cheat_muzzle_tuner=false; _clear_muzzle_preview(); _update_sharpness_label(); _preview_sharpness(); _update_cheat_button_style()

func _toggle_sharpness_2() -> void:
	if not cheat_mode: return
	cheat_sharpness_tuner=0 if cheat_sharpness_tuner==2 else 2
	if cheat_sharpness_tuner==2:
		var key:=_selected_weapon_key()
		if _is_melee_key(key):
			var item:=str(key.split("|")[0]); sharpness_test_offset=sharpness2_offsets.get(item,Vector3(-.15,.60,.57)); sharpness_test_scale=float(sharpness2_scales.get(item,1.0)); sharpness_test_angle=sharpness2_angle
	muzzle_calibration_frozen=false; player_action_locked=false; player_anim_name=&""
	if player_anim and is_instance_valid(player_anim): player_anim.play()
	cheat_muzzle_tuner=false; _clear_muzzle_preview(); _update_sharpness_label(); _preview_sharpness(); _update_cheat_button_style()

func _sharpness1_values(key:String) -> Dictionary:
	var item:=str(key.split("|")[0]) if "|" in key else ""
	return {
		"offset":sharpness1_offsets.get(item,Vector3.ZERO),
		"scale":float(sharpness1_scales.get(item,1.0)),
		"angle":float(sharpness1_angles.get(item,0.0))
	}

func _blade_trail(weapon:Node3D,key:String,duration:float) -> void:
	if weapon==null or not is_instance_valid(weapon) or fx_root==null or not _is_melee_key(key): return
	var vals:=_sharpness1_values(key)
	var elapsed:=0.0
	while elapsed<duration and weapon!=null and is_instance_valid(weapon):
		var ghost=_make_sharpness_effect(weapon,key,1,true,vals.offset,vals.scale,vals.angle)
		ghost.reparent(fx_root,true)
		var tw=create_tween(); tw.tween_interval(.10); tw.tween_property(ghost,"scale",ghost.scale*.82,.12); tw.tween_callback(ghost.queue_free)
		await get_tree().create_timer(.035).timeout
		elapsed+=.035

func _spawn_melee_sharpness(key:String) -> void:
	# Keskinlik 1 follows the blade for the whole attack and leaves a fading visible history.
	if not _is_melee_key(key) or player_weapon_node==null: return
	_blade_trail(player_weapon_node,key,maxf(player_action_duration,.30))

func _spawn_npc_melee_sharpness(bot:Node3D) -> void:
	if bot==null or not is_instance_valid(bot): return
	var id:=bot.get_instance_id()
	var key:=str(bot_weapon_keys.get(id,""))
	var weapon:Node3D=bot_weapon_nodes.get(id,null)
	if weapon==null or not is_instance_valid(weapon) or not _is_melee_key(key): return
	_blade_trail(weapon,key,.65)


func _spawn_local_kill_sharpness() -> void:
	# Local-only finisher. Called exclusively from damage caused by this player.
	var key:=_selected_weapon_key()
	if not _is_melee_key(key) or fx_root==null or player==null: return
	var item:=str(key.split("|")[0])
	var offset:Vector3=sharpness2_offsets.get(item,Vector3(-.15,.60,.57))
	var scale_value:float=float(sharpness2_scales.get(item,1.0))
	var anchor=Node3D.new(); fx_root.add_child(anchor)
	anchor.global_position=player.global_position+Vector3(0,1.15,0)-player.global_transform.basis.z*1.25
	anchor.global_rotation=player.global_rotation
	_make_sharpness_effect(anchor,key,2,false,offset,scale_value,sharpness2_angle)
	var timer=get_tree().create_timer(.08); timer.timeout.connect(anchor.queue_free)


func _toggle_muzzle_tuner() -> void:
	if not cheat_mode: return
	cheat_muzzle_tuner=!cheat_muzzle_tuner
	if cheat_muzzle_tuner: cheat_sharpness_tuner=0; _clear_sharpness_preview()
	if not cheat_muzzle_tuner:
		muzzle_calibration_frozen=false
		player_action_locked=false
	_load_muzzle_calibration()
	_update_cheat_button_style()
	_preview_muzzle_flash()

func _toggle_cheat_fly() -> void:
	if not cheat_mode: return
	_toggle_fly_mode()

func _toggle_infinite_weapons() -> void:
	if not cheat_mode: return
	cheat_infinite_weapons=!cheat_infinite_weapons
	_sync_cheat_weapons(); _save_player_inventory(); _refresh_hotbar()
	if inventory_panel and inventory_panel.visible: _refresh_inventory()
	_flash_message("SINIRSIZ SILAH ACIK" if cheat_infinite_weapons else "SINIRSIZ SILAH KAPALI")

func _toggle_cheat_foundation_place() -> void:
	if not cheat_mode: return
	cheat_foundation_place=not cheat_foundation_place
	if cheat_foundation_place: cheat_foundation_remove=false
	_flash_message("ZEMİNE TEMEL AÇIK • VUR İLE YERLEŞTİR" if cheat_foundation_place else "ZEMİNE TEMEL KAPALI")

func _toggle_cheat_foundation_remove() -> void:
	if not cheat_mode: return
	cheat_foundation_remove=not cheat_foundation_remove
	if cheat_foundation_remove: cheat_foundation_place=false
	_flash_message("TEMEL KALDIR AÇIK • VUR İLE KALDIR" if cheat_foundation_remove else "TEMEL KALDIR KAPALI")

func _toggle_infinite_power() -> void:
	if not cheat_mode: return
	cheat_infinite_power=!cheat_infinite_power
	_flash_message("SONSUZ GÜÇ AÇIK" if cheat_infinite_power else "SONSUZ GÜÇ KAPALI")

func _toggle_infinite_gj() -> void:
	if not cheat_mode: return
	cheat_infinite_gj=!cheat_infinite_gj
	_flash_message("SINIRSIZ GJ ACIK" if cheat_infinite_gj else "SINIRSIZ GJ KAPALI")

func _sync_cheat_weapons() -> void:
	var weapon_names=["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
	var weapon_rarities=["gumus","yesil","buz","gunes","lav"]
	for weapon_name in weapon_names:
		for rarity in weapon_rarities:
			var weapon_key="%s|%s" % [weapon_name,rarity]
			if cheat_mode and cheat_infinite_weapons:
				crafted_inventory[weapon_key]=1
			else:
				crafted_inventory.erase(weapon_key)
	if not (cheat_mode and cheat_infinite_weapons):
		for i in range(hotbar_items.size()):
			if "|" in str(hotbar_items[i]):
				hotbar_items[i]=""
		selected_tool=""
		_refresh_player_weapon_model()

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
