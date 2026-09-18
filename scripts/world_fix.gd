extends Node

var player: CharacterBody3D
var decorated := false

func _process(_delta):
	if not decorated:
		var main = get_tree().current_scene
		if main:
			decorate(main)
			decorated = true

func find_player(n: Node) -> CharacterBody3D:
	if n == null:
		return null
	if n is CharacterBody3D:
		return n
	for c in n.get_children():
		var found = find_player(c)
		if found:
			return found
	return null

func decorate(main: Node):
	# Sky and daylight
	var env_node = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.32, 0.62, 0.88)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.72, 0.80, 0.90)
	env.ambient_light_energy = 0.75
	env_node.environment = env
	main.add_child(env_node)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	main.add_child(sun)

	# Dense low-cost grass outside boss dry zones and central trade zone.
	var rng = RandomNumberGenerator.new()
	rng.seed = 424242
	for i in 650:
		var x = rng.randf_range(-195.0, 195.0)
		var z = rng.randf_range(-195.0, 195.0)
		if Vector2(x, z).length() < 21.0:
			continue
		if near_boss(main, x, z):
			continue
		var tuft = MeshInstance3D.new()
		var mesh = QuadMesh.new()
		mesh.size = Vector2(rng.randf_range(0.35, 0.75), rng.randf_range(0.45, 0.95))
		tuft.mesh = mesh
		tuft.position = Vector3(x, mesh.size.y * 0.5, z)
		tuft.rotation_degrees.y = rng.randf_range(0.0, 180.0)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(rng.randf_range(0.18,0.30), rng.randf_range(0.42,0.62), rng.randf_range(0.10,0.20))
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		tuft.material_override = mat
		main.add_child(tuft)

func near_boss(main: Node, x: float, z: float) -> bool:
	if main.get("bosses") == null:
		return false
	for b in main.get("bosses"):
		var p: Vector3 = b["pos"]
		if Vector2(x - p.x, z - p.z).length() < 42.0:
			return true
	return false
