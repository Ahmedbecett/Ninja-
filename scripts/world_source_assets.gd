extends Node3D
class_name WorldSourceAssets

@export_file("*.glb", "*.gltf") var primary_world_path := "res://assets/imported/world/world_22.glb"
@export_file("*.glb", "*.gltf") var fuji_path := "res://assets/imported/world/japanfuji.glb"
@export var primary_world_max_span := 82.0
@export var fuji_max_span := 140.0
@export var fuji_distance := -85.0

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
    var combined := AABB()
    var has_box := false
    var stack: Array[Node] = [root]
    while not stack.is_empty():
        var node: Node = stack.pop_back()
        for child in node.get_children():
            stack.push_back(child)
        if node is VisualInstance3D:
            var box: AABB = (node as VisualInstance3D).get_aabb()
            if box.size.length() > 0.001:
                var xform: Transform3D = root.global_transform.affine_inverse() * (node as Node3D).global_transform
                var transformed: AABB = xform * box
                if not has_box:
                    combined = transformed
                    has_box = true
                else:
                    combined = combined.merge(transformed)
    return combined

func _create_fallback_fuji() -> void:
    var mountain := Node3D.new()
    mountain.name = "MountFujiScenicBackdrop"
    mountain.position = Vector3(18.0, -4.0, fuji_distance)
    add_child(mountain)

    # Realistic Sunset Alpine Rock & Snow Materials matching reference art
    var rock := StandardMaterial3D.new()
    rock.albedo_color = Color(0.18, 0.15, 0.22, 1.0) # Alpine purple twilight basalt
    rock.roughness = 0.94
    rock.metallic = 0.05

    var snow := StandardMaterial3D.new()
    snow.albedo_color = Color(0.96, 0.88, 0.86, 1.0) # Snow with warm sunset golden reflection
    snow.roughness = 0.72
    snow.emission_enabled = true
    snow.emission = Color(0.35, 0.25, 0.22, 1.0)
    snow.emission_energy_multiplier = 0.25

    # Majestic proportions: base radius 72m, height 78m
    var body := MeshInstance3D.new()
    body.name = "FujiRock"
    body.mesh = _mountain_mesh(72.0, 78.0, 80, 32, 0.0)
    body.material_override = rock
    mountain.add_child(body)

    var cap := MeshInstance3D.new()
    cap.name = "FujiSnowCap"
    cap.mesh = _mountain_mesh(72.0, 78.0, 80, 20, 0.68) # Beautiful curved snow cap
    cap.material_override = snow
    mountain.add_child(cap)

func _mountain_mesh(base_radius: float, mountain_height: float, segments: int, rings: int, start_height_ratio: float) -> ArrayMesh:
    var tool := SurfaceTool.new()
    tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    var start_ring := int(round(float(rings) * start_height_ratio))
    for ring in range(start_ring, rings):
        var t0 := float(ring) / float(rings)
        var t1 := float(ring + 1) / float(rings)
        # Elegant exponential curve of Mount Fuji's stratovolcano slopes
        var r0 := maxf(0.15, base_radius * pow(1.0 - t0, 1.25))
        var r1 := maxf(0.15, base_radius * pow(1.0 - t1, 1.25))
        for segment in range(segments):
            var a0 := TAU * float(segment) / float(segments)
            var a1 := TAU * float(segment + 1) / float(segments)
            var wobble00 := 1.0 + 0.025 * sin(a0 * 8.0 + float(ring) * 0.6)
            var wobble01 := 1.0 + 0.025 * sin(a1 * 8.0 + float(ring) * 0.6)
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
