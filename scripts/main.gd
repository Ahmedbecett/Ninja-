extends Node3D

var elapsed := 0.0

func _ready() -> void:
    Engine.max_fps = 60
    _build_environment()

func _process(delta: float) -> void:
    elapsed += delta

func _build_environment() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#080a10")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#5b6075")
    env.ambient_light_energy = 0.45
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48,-25,0)
    sun.light_energy = 1.15
    sun.shadow_enabled = true
    add_child(sun)

    var moon := OmniLight3D.new()
    moon.position = Vector3(0,8,0)
    moon.light_color = Color("#6f7fb5")
    moon.light_energy = 1.8
    moon.omni_range = 35.0
    add_child(moon)
