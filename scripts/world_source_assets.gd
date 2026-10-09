extends Node3D
class_name WorldSourceAssets

@export_file("*.glb", "*.gltf") var primary_world_path := "res://assets/imported/world/22.glb"
@export_file("*.glb", "*.gltf") var fuji_path := "res://assets/imported/world/japanfuji.glb"
@export var primary_world_max_span := 82.0
@export var fuji_max_span := 115.0
@export var fuji_distance := -72.0

var primary_world_loaded := false
var fuji_loaded := false

func _ready() -> void:
    _load_world_model(primary_world_path, primary_world_max_span, 0.0, "ImportedMainWorld", true)
    _load_world_model(fuji_path, fuji_max_span, fuji_distance, "MountFujiBackdrop", false)
    if not fuji_loaded:
        _create_fallback_fuji()

func has_primary_world() -> bool:
    return primary_world_loaded

func _load_world_model(path: String, max_span: float, target_z: float, node_name: String, is_primary: bool) -> void:
    if not ResourceLoader.exists(path):
        print("NINJA: Optional world model not found; procedural fallback remains active: ", path)
        return

    var packed := load(path) as PackedScene
    if packed == null:
        push_warning("NINJA: Could not load world model as PackedScene: %s" % path)
        return

    var model := packed.instantiate() as Node3D
    if model == null:
        push_warning("NINJA: World model root is not Node3D: %s" % path)
        return

    model.name = node_name
    add_child(model)

    var bounds := _calculate_bounds(model)
    if bounds.size.length() < 0.01:
        model.queue_free()
        push_warning("NINJA: World model has no visible mesh bounds: %s" % path)
        return

    var largest := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
    var factor := max_span / maxf(largest, 0.01)
    model.scale = Vector3.ONE * factor
    model.position = Vector3(
        -bounds.get_center().x * factor,
        -bounds.position.y * factor,
        target_z - bounds.get_center().z * factor
    )

    if is_primary:
        primary_world_loaded = true
    else:
        fuji_loaded = true
    print("NINJA: Loaded 3D world asset %s at scale %.4f" % [path, factor])

func _calculate_bounds(root: Node3D) -> AABB:
    var found := false
    var combined := AABB()
    var stack: Array[Node] = [root]
    while not stack.is_empty():
        var current: Node = stack.pop_back()
        if current is MeshInstance3D:
            var mesh_instance := current as MeshInstance3D
            if mesh_instance.mesh != null:
                var local_bounds := mesh_instance.get_aabb()
                var transformed := mesh_instance.global_transform * local_bounds
                if not found:
                    combined = transformed
                    found = true
                else:
                    combined = combined.merge(transformed)
        for child in current.get_children():
            stack.append(child)
    return combined if found else AABB()


func _create_fallback_fuji() -> void:
    # A smooth, distant mountain silhouette keeps the horizon natural while
    # the real Alembic model is being imported/uploaded.
    var mountain := Node3D.new()
    mountain.name = "ProceduralFujiFallback"
    mountain.position = Vector3(0.0, -1.0, fuji_distance - 8.0)
    add_child(mountain)

    var rock := StandardMaterial3D.new()
    rock.albedo_color = Color(0.075, 0.085, 0.105, 1.0)
    rock.roughness = 0.96
    var snow := StandardMaterial3D.new()
    snow.albedo_color = Color(0.68, 0.73, 0.79, 1.0)
    snow.roughness = 0.88

    var body := MeshInstance3D.new()
    body.name = "FujiRock"
    body.mesh = _mountain_mesh(46.0, 48.0, 64, 26, 0.0)
    body.material_override = rock
    mountain.add_child(body)

    var cap := MeshInstance3D.new()
    cap.name = "FujiSnowCap"
    cap.mesh = _mountain_mesh(46.0, 48.0, 64, 16, 0.73)
    cap.material_override = snow
    mountain.add_child(cap)

func _mountain_mesh(base_radius: float, mountain_height: float, segments: int, rings: int, start_height_ratio: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var start_ring := int(round(float(rings) * start_height_ratio))
    for ring in range(start_ring, rings):
        var t0 := float(ring) / float(rings)
        var t1 := float(ring + 1) / float(rings)
        var r0 := maxf(0.12, base_radius * pow(1.0 - t0, 1.18))
        var r1 := maxf(0.12, base_radius * pow(1.0 - t1, 1.18))
        for segment in range(segments):
            var a0 := TAU * float(segment) / float(segments)
            var a1 := TAU * float(segment + 1) / float(segments)
            var wobble00 := 1.0 + 0.035 * sin(a0 * 7.0 + float(ring) * 0.7)
            var wobble01 := 1.0 + 0.035 * sin(a1 * 7.0 + float(ring) * 0.7)
            var p00 := Vector3(cos(a0) * r0 * wobble00, t0 * mountain_height, sin(a0) * r0 * wobble00)
            var p01 := Vector3(cos(a1) * r0 * wobble01, t0 * mountain_height, sin(a1) * r0 * wobble01)
            var p10 := Vector3(cos(a0) * r1, t1 * mountain_height, sin(a0) * r1)
            var p11 := Vector3(cos(a1) * r1, t1 * mountain_height, sin(a1) * r1)
            tool.add_vertex(p00)
            tool.add_vertex(p10)
            tool.add_vertex(p01)
            tool.add_vertex(p01)
            tool.add_vertex(p10)
            tool.add_vertex(p11)
    tool.generate_normals()
    return tool.commit()
