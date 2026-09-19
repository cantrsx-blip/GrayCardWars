extends Node

var decorated := false
var decorated_scene_id := 0

func _process(_delta):
	var scene=get_tree().current_scene
	if scene==null:
		decorated=false
		decorated_scene_id=0
		return
	var is_main=scene.name=="Main" or scene.scene_file_path.ends_with("Main.tscn")
	if not is_main:
		decorated=false
		decorated_scene_id=0
		return
	var scene_id=scene.get_instance_id()
	if decorated and decorated_scene_id==scene_id:
		return
	decorated=true
	decorated_scene_id=scene_id
	decorate.call_deferred(scene)

func decorate(main:Node):
	if main==null or not main.has_method("height_at"):
		return
	var rng=RandomNumberGenerator.new(); rng.seed=424242
	var quad=QuadMesh.new(); quad.size=Vector2(.55,.75)
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.22,.50,.13); mat.roughness=1.0; mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	if ResourceLoader.exists("res://assets/environment/plants/grass_billboard.png"):
		var grass_texture=ResourceLoader.load("res://assets/environment/plants/grass_billboard.png")
		if grass_texture is Texture2D:
			mat.albedo_texture=grass_texture
			mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	quad.material=mat
	var mm=MultiMesh.new(); mm.transform_format=MultiMesh.TRANSFORM_3D; mm.mesh=quad
	var transforms:Array[Transform3D]=[]
	while transforms.size()<360:
		var x=rng.randf_range(-195.0,195.0); var z=rng.randf_range(-195.0,195.0)
		if Vector2(x,z).length()<21.0 or near_poi(main,x,z): continue
		var y=float(main.call("height_at",x,z))
		var basis=Basis(Vector3.UP,rng.randf_range(0.0,TAU)).scaled(Vector3(rng.randf_range(.75,1.25),rng.randf_range(.8,1.35),1.0))
		transforms.append(Transform3D(basis,Vector3(x,y+.02,z)))
	mm.instance_count=transforms.size()
	for i in transforms.size(): mm.set_instance_transform(i,transforms[i])
	var grass=MultiMeshInstance3D.new(); grass.name="GrassMultiMesh"; grass.multimesh=mm; main.add_child(grass)

func near_poi(main:Node,x:float,z:float)->bool:
	var list=main.get("pois")
	if not (list is Array):
		return false
	for b in list:
		if not (b is Dictionary) or not b.has("pos"):
			continue
		var p:Vector3=b["pos"]
		if Vector2(x-p.x,z-p.z).length()<42.0: return true
	return false
