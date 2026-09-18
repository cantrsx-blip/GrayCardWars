extends Node

var decorated := false

func _process(_delta):
	if decorated: return
	var main=get_tree().current_scene
	if main:
		decorate(main)
		decorated=true

func decorate(main:Node):
	var rng=RandomNumberGenerator.new(); rng.seed=424242
	var quad=QuadMesh.new(); quad.size=Vector2(.55,.75)
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(.22,.50,.13); mat.roughness=1.0; mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	quad.material=mat
	var mm=MultiMesh.new(); mm.transform_format=MultiMesh.TRANSFORM_3D; mm.mesh=quad
	var transforms:Array[Transform3D]=[]
	while transforms.size()<360:
		var x=rng.randf_range(-195.0,195.0); var z=rng.randf_range(-195.0,195.0)
		if Vector2(x,z).length()<21.0 or near_boss(main,x,z): continue
		var y=main.call("height_at",x,z) if main.has_method("height_at") else 0.0
		var basis=Basis(Vector3.UP,rng.randf_range(0.0,TAU)).scaled(Vector3(rng.randf_range(.75,1.25),rng.randf_range(.8,1.35),1.0))
		transforms.append(Transform3D(basis,Vector3(x,y+.38,z)))
	mm.instance_count=transforms.size()
	for i in transforms.size(): mm.set_instance_transform(i,transforms[i])
	var grass=MultiMeshInstance3D.new(); grass.name="GrassMultiMesh"; grass.multimesh=mm; main.add_child(grass)

func near_boss(main:Node,x:float,z:float)->bool:
	var list=main.get("bosses")
	if list==null: return false
	for b in list:
		var p:Vector3=b["pos"]
		if Vector2(x-p.x,z-p.z).length()<42.0: return true
	return false
