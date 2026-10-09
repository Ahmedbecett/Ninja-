extends Node

var frames := 0

func _process(_delta: float) -> void:
    frames += 1
    if frames == 120:
        get_tree().root.get_viewport().get_texture().get_image().save_png("/tmp/shot_intro.png")
        print("SHOT INTRO")
    if frames == 900:
        get_tree().root.get_viewport().get_texture().get_image().save_png("/tmp/shot_world.png")
        print("SHOT WORLD")
    if frames == 920:
        get_tree().quit()
