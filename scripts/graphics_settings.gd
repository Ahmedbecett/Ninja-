extends Node
class_name GraphicsSettings

enum Level { LOW, MEDIUM, HIGH, ULTRA, 4K }

const SAVE_PATH := "user://graphics.cfg"
var level: int = Level.HIGH
var labels := ["Low","Medium","High","Ultra","4K"]

func _ready() -> void:
    load_settings()
    apply()

func set_level(value: int) -> void:
    level = clamp(value, Level.LOW, Level.4K)
    apply()
    save_settings()

func apply() -> void:
    var viewport := get_viewport()
    if viewport:
        match level:
            Level.LOW:
                viewport.scaling_3d_scale = 0.67
                Engine.max_fps = 45
            Level.MEDIUM:
                viewport.scaling_3d_scale = 0.80
                Engine.max_fps = 60
            Level.HIGH:
                viewport.scaling_3d_scale = 0.92
                Engine.max_fps = 60
            Level.ULTRA:
                viewport.scaling_3d_scale = 1.0
                Engine.max_fps = 60
            Level.4K:
                viewport.scaling_3d_scale = 1.0
                Engine.max_fps = 60
        RenderingServer.set_default_clear_color(Color(0.006,0.008,0.012))

func save_settings() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("graphics","level",level)
    cfg.save(SAVE_PATH)

func load_settings() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SAVE_PATH) == OK:
        level = int(cfg.get_value("graphics","level",Level.HIGH))

func get_label() -> String:
    return labels[level]
