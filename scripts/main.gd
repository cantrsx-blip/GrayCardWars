extends Node3D

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

func _ready():
    _build_world()
    _build_player()
    _build_hud()

func _build_world():
    var ground = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(160,160)
    ground.mesh = plane
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.18,0.42,0.16)
    ground.material_override = mat
    add_child(ground)
    for i in 24:
        var rock = MeshInstance3D.new()
        var mesh = BoxMesh.new()
        mesh.size = Vector3(1.5,1.5,1.5)
        rock.mesh = mesh
        rock.position = Vector3(randf_range(-55,55),0.75,randf_range(-55,55))
        add_child(rock)
    for i in 28:
        var tree = MeshInstance3D.new()
        var mesh = CylinderMesh.new()
        mesh.top_radius = 0.35
        mesh.bottom_radius = 0.55
        mesh.height = 4.0
        tree.mesh = mesh
        tree.position = Vector3(randf_range(-60,60),2,randf_range(-60,60))
        var m = StandardMaterial3D.new()
        m.albedo_color = Color(0.28,0.15,0.06)
        tree.material_override = m
        add_child(tree)

func _build_player():
    player = CharacterBody3D.new()
    player.position = Vector3(0,1,0)
    add_child(player)
    var body = MeshInstance3D.new()
    var capsule = CapsuleMesh.new()
    capsule.height = 1.8
    capsule.radius = 0.45
    body.mesh = capsule
    player.add_child(body)
    camera = Camera3D.new()
    camera.position = Vector3(0,7,9)
    camera.rotation_degrees.x = -32
    camera.current = true
    player.add_child(camera)

func _build_hud():
    var layer = CanvasLayer.new()
    add_child(layer)
    hud = Label.new()
    hud.position = Vector2(24,24)
    hud.add_theme_font_size_override("font_size",24)
    layer.add_child(hud)
    var help = Label.new()
    help.text = "GRAY CARD WARS  |  Sol tarafta surukle: hareket\nKaynak toplamak icin agac/kayaya yaklas"
    help.position = Vector2(24,110)
    help.add_theme_font_size_override("font_size",20)
    layer.add_child(help)

func _physics_process(delta):
    hunger = max(0, hunger - delta * 0.12)
    thirst = max(0, thirst - delta * 0.18)
    var v = move_touch
    if Input.is_key_pressed(KEY_W): v.y = -1
    if Input.is_key_pressed(KEY_S): v.y = 1
    if Input.is_key_pressed(KEY_A): v.x = -1
    if Input.is_key_pressed(KEY_D): v.x = 1
    var dir = Vector3(v.x,0,v.y)
    if dir.length() > 1: dir = dir.normalized()
    player.velocity = dir * 6.0
    player.move_and_slide()
    hud.text = "HP %d   Aclik %d   Susuzluk %d\nGray Card %d   Odun %d   Tas %d" % [health,hunger,thirst,gray_cards,wood,stone]

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
            if n.mesh is CylinderMesh:
                wood += 25
                n.queue_free()
                return
            if n.mesh is BoxMesh:
                stone += 20
                n.queue_free()
                return
