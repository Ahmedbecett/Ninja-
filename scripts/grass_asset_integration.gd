extends Node3D
class_name GrassAssetIntegration

@export_file("*.glb") var grass_scene_path := "res://assets/world/grass/Grass.glb"
@export_range(1, 160, 1) var instance_count := 72
@export var world_radius := 34.0
@export var min_distance_from_player := 5.0
@export var scale_min := 0.85
@export var scale_max := 1.35

var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    _rng.seed = 918273
    call_deferred("_load_and_place")

func _load_and_place() -> void:
    if not ResourceLoader.exists(grass_scene_path) or _is_lfs_pointer(grass_scene_path):
        push_warning("NINJA: Grass.glb is missing or is only a Git LFS pointer; keeping procedural vegetation active.")
        return

    var packed := load(grass_scene_path) as PackedScene
    if packed == null:
        push_error("NINJA: Failed to load Grass.glb as a PackedScene.")
        return

    var source := packed.instantiate()
    if source == null:
        push_error("NINJA: Failed to instantiate Grass.glb.")
        return

    add_child(source)
    var candidates: Array[MeshInstance3D] = []
    _collect_grass_meshes(source, candidates)

    if candidates.is_empty():
        # Some asset packs use generic node names. Fall back to every mesh so
        # a valid imported vegetation scene is not silently ignored.
        _collect_all_meshes(source, candidates)
    if candidates.is_empty():
        source.queue_free()
        push_warning("NINJA: Grass.glb contains no suitable MeshInstance3D nodes.")
        return

    var usable_count := mini(instance_count, candidates.size())
    for i in range(usable_count):
        var source_mesh := candidates[i]
        var copy := source_mesh.duplicate() as MeshInstance3D
        if copy == null:
            continue
        copy.name = "Grass_%03d" % i
        copy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        copy.position = _safe_position(i)
        copy.rotation.y = _rng.randf_range(0.0, TAU)
        var s := _rng.randf_range(scale_min, scale_max)
        copy.scale = Vector3(s, s, s)
        add_child(copy)

    source.queue_free()

func _collect_grass_meshes(root: Node, output: Array[MeshInstance3D]) -> void:
    var stack: Array[Node] = [root]
    while not stack.is_empty() and output.size() < instance_count:
        var current: Node = stack.pop_back()
        if current is MeshInstance3D and current.mesh != null and _looks_like_vegetation(current.name):
            output.append(current as MeshInstance3D)
        for child in current.get_children():
            stack.append(child)

func _collect_all_meshes(root: Node, output: Array[MeshInstance3D]) -> void:
    var stack: Array[Node] = [root]
    while not stack.is_empty() and output.size() < instance_count:
        var current: Node = stack.pop_back()
        if current is MeshInstance3D and current.mesh != null:
            output.append(current as MeshInstance3D)
        for child in current.get_children():
            stack.append(child)

func _looks_like_vegetation(node_name: String) -> bool:
    var n := node_name.to_lower()
    return n.contains("grass") or n.contains("clover") or n.contains("weed") or n.contains("flower") or n.contains("leaf") or n.contains("dandelion") or n.contains("nettle") or n.contains("wasteland")

func _safe_position(index: int) -> Vector3:
    var angle := float(index) * 2.399963
    var radius := sqrt(float(index + 1) / float(maxi(1, instance_count))) * world_radius
    var p := Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
    if p.distance_to(Vector3(0.0, 0.0, 5.0)) < min_distance_from_player:
        p += Vector3(7.0, 0.0, 7.0)
    return p
func _is_lfs_pointer(path: String) -> bool:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var header := file.get_buffer(80).get_string_from_utf8()
    file.close()
    return header.begins_with("version https://git-lfs.github.com/spec/v1")
