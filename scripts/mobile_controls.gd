extends CanvasLayer
class_name MobileControls

var move_pad: Control
var attack_button: Button
var dodge_button: Button
var heavy_button: Button

func _ready() -> void:
    _build()

func _build() -> void:
    move_pad = Control.new()
    move_pad.position = Vector2(28, get_viewport().size.y - 230)
    move_pad.size = Vector2(190,190)
    add_child(move_pad)

    var pad := ColorRect.new()
    pad.color = Color(0.05,0.06,0.08,0.72)
    pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    move_pad.add_child(pad)

    attack_button = _button("ATTACK", Vector2(get_viewport().size.x - 190, get_viewport().size.y - 205), 150)
    dodge_button = _button("DASH", Vector2(get_viewport().size.x - 320, get_viewport().size.y - 115), 110)
    heavy_button = _button("HEAVY", Vector2(get_viewport().size.x - 335, get_viewport().size.y - 250), 110)

func _button(label_text: String, pos: Vector2, size_px: int) -> Button:
    var b := Button.new()
    b.text = label_text
    b.position = pos
    b.size = Vector2(size_px,size_px)
    b.add_theme_font_size_override("font_size", 18)
    add_child(b)
    return b

func _process(_delta: float) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if not is_instance_valid(player):
        return
    if attack_button.button_pressed and player.has_method("attack"):
        player.attack()
    if heavy_button.button_pressed and player.has_method("heavy_attack"):
        player.heavy_attack()
    if dodge_button.button_pressed and player.has_method("dash"):
        player.dash(Vector3.FORWARD)
