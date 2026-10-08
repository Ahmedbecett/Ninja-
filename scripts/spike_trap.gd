extends Area3D
class_name SpikeTrap

@export var damage := 24.0
@export var cooldown := 1.1
var hit_cooldown := 0.0

func _ready() -> void:
    monitoring = true
    body_entered.connect(_on_body_entered)
    var shape := CollisionShape3D.new()
    var cylinder := CylinderShape3D.new()
    cylinder.radius = 0.65
    cylinder.height = 0.35
    shape.shape = cylinder
    add_child(shape)

    var mesh := MeshInstance3D.new()
    var quad := QuadMesh.new()
    quad.size = Vector2(1.15, 1.15)
    mesh.mesh = quad
    mesh.rotation_degrees.x = -90.0
    var material := StandardMaterial3D.new()
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.albedo_texture = load("res://assets/world/spike_trap_icon.png")
    material.albedo_color = Color(1,1,1,0.92)
    mesh.material_override = material
    add_child(mesh)

func _physics_process(delta: float) -> void:
    hit_cooldown = maxf(hit_cooldown - delta, 0.0)

func _on_body_entered(body: Node3D) -> void:
    if hit_cooldown > 0.0:
        return
    if body.has_method("take_damage"):
        hit_cooldown = cooldown
        body.take_damage(damage)
        VFX.impact(get_parent(), global_position)
