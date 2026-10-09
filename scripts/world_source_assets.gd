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
