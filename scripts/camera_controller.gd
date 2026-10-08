extends Node3D
class_name CameraController

@export var distance := 6.2
@export var height := 2.7
@export var sensitivity := 0.008
@export var follow_speed := 10.0
var yaw := 0.0
var pitch := -0.18
var target: Node3D
var dragging := false
var last_touch := Vector2.ZERO

func _ready() -> void:
    target = get_parent()
    yaw = target.rotation.y

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        dragging = event.pressed
        last_touch = event.position
    elif event is InputEventScreenDrag and dragging:
        var delta: Vector2 = event.relative
        yaw -= delta.x * sensitivity
        pitch = clampf(pitch - delta.y * sensitivity, -0.65, 0.2)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        yaw -= event.relative.x * sensitivity
        pitch = clampf(pitch - event.relative.y * sensitivity, -0.65, 0.2)

func _physics_process(delta: float) -> void:
    if not is_instance_valid(target):
        return
    var rot := Basis.from_euler(Vector3(pitch,yaw,0))
    var desired := target.global_position + Vector3(0,height,0) + rot * Vector3(0,0,distance)
    global_position = global_position.lerp(desired, 1.0 - exp(-follow_speed * delta))
    look_at(target.global_position + Vector3(0,1.15,0), Vector3.UP)

func get_move_basis() -> Basis:
    return Basis(Vector3.UP, yaw)
