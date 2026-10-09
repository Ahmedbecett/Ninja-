extends Node3D
class_name VisualQuality

@export var radius := 38.0

func _ready() -> void:
    _build_terrain_details()

func _mat(color: Color, rough := 0.9, metal := 0.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = rough
    m.metallic = metal
    return m

func _box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    n.mesh = mesh
    n.material_override = mat
    n.position = pos
    parent.add_child(n)
    return n

func _build_terrain_details() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 448211
    var grass := _mat(Color(0.025,0.095,0.045,1),0.98)
    var grass2 := _mat(Color(0.055,0.14,0.065,1),0.98)
    var stone := _mat(Color(0.13,0.14,0.145,1),0.92)
    var soil := _mat(Color(0.095,0.065,0.045,1),1.0)
    var real_grass_available := ResourceLoader.exists("res://assets/world/grass/Grass.glb")
    # Avoid drawing hundreds of box-shaped blades on top of the real vegetation asset.
    if not real_grass_available:
        for i in range(180):
            var p := Vector3(rng.randf_range(-radius,radius),0.0,rng.randf_range(-radius,radius))
            if abs(p.z-3.0) < 3.6:
                continue
            var blade := _box(self,p+Vector3(0,rng.randf_range(0.08,0.18),0),Vector3(rng.randf_range(0.025,0.055),rng.randf_range(0.16,0.34),rng.randf_range(0.025,0.055)),grass if i%2==0 else grass2)
            blade.rotation.y = rng.randf_range(0.0,6.28)
            blade.rotation.z = rng.randf_range(-0.18,0.18)

    for i in range(55):
        var p := Vector3(rng.randf_range(-radius,radius),0.03,rng.randf_range(-radius,radius))
        if abs(p.z-3.0) < 4.0:
            continue
        var stone_n := _box(self,p,Vector3(rng.randf_range(0.18,0.7),rng.randf_range(0.08,0.35),rng.randf_range(0.18,0.55)),stone)
        stone_n.rotation = Vector3(rng.randf_range(-0.2,0.2),rng.randf_range(0,6.28),rng.randf_range(-0.2,0.2))
    for i in range(28):
        var p := Vector3(rng.randf_range(-34,34),0.025,rng.randf_range(-34,34))
        var patch := _box(self,p,Vector3(rng.randf_range(1.2,3.2),0.035,rng.randf_range(0.8,2.2)),soil)
        patch.rotation.y = rng.randf_range(0,6.28)
