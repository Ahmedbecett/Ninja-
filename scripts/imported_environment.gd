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
    if not ResourceLoader.exists(environment_scene_path):
        push_warning("NINJA: Imported environment asset not available at %s. The Android workflow must extract ForestPack.7z before import." % environment_scene_path)
        return
    var packed := load(environment_scene_path) as PackedScene
    if packed == null:
        push_error("NINJA: The imported environment file could not be loaded as a scene: %s" % environment_scene_path)
        return
    loaded_environment = packed.instantiate() as Node3D
    if loaded_environment == null:
        push_error("NINJA: The environment scene root is not Node3D.")
        return
    loaded_environment.name = "ImportedForestPack"
    loaded_environment.position = environment_position
    loaded_environment.rotation_degrees = environment_rotation_degrees
    loaded_environment.scale = Vector3.ONE * environment_scale
    add_child(loaded_environment)
    print("NINJA: Loaded real imported environment scene: ", environment_scene_path)
