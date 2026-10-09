extends Node3D
class_name WorldAssetIntegration

@export var world_model_path := "res://assets/imported/world/world_22.glb"
@export var fuji_model_path := "res://assets/imported/world/japanfuji.glb"
@export var load_world_model := true
@export var world_target_size := 72.0
@export var fuji_target_size := 58.0
@export var fuji_position := Vector3(0.0, 0.0, -58.0)

func _ready() -> void:
    var loaded_world := false
    if load_world_model:
        loaded_world = _load_and_fit(world_model_path, "ImportedWorld22", world_target_size, Vector3.ZERO)
    var loaded_fuji := _load_and_fit(fuji_model_path, "ImportedMountFuji", fuji_target_size, fuji_position)
    if not loaded_fuji:
        _build_fuji_backdrop()
    if loaded_world:
        print("NINJA: Connected converted 22.blend world asset.")
    if loaded_fuji:
        print("NINJA: Connected converted Japan Fuji Alembic asset.")
    else:
        print("NINJA: Using procedural Fuji backdrop until japanfuji.abc is uploaded and converted.")

func _load_and_fit(path: String, node_name: String, target_size: float, target_position: Vector3) -> bool:
    if not ResourceLoader.exists(path) or _is_lfs_pointer(path):
        return false
    var packed := load(path) as PackedScene
    if packed == null:
        push_warning("NINJA: Could not load 3D world asset: " + path)
        return false
    var instance := packed.instantiate() as Node3D
    if instance == null:
        push_warning("NINJA: 3D world asset has no Node3D root: " + path)
        return false
    instance.name = node_name
    add_child(instance)
    var bounds := _combined_bounds(instance)
    if bounds.size.length() < 0.001:
        instance.queue_free()
        push_warning("NINJA: 3D world asset contains no visible meshes: " + path)
        return false
    var longest := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
    if longest <= 0.001:
        instance.queue_free()
        return false
    var factor := target_size / longest
    instance.scale = instance.scale * factor
    instance.position = target_position - Vector3(bounds.position.x + bounds.size.x * 0.5, bounds.position.y, bounds.position.z + bounds.size.z * 0.5) * factor
    return true

func _combined_bounds(root: Node3D) -> AABB:
    var found := false
    var combined := AABB()
    var stack: Array[Node] = [root]
    while not stack.is_empty():
        var current: Node = stack.pop_back()
        if current is MeshInstance3D:
            var mesh_instance := current as MeshInstance3D
            if mesh_instance.mesh != null:
                var transformed: AABB = mesh_instance.get_aabb() * mesh_instance.transform
                var parent := mesh_instance.get_parent()
                while parent != null and parent != root:
                    transformed = transformed * (parent as Node3D).transform
                    parent = parent.get_parent()
                if not found:
                    combined = transformed
                    found = true
                else:
                    combined = combined.merge(transformed)
        for child in current.get_children():
            stack.append(child)
    return combined if found else AABB()

func _is_lfs_pointer(path: String) -> bool:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var header := file.get_buffer(80).get_string_from_utf8()
    file.close()
    return header.begins_with("version https://git-lfs.github.com/spec/v1")

func _build_fuji_backdrop() -> void:
    var mountain := MeshInstance3D.new()
    mountain.name = "ProceduralFujiMountain"
    mountain.position = fuji_position
    mountain.mesh = _make_mountain_mesh()
    var rock := StandardMaterial3D.new()
    rock.albedo_color = Color(0.075, 0.095, 0.14, 1.0)
    rock.roughness = 0.96
    rock.vertex_color_use_as_albedo = true
    mountain.material_override = rock
    add_child(mountain)

    var snow := MeshInstance3D.new()
    snow.name = "FujiSnowCap"
    var snow_mesh := CylinderMesh.new()
    snow_mesh.top_radius = 0.15
    snow_mesh.bottom_radius = 7.0
    snow_mesh.height = 7.0
    snow_mesh.radial_segments = 48
    snow.mesh = snow_mesh
    var snow_mat := StandardMaterial3D.new()
    snow_mat.albedo_color = Color(0.72, 0.79, 0.86, 1.0)
    snow_mat.roughness = 0.88
    snow.material_override = snow_mat
    snow.position = fuji_position + Vector3(0.0, 20.0, 0.0)
    snow.scale = Vector3(1.0, 1.0, 0.72)
    add_child(snow)

func _make_mountain_mesh() -> ArrayMesh:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    var segments := 64
    var radii := [0.4, 3.0, 7.0, 13.0, 21.0, 31.0, 40.0]
    var heights := [25.0, 23.0, 19.0, 14.0, 8.0, 3.0, 0.0]
    for ring in range(radii.size() - 1):
        for seg in range(segments):
            var a0 := TAU * float(seg) / float(segments)
            var a1 := TAU * float(seg + 1) / float(segments)
            var jitter0 := 1.0 + 0.025 * sin(float(seg * 7 + ring * 11))
            var jitter1 := 1.0 + 0.025 * sin(float((seg + 1) * 7 + ring * 11))
            var p00 := Vector3(cos(a0) * radii[ring] * jitter0, heights[ring], sin(a0) * radii[ring] * jitter0)
            var p01 := Vector3(cos(a1) * radii[ring] * jitter1, heights[ring], sin(a1) * radii[ring] * jitter1)
            var p10 := Vector3(cos(a0) * radii[ring + 1] * jitter0, heights[ring + 1], sin(a0) * radii[ring + 1] * jitter0)
            var p11 := Vector3(cos(a1) * radii[ring + 1] * jitter1, heights[ring + 1], sin(a1) * radii[ring + 1] * jitter1)
            var shade0 := 0.72 - float(ring) * 0.055 + 0.025 * sin(a0 * 5.0)
            var shade1 := 0.72 - float(ring) * 0.055 + 0.025 * sin(a1 * 5.0)
            st.set_color(Color(shade0, shade0 * 1.08, minf(1.0, shade0 * 1.32), 1.0))
            st.add_vertex(p00)
            st.add_vertex(p10)
            st.add_vertex(p11)
            st.set_color(Color(shade1, shade1 * 1.08, minf(1.0, shade1 * 1.32), 1.0))
            st.add_vertex(p00)
            st.add_vertex(p11)
            st.add_vertex(p01)
    st.generate_normals()
    return st.commit()
