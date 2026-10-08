extends Area3D
class_name ShurikenProjectile

@export var speed := 18.0
@export var damage := 45.0
@export var lifetime := 2.2

var direction := Vector3.FORWARD
var owner_node: Node3D
var age := 0.0

func _ready() -> void:
    monitoring = true
    body_entered.connect(_on_body_entered)
    var shape := CollisionShape3D.new()
    var sphere := SphereShape3D.new()
    sphere.radius = 0.18
    shape.shape = sphere
    add_child(shape)
    var mesh := MeshInstance3D.new()
    var blade := BoxMesh.new()
    blade.size = Vector3(0.08, 0.035, 0.55)
    mesh.mesh = blade
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.48, 0.52, 0.58, 1)
    material.metallic = 0.95
    material.roughness = 0.18
    material.emission_enabled = true
    material.emission = Color(0.08, 0.12, 0.18, 1)
    material.emission_energy_multiplier = 0.7
    mesh.material_override = material
    add_child(mesh)

func launch(start: Vector3, dir: Vector3, source: Node3D) -> void:
    global_position = start
    direction = dir.normalized()
    owner_node = source
    if direction.length() > 0.01:
        look_at(global_position + direction, Vector3.UP)

func _physics_process(delta: float) -> void:
    age += delta
    if age >= lifetime:
        queue_free()
        return
    global_position += direction * speed * delta
    rotate_z(18.0 * delta)

func _on_body_entered(body: Node3D) -> void:
    if body == owner_node:
        return
    if body.has_method("take_damage"):
        body.take_damage(damage, global_position)
        VFX.impact(get_parent(), global_position)
        queue_free()
    elif body is StaticBody3D:
        queue_free()
