extends Area3D
class_name ShadowArrow

@export var speed:=13.0
@export var damage:=18.0
@export var lifetime:=3.0
var direction:=Vector3.FORWARD
var owner_node:Node3D
var age:=0.0

func _ready()->void:
    monitoring=true
    body_entered.connect(_on_body_entered)
    var shape:=CollisionShape3D.new()
    var sphere:=SphereShape3D.new()
    sphere.radius=0.14
    shape.shape=sphere
    add_child(shape)
    var mesh:=MeshInstance3D.new()
    var box:=BoxMesh.new()
    box.size=Vector3(0.08,0.08,0.7)
    mesh.mesh=box
    var mat:=StandardMaterial3D.new()
    mat.albedo_color=Color(0.12,0.02,0.02,1)
    mat.metallic=0.5
    mat.emission_enabled=true
    mat.emission=Color(0.35,0.01,0.01,1)
    mat.emission_energy_multiplier=1.5
    mesh.material_override=mat
    add_child(mesh)

func launch(start:Vector3,dir:Vector3,source:Node3D)->void:
    global_position=start
    direction=dir.normalized()
    owner_node=source
    look_at(global_position+direction,Vector3.UP)

func _physics_process(delta:float)->void:
    age+=delta
    if age>=lifetime:
        queue_free()
        return
    global_position+=direction*speed*delta

func _on_body_entered(body:Node3D)->void:
    if body==owner_node:
        return
    if body.has_method("take_damage"):
        body.take_damage(damage)
        VFX.impact(get_parent(),global_position)
        queue_free()
    elif body is StaticBody3D:
        queue_free()
