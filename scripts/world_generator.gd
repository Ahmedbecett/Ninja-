extends Node3D
class_name WorldGenerator

@export var radius := 38.0

func _mat(color:Color,rough:=0.8,metal:=0.0)->StandardMaterial3D:
    var m:=StandardMaterial3D.new()
    m.albedo_color=color
    m.roughness=rough
    m.metallic=metal
    return m

func _ready()->void:
    _generate()

func _generate()->void:
    var rng:=RandomNumberGenerator.new()
    rng.seed=91472
    var rock_mat:=_mat(Color(0.055,0.065,0.075,1),0.95,0.05)
    var wood_mat:=_mat(Color(0.09,0.045,0.025,1),0.88,0.0)
    var roof_mat:=_mat(Color(0.035,0.02,0.025,1),0.9,0.0)
    for i in range(65):
        var rock:=MeshInstance3D.new()
        var mesh:=SphereMesh.new()
        var s:=rng.randf_range(0.25,1.45)
        mesh.radius=s
        mesh.height=s*1.6
        rock.mesh=mesh
        rock.material_override=rock_mat
        rock.position=Vector3(rng.randf_range(-radius,radius),s*0.45,rng.randf_range(-radius,radius))
        rock.scale=Vector3(1,rng.randf_range(0.5,1.35),1)
        add_child(rock)
    for i in range(24):
        _make_tree(Vector3(rng.randf_range(-radius,radius),0,rng.randf_range(-radius,radius)),rng)
    for i in range(12):
        _make_trap(Vector3(rng.randf_range(-radius+3.0,radius-3.0),0.03,rng.randf_range(-radius+3.0,radius-3.0)),rng)

func _make_tree(pos:Vector3,rng:RandomNumberGenerator)->void:
    var tree:=Node3D.new()
    tree.position=pos
    var trunk:=MeshInstance3D.new()
    var tm:=CylinderMesh.new()
    tm.top_radius=0.16; tm.bottom_radius=0.3; tm.height=3.4
    trunk.mesh=tm
    trunk.material_override=_mat(Color(0.08,0.04,0.02,1),0.9)
    trunk.position.y=1.7
    tree.add_child(trunk)
    var crown:=MeshInstance3D.new()
    var cm:=SphereMesh.new()
    cm.radius=1.35; cm.height=2.5
    crown.mesh=cm
    crown.material_override=_mat(Color(0.015,0.075,0.045,1),0.96)
    crown.position.y=3.45
    tree.add_child(crown)
    add_child(tree)

    var body:=StaticBody3D.new()
    body.position=pos
    var shape:=CollisionShape3D.new()
    var cs:=CylinderShape3D.new()
    cs.radius=0.28; cs.height=3.2
    shape.shape=cs
    shape.position.y=1.6
    body.add_child(shape)
    add_child(body)


func _make_trap(pos:Vector3,rng:RandomNumberGenerator)->void:
    var trap_script = preload("res://scripts/spike_trap.gd")
    if pos.length() < 7.0:
        pos += Vector3(8.0,0,8.0)
    var trap:=Area3D.new()
    trap.set_script(trap_script)
    trap.position=pos
    add_child(trap)
