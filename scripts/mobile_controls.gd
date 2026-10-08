extends CanvasLayer
class_name MobileControls

var move_pad: Control
var knob: ColorRect
var attack_button: Button
var dodge_button: Button
var heavy_button: Button
var radius := 78.0
var center := Vector2.ZERO
var active_touch := -1

func _ready() -> void:
    _build()
    get_viewport().size_changed.connect(_layout)

func _build() -> void:
    move_pad = Control.new()
    move_pad.mouse_filter = Control.MOUSE_FILTER_STOP
    move_pad.gui_input.connect(_on_pad_input)
    add_child(move_pad)
    var pad := ColorRect.new()
    pad.color = Color(0.035,0.045,0.055,0.7)
    pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
    move_pad.add_child(pad)
    knob = ColorRect.new()
    knob.color = Color(0.22,0.27,0.31,0.85)
    knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
    move_pad.add_child(knob)

    attack_button = _button("ATTACK",150)
    dodge_button = _button("DASH",110)
    heavy_button = _button("HEAVY",110)
    attack_button.pressed.connect(_attack)
    dodge_button.pressed.connect(_dash)
    heavy_button.pressed.connect(_heavy)
    _layout()

func _button(label_text:String,size_px:int)->Button:
    var b:=Button.new()
    b.text=label_text
    b.size=Vector2(size_px,size_px)
    b.add_theme_font_size_override("font_size",18)
    add_child(b)
    return b

func _layout()->void:
    var s:=get_viewport().size
    move_pad.position=Vector2(28,s.y-210)
    move_pad.size=Vector2(170,170)
    center=Vector2(85,85)
    knob.position=center-Vector2(27,27)
    knob.size=Vector2(54,54)
    attack_button.position=Vector2(s.x-175,s.y-185)
    dodge_button.position=Vector2(s.x-300,s.y-105)
    heavy_button.position=Vector2(s.x-315,s.y-235)

func _on_pad_input(event:InputEvent)->void:
    if event is InputEventScreenTouch:
        active_touch=event.index if event.pressed else -1
        if not event.pressed:
            _set_move(Vector2.ZERO)
        else:
            _set_move(event.position-move_pad.global_position)
    elif event is InputEventScreenDrag and event.index==active_touch:
        _set_move(event.position-move_pad.global_position)

func _set_move(pos:Vector2)->void:
    var delta:=pos-center
    delta=delta.limit_length(radius)
    knob.position=center+delta-Vector2(27,27)
    var player:=get_tree().get_first_node_in_group("player")
    if is_instance_valid(player) and player.has_method("set_mobile_move"):
        player.set_mobile_move(Vector2(delta.x/radius,delta.y/radius))

func _release_move()->void:
    knob.position=center-Vector2(27,27)
    var player:=get_tree().get_first_node_in_group("player")
    if is_instance_valid(player) and player.has_method("set_mobile_move"):
        player.set_mobile_move(Vector2.ZERO)

func _attack()->void:
    var p:=get_tree().get_first_node_in_group("player")
    if is_instance_valid(p): p.attack()

func _dash()->void:
    var p:=get_tree().get_first_node_in_group("player")
    if is_instance_valid(p): p.dash(Vector3.ZERO)

func _heavy()->void:
    var p:=get_tree().get_first_node_in_group("player")
    if is_instance_valid(p): p.heavy_attack()
