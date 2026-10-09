extends CanvasLayer
class_name CinematicIntro

const SHOTS := [
    {"time": 0.0, "title": "WHEN THE MOON TURNED RED", "caption": "The night the Ashen Village burned, the empire erased every name but one."},
    {"time": 4.0, "title": "ONE SURVIVOR", "caption": "A young shinobi woke beneath the ashes, with a broken oath and a blade that remembered."},
    {"time": 8.0, "title": "THE SHADOW CITADEL", "caption": "Beyond the cedar forest, the warlord Kurogane gathers the souls of the fallen."},
    {"time": 12.0, "title": "YOUR OATH BEGINS", "caption": "Cross the river. Follow the lanterns. Find the truth before dawn."}
]

var _finished := false
var _elapsed := 0.0
var _player: CharacterBody3D
var _camera_rig: Node3D
var _hud: CanvasLayer
var _mobile: CanvasLayer
var _shade: ColorRect
var _title: Label
var _caption: Label
var _skip: Button
var _top_bar: ColorRect
var _bottom_bar: ColorRect
var _initial_yaw := 0.0
var _paused_enemies: Array[Node] = []
var _director: Node

func _ready() -> void:
    layer = 100
    _player = get_tree().get_first_node_in_group("player") as CharacterBody3D
    if _player == null:
        _finish()
        return
    _camera_rig = _player.get_node_or_null("CameraRig")
    _hud = get_tree().get_first_node_in_group("game_hud") as CanvasLayer
    _mobile = get_tree().get_first_node_in_group("mobile_controls") as CanvasLayer
    _player.set_physics_process(false)
    _director = get_tree().current_scene.get_node_or_null("GameDirector")
    if _director:
        _director.set_process(false)
    for enemy in get_tree().get_nodes_in_group("enemies"):
        if enemy is Node:
            _paused_enemies.append(enemy)
            enemy.set_physics_process(false)
    if _hud:
        _hud.visible = false
    if _mobile:
        _mobile.visible = false
    if _camera_rig:
        _initial_yaw = float(_camera_rig.get("yaw"))
        _camera_rig.set("distance", 9.5)
        _camera_rig.set("height", 4.0)
        _camera_rig.set("pitch", -0.10)
    _build_overlay()
    _play_intro()

func _build_overlay() -> void:
    var screen := Control.new()
    screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(screen)

    _shade = ColorRect.new()
    _shade.color = Color(0.005, 0.006, 0.012, 1.0)
    _shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    screen.add_child(_shade)

    _top_bar = ColorRect.new()
    _top_bar.color = Color(0.0, 0.0, 0.0, 0.96)
    _top_bar.anchor_right = 1.0
    _top_bar.offset_bottom = 48.0
    screen.add_child(_top_bar)

    _bottom_bar = ColorRect.new()
    _bottom_bar.color = Color(0.0, 0.0, 0.0, 0.96)
    _bottom_bar.anchor_top = 1.0
    _bottom_bar.anchor_right = 1.0
    _bottom_bar.offset_top = -48.0
    screen.add_child(_bottom_bar)

    var brand := Label.new()
    brand.text = "AHMED BECETTI  PRESENTS"
    brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    brand.anchor_left = 0.2
    brand.anchor_right = 0.8
    brand.anchor_top = 0.24
    brand.anchor_bottom = 0.30
    brand.add_theme_font_size_override("font_size", 15)
    brand.add_theme_color_override("font_color", Color(0.76, 0.61, 0.43, 1))
    screen.add_child(brand)

    _title = Label.new()
    _title.text = "N I N J A"
    _title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _title.anchor_left = 0.08
    _title.anchor_right = 0.92
    _title.anchor_top = 0.34
    _title.anchor_bottom = 0.47
    _title.add_theme_font_size_override("font_size", 58)
    _title.add_theme_color_override("font_color", Color(0.94, 0.88, 0.78, 1))
    _title.add_theme_color_override("font_shadow_color", Color(0.55, 0.02, 0.015, 1))
    _title.add_theme_constant_override("shadow_offset_x", 2)
    _title.add_theme_constant_override("shadow_offset_y", 3)
    screen.add_child(_title)

    _caption = Label.new()
    _caption.text = "E C H O E S   O F   T H E   A S H E N   M O O N"
    _caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _caption.anchor_left = 0.10
    _caption.anchor_right = 0.90
    _caption.anchor_top = 0.51
    _caption.anchor_bottom = 0.68
    _caption.add_theme_font_size_override("font_size", 20)
    _caption.add_theme_color_override("font_color", Color(0.85, 0.78, 0.68, 1))
    screen.add_child(_caption)

    _skip = Button.new()
    _skip.text = "SKIP  »"
    _skip.anchor_left = 1.0
    _skip.anchor_right = 1.0
    _skip.anchor_top = 1.0
    _skip.anchor_bottom = 1.0
    _skip.offset_left = -132.0
    _skip.offset_right = -24.0
    _skip.offset_top = -92.0
    _skip.offset_bottom = -48.0
    _skip.pressed.connect(_finish)
    screen.add_child(_skip)

func _play_intro() -> void:
    var fade := create_tween()
    fade.tween_property(_shade, "color:a", 0.18, 2.0)
    await fade.finished
    if _finished:
        return

    for shot in SHOTS:
        var target_time: float = float(shot.time)
        while _elapsed < target_time and not _finished:
            await get_tree().create_timer(0.1).timeout
        if _finished:
            return
        _title.text = str(shot.title)
        _caption.text = str(shot.caption)
        _title.modulate.a = 0.0
        _caption.modulate.a = 0.0
        var text_fade := create_tween().set_parallel(true)
        text_fade.tween_property(_title, "modulate:a", 1.0, 0.75)
        text_fade.tween_property(_caption, "modulate:a", 1.0, 0.75)
        await get_tree().create_timer(3.2).timeout
        if _finished:
            return
        var text_out := create_tween().set_parallel(true)
        text_out.tween_property(_title, "modulate:a", 0.0, 0.45)
        text_out.tween_property(_caption, "modulate:a", 0.0, 0.45)
        await text_out.finished

    _title.text = "BECOME THE LAST SHADOW"
    _caption.text = "The forest is listening. Your story starts now."
    var finale := create_tween().set_parallel(true)
    finale.tween_property(_title, "modulate:a", 1.0, 0.6)
    finale.tween_property(_caption, "modulate:a", 1.0, 0.6)
    await get_tree().create_timer(2.0).timeout
    _finish()

func _process(delta: float) -> void:
    if _finished:
        return
    _elapsed += delta
    if _camera_rig:
        _camera_rig.set("yaw", _initial_yaw + _elapsed * 0.045)
    if _player and is_instance_valid(_player):
        _player.rotation.y = sin(_elapsed * 0.18) * 0.12

func _finish() -> void:
    if _finished:
        return
    _finished = true
    if _player and is_instance_valid(_player):
        _player.set_physics_process(true)
        _player.rotation.y = 0.0
    if _director and is_instance_valid(_director):
        _director.set_process(true)
    for enemy in _paused_enemies:
        if is_instance_valid(enemy):
            enemy.set_physics_process(true)
    if _camera_rig:
        _camera_rig.set("distance", 6.2)
        _camera_rig.set("height", 2.7)
        _camera_rig.set("pitch", -0.18)
    if _hud:
        _hud.visible = true
    if _mobile:
        _mobile.visible = true
    queue_free()
