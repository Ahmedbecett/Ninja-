extends Node3D
class_name VisualQuality

@export var radius := 38.0

func _ready() -> void:
    # Wait until sibling asset loaders finish before deciding whether fallback
    # geometry is needed; never cover a successfully imported realistic scene.
    call_deferred("_build_terrain_details")

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

func _is_real_asset(path: String) -> bool:
    if not ResourceLoader.exists(path):
        return false
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var header := file.get_buffer(80).get_string_from_utf8()
    file.close()
    return not header.begins_with("version https://git-lfs.github.com/spec/v1")

func _grass_blade(pos: Vector3, height: float, width: float, mat: Material, yaw: float) -> void:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    var left := Vector3(-width * 0.5, 0.0, 0.0)
    var right := Vector3(width * 0.5, 0.0, 0.0)
    var tip := Vector3(0.0, height, 0.0)
    st.add_vertex(left)
    st.add_vertex(tip)
    st.add_vertex(right)
    st.add_vertex(right)
    st.add_vertex(tip)
    st.add_vertex(left)
    st.generate_normals()
    var blade := MeshInstance3D.new()
    blade.mesh = st.commit()
    blade.material_override = mat
    blade.position = pos
    blade.rotation.y = yaw
    add_child(blade)

func _build_terrain_details() -> void:
    var world_root := get_parent()
    var source_assets := world_root.get_node_or_null("WorldSourceAssets") as WorldSourceAssets
    var forest_loader := world_root.get_node_or_null("ImportedForest") as ImportedEnvironment
    var has_real_world := source_assets != null and source_assets.has_primary_world()
    var has_real_forest := forest_loader != null and is_instance_valid(forest_loader.loaded_environment)
    if has_real_world or has_real_forest:
        print("NINJA: Real imported world/forest detected; skipping synthetic grass, rocks, and soil overlays.")
        return

    var rng := RandomNumberGenerator.new()
    rng.seed = 448211
    var grass := _mat(Color(0.025,0.095,0.045,1),0.98)
    var grass2 := _mat(Color(0.055,0.14,0.065,1),0.98)
    var stone := _mat(Color(0.13,0.14,0.145,1),0.92)
    var soil := _mat(Color(0.095,0.065,0.045,1),1.0)
    var real_grass_available := _is_real_asset("res://assets/world/grass/Grass_pack.glb")
    if not real_grass_available:
        for i in range(260):
            var p := Vector3(rng.randf_range(-radius,radius),0.0,rng.randf_range(-radius,radius))
            if abs(p.z-3.0) < 3.6:
                continue
            var height := rng.randf_range(0.18,0.42)
            var width := rng.randf_range(0.07,0.14)
            var mat := grass if i % 2 == 0 else grass2
            _grass_blade(p, height, width, mat, rng.randf_range(0.0,TAU))
            if i % 3 == 0:
                _grass_blade(p + Vector3(0.04,0.0,0.035), height * 0.82, width * 0.8, grass2 if mat == grass else grass, rng.randf_range(0.0,TAU))

    for i in range(65):
        var p := Vector3(rng.randf_range(-radius,radius),0.02,rng.randf_range(-radius,radius))
        if abs(p.z-3.0) < 4.0:
            continue
        var rock_mesh := SphereMesh.new()
        rock_mesh.radius = rng.randf_range(0.18,0.55)
        rock_mesh.height = rock_mesh.radius * rng.randf_range(0.55,1.2)
        rock_mesh.radial_segments = 7
        rock_mesh.rings = 5
        var rock_n := MeshInstance3D.new()
        rock_n.mesh = rock_mesh
        rock_n.material_override = stone
        rock_n.position = p
        rock_n.scale = Vector3(rng.randf_range(0.8,1.4),rng.randf_range(0.65,1.0),rng.randf_range(0.8,1.35))
        rock_n.rotation.y = rng.randf_range(0.0,TAU)
        add_child(rock_n)

    for i in range(28):
        var p := Vector3(rng.randf_range(-34,34),0.025,rng.randf_range(-34,34))
        var patch := _box(self,p,Vector3(rng.randf_range(1.2,3.2),0.035,rng.randf_range(0.8,2.2)),soil)
        patch.rotation.y = rng.randf_range(0,TAU)
