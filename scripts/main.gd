extends Node3D

var autosave_timer := 20.0

func _ready() -> void:
    Engine.max_fps = 60
    SaveSystem.load_game()

func _process(delta: float) -> void:
    autosave_timer -= delta
    if autosave_timer <= 0.0:
        autosave_timer = 20.0
        SaveSystem.save_game()
