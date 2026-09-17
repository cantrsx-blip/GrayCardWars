extends Node3D

const ENEMY_COUNT := 12
var player: CharacterBody3D
var enemies: Array[CharacterBody3D] = []
var boss: CharacterBody3D
var hp := 100
var wood := 0
var stone := 0
var ammo := 40
var boss_hp := 300
var fire_built := false
var house_parts := 0
var boat_built := false
var hud: Label
var move_touch := Vector2.ZERO
var move_touch_id := -1
var move_origin := Vector2.ZERO
var build_origin := Vector3.ZERO

func _ready():
	_build_environment()
	_build_player()
	_spawn_resources()
	_spawn_enemies()
	_spawn_boss()
	_build_ui()

func _mat(c: Color) -> StandardMaterial3D:
	var m=StandardMaterial3D.new(); m.albedo_color=c; m.roughness=0.8; return m

func _box(pos:Vector3,size:Vector3,c:Color,collide:=true)->Node3D:
	var root:Node3D = StaticBody3D.new() if collide else Node3D.new()
	root.position=pos
	var mi=MeshInstance3D.new(); var bm=BoxMesh.new(); bm.size=size; mi.mesh=bm; mi.material_override=_mat(c); root.add_child(mi)
	if collide:
		var cs=CollisionShape3D.new(); var sh=BoxShape3D.new(); sh.size=size; cs.shape=sh; root.add_child(cs)
	add_child(root); return root

func _build_environment():
	var world=WorldEnvironment.new(); var env=Environment.new()
	env.background_mode=Environment.BG_COLOR; env.background_color=Color(0.52,0.72,0.88)
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color=Color(0.75,0.82,0.9); env.ambient_light_energy=0.75
	env.tonemap_mode=Environment.TONE_MAPPER_FILMIC; world.environment=env; add_child(world)
	var sun=DirectionalLight3D.new(); sun.rotation_degrees=Vector3(-55,-35,0); sun.shadow_enabled=true; sun.light_energy=1.2; add_child(sun)
	_box(Vector3(0,-0.5,0),Vector3(180,1,180),Color(0.18,0.38,0.14))
	for i in 30:
		var p=Vector3(randf_range(-75,75),0,randf_range(-75,75))
		var trunk=_box(p+Vector3(0,2,0),Vector3(0.8,4,0.8),Color(0.28,0.13,0.05)); trunk.set_meta("resource","wood")
		var crown=MeshInstance3D.new(); var s=SphereMesh.new(); s.radius=2.3; s.height=4.6; crown.mesh=s; crown.position=p+Vector3(0,5,0); crown.material_override=_mat(Color(0.08,0.34,0.10)); add_child(crown)
	for i in 22:
		var p=Vector3(randf_range(-75,75),0,randf_range(-75,75)); var r=_box(p+Vector3(0,0.5,0),Vector3(1.4,1,1.2),Color(0.34,0.36,0.38)); r.set_meta("resource","stone")
	# water + dock target
	var water=MeshInstance3D.new(); var pm=PlaneMesh.new(); pm.size=Vector2(180,35); water.mesh=pm; water.position=Vector3(0,0.03,-72); water.material_override=_mat(Color(0.05,0.30,0.52)); add_child(water)

func _build_player():
	player=CharacterBody3D.new(); player.position=Vector3(0,1,8)
	var cs=CollisionShape3D.new(); var cap=CapsuleShape3D.new(); cap.radius=.45; cap.height=1.8; cs.shape=cap; player.add_child(cs)
	var body=MeshInstance3D.new(); var cm=CapsuleMesh.new(); cm.radius=.42; cm.height=1.5; body.mesh=cm; body.material_override=_mat(Color(0.16,0.20,0.25)); player.add_child(body)
	var cam=Camera3D.new(); cam.position=Vector3(0,6.5,8.5); cam.rotation_degrees.x=-30; cam.current=true; player.add_child(cam); add_child(player)

func _spawn_resources():
	pass

func _enemy_mesh(c:Color)->MeshInstance3D:
	var mi=MeshInstance3D.new(); var cm=CapsuleMesh.new(); cm.radius=.5; cm.height=1.8; mi.mesh=cm; mi.material_override=_mat(c); return mi

func _spawn_enemies():
	for i in ENEMY_COUNT:
		var e=CharacterBody3D.new(); e.position=Vector3(randf_range(-60,60),1,randf_range(-60,60)); e.add_child(_enemy_mesh(Color(0.42,0.08,0.08))); e.set_meta("hp",60); add_child(e); enemies.append(e)

func _spawn_boss():
	boss=CharacterBody3D.new(); boss.position=Vector3(0,1,-50); var m=_enemy_mesh(Color(0.12,0.04,0.04)); m.scale=Vector3(2.2,2.2,2.2); boss.add_child(m); add_child(boss)

func _build_ui():
	var layer=CanvasLayer.new(); add_child(layer); hud=Label.new(); hud.position=Vector2(18,18); hud.add_theme_font_size_override("font_size",20); layer.add_child(hud)
	var help=Label.new(); help.position=Vector2(18,120); help.text="Sol tarafta surukle: Hareket"; layer.add_child(help)
	var buttons=[["TOPLA","interact"],["ATES","shoot"],["KAMP","build_fire"],["EV","build_house"],["BOT","build_boat"]]
	for i in buttons.size():
		var b=Button.new(); b.text=buttons[i][0]; b.position=Vector2(get_viewport().get_visible_rect().size.x-150,120+i*72); b.size=Vector2(125,58); layer.add_child(b)
		if buttons[i][1]=="shoot": b.pressed.connect(_shoot)
		elif buttons[i][1]=="interact": b.pressed.connect(_gather)
		elif buttons[i][1]=="build_fire": b.pressed.connect(_build_fire)
		elif buttons[i][1]=="build_house": b.pressed.connect(_build_house)
		elif buttons[i][1]=="build_boat": b.pressed.connect(_build_boat)

func _physics_process(delta):
	var v=Input.get_vector("move_left","move_right","move_forward","move_back")
	if move_touch.length() > 0.05:
		v = move_touch
	player.velocity=Vector3(v.x,0,v.y)*7.0; player.move_and_slide()
	for e in enemies:
		if not is_instance_valid(e): continue
		var d=player.global_position-e.global_position
		if d.length()<18:
			e.velocity=d.normalized()*2.4; e.move_and_slide()
			if d.length()<1.5: hp=max(0,hp-int(delta*12.0))
	if is_instance_valid(boss) and boss_hp>0:
		var d=player.global_position-boss.global_position
		if d.length()<28: boss.velocity=d.normalized()*1.7; boss.move_and_slide()
		if d.length()<2.2: hp=max(0,hp-int(delta*20.0))
	hud.text="HP %d | Odun %d | Tas %d | Mermi %d\nBoss HP %d | Ev %d/6 | Ates %s | Bot %s" % [hp,wood,stone,ammo,max(0,boss_hp),house_parts,str(fire_built),str(boat_built)]

func _input(event):
	if event is InputEventScreenTouch:
		var screen_w = get_viewport().get_visible_rect().size.x
		if event.pressed and event.position.x < screen_w * 0.55 and move_touch_id == -1:
			move_touch_id = event.index
			move_origin = event.position
		elif not event.pressed and event.index == move_touch_id:
			move_touch_id = -1
			move_touch = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == move_touch_id:
		move_touch = ((event.position - move_origin) / 85.0).limit_length(1.0)

func _unhandled_input(event):
	if event.is_action_pressed("interact"): _gather()
	if event.is_action_pressed("build_fire"): _build_fire()
	if event.is_action_pressed("build_house"): _build_house()
	if event.is_action_pressed("build_boat"): _build_boat()
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed: _shoot()

func _gather():
	for n in get_children():
		if n.has_meta("resource") and n.global_position.distance_to(player.global_position)<4:
			if n.get_meta("resource")=="wood": wood+=10
			else: stone+=8
			n.queue_free(); return

func _shoot():
	if ammo<=0:return
	ammo-=1
	var best:CharacterBody3D=null; var bd=16.0
	for e in enemies:
		if is_instance_valid(e):
			var d=e.global_position.distance_to(player.global_position)
			if d<bd: bd=d; best=e
	if is_instance_valid(boss):
		var d=boss.global_position.distance_to(player.global_position)
		if d < bd:
			boss_hp -= 25
			if boss_hp <= 0:
				boss.queue_free()
			return
	if best:
		var ehp=int(best.get_meta("hp"))-30; best.set_meta("hp",ehp)
		if ehp<=0: best.queue_free()

func _build_fire():
	if fire_built or wood<15 or stone<5:return
	wood-=15; stone-=5; fire_built=true
	var p=player.global_position+Vector3(2,0,0)
	for i in 6:
		var log=_box(p+Vector3(cos(i)*.7,.15,sin(i)*.7),Vector3(.8,.25,.25),Color(0.30,0.12,0.03),false); log.rotation.y=i
	var flame=OmniLight3D.new(); flame.position=p+Vector3(0,1.2,0); flame.light_color=Color(1,.45,.12); flame.omni_range=8; flame.light_energy=4; add_child(flame)

func _build_house():
	if house_parts>=6 or wood<20:return
	wood-=20
	if house_parts == 0:
		build_origin = player.global_position + Vector3(5,0,0)
	house_parts+=1
	var base=build_origin; var idx=house_parts-1
	var parts=[Vector3(0,.2,0),Vector3(0,1.7,-2.5),Vector3(0,1.7,2.5),Vector3(-2.5,1.7,0),Vector3(2.5,1.7,0),Vector3(0,3.5,0)]
	var sizes=[Vector3(5,.4,5),Vector3(5,3,.3),Vector3(5,3,.3),Vector3(.3,3,5),Vector3(.3,3,5),Vector3(5,.3,5)]
	_box(base+parts[idx],sizes[idx],Color(0.42,0.23,0.08))

func _build_boat():
	if boat_built or wood<40:return
	wood-=40; boat_built=true; var p=Vector3(player.global_position.x,.45,-70)
	_box(p,Vector3(3,.5,6),Color(0.35,0.16,0.05),false); _box(p+Vector3(0,.8,1),Vector3(2,.8,1.5),Color(0.48,0.25,0.08),false)
