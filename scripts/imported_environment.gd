extends Node3D
class_name ImportedEnvironment

@export_file("*.fbx", "*.glb", "*.gltf") var environment_scene_path := "res://assets/imported/forestpack/ForestPack.fbx"
@export var environment_scale := 1.0
@export var environment_position := Vector3.ZERO
@export var environment_rotation_degrees := Vector3.ZERO

var loaded_environment: Node3D

func _ready() -> void:
    _load_environment()

func _load_environment() -> void:
    var selected_path := environment_scene_path
    if not _is_real_scene_file(selected_path):
        selected_path = _find_forest_scene("res://assets/imported/forestpack")
    if selected_path.is_empty():
        push_warning("NINJA: No real ForestPack scene was found after archive extraction; the world source asset or procedural fallback will remain active.")
        return

    var packed := load(selected_path) as PackedScene
    if packed == null:
        push_error("NINJA: The imported environment file could not be loaded as a scene: %s" % selected_path)
        return
    loaded_environment = packed.instantiate() as Node3D
    if loaded_environment == null:
        push_error("NINJA: The environment scene root is not Node3D: %s" % selected_path)
        return
    loaded_environment.name = "ImportedForestPack"
    loaded_environment.position = environment_position
    loaded_environment.rotation_degrees = environment_rotation_degrees
    loaded_environment.scale = Vector3.ONE * environment_scale
    add_child(loaded_environment)
    print("NINJA: Loaded real imported forest scene: ", selected_path)

func _is_real_scene_file(path: String) -> bool:
    if path.is_empty() or not ResourceLoader.exists(path):
        return false
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var header := file.get_buffer(80).get_string_from_utf8()
    file.close()
    return not header.begins_with("version https://git-lfs.github.com/spec/v1")

func _find_forest_scene(root_path: String) -> String:
    var dir := DirAccess.open(root_path)
    if dir == null:
        return ""
    var found := ""
    dir.list_dir_begin()
    var entry := dir.get_next()
    while not entry.is_empty():
        if not entry.begins_with("."):
            var full_path := root_path.path_join(entry)
            if dir.current_is_dir():
                found = _find_forest_scene(full_path)
            elif entry.to_lower() in ["forestpack.fbx", "forestpack.glb", "forestpack.gltf"]:
                if _is_real_scene_file(full_path):
                    found = full_path
            if not found.is_empty():
                break
        entry = dir.get_next()
    dir.list_dir_end()
    return found
