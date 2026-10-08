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

func _make_dojo(pos:Vector3)->void:
    var wood:=_mat(Color(0.13,0.06,0.028,1),0.82)
    var dark:=_mat(Color(0.025,0.018,0.014,1),0.88)
    for x in [-4.0,4.0]:
        _make_box(self,pos+Vector3(x,2.0,0),Vector3(0.35,4.0,7.0),wood)
    _make_box(self,pos+Vector3(0,3.8,0),Vector3(8.6,0.45,7.4),dark)
    _make_box(self,pos+Vector3(0,1.5,-3.5),Vector3(7.8,3.0,0.3),wood)
    _make_box(self,pos+Vector3(0,1.5,3.5),Vector3(7.8,3.0,0.3),wood)
    for x in [-2.8,0,2.8]:
        _make_lantern(pos+Vector3(x,0,-4.2))
    var body:=StaticBody3D.new()
    body.position=pos
    var shape:=CollisionShape3D.new()
    var box:=BoxShape3D.new()
    box.size=Vector3(8.2,3.8,7.0)
    shape.shape=box
    shape.position.y=1.9
    body.add_child(shape)
    add_child(body)

func _make_castle_gate(pos:Vector3)->void:
    var stone:=_mat(Color(0.09,0.095,0.105,1),0.94)
    var wood:=_mat(Color(0.18,0.035,0.02,1),0.75)
    _make_box(self,pos+Vector3(-5,3,0),Vector3(2.2,6,3.2),stone)
    _make_box(self,pos+Vector3(5,3,0),Vector3(2.2,6,3.2),stone)
    _make_box(self,pos+Vector3(0,6,0),Vector3(12,2.2,3.2),stone)
    _make_box(self,pos+Vector3(0,2.8,-1.7),Vector3(6.0,4.6,0.35),wood)
    _make_torii(pos+Vector3(0,0,-2.4))

func _make_river()->void:
    var water:=_mat(Color(0.015,0.07,0.11,1),0.12,0.25)
    water.emission_enabled=true
    water.emission=Color(0.0,0.025,0.05,1)
    water.emission_energy_multiplier=0.35
    _make_box(self,Vector3(0,-0.03,3.0),Vector3(80,0.08,5.2),water)
    for x in range(-36,37,4):
        _make_box(self,Vector3(x,0.04,0.5),Vector3(2.5,0.03,0.25),_mat(Color(0.15,0.17,0.18,1),0.92))

func _make_bamboo_grove()->void:
    var green:=_mat(Color(0.035,0.16,0.07,1),0.86)
    for x in range(-28,-10,3):
        for z in range(10,28,3):
            var h:=4.0+abs(sin(float(x*z)))*3.0
            _make_box(self,Vector3(x, h*0.5,z),Vector3(0.18,h,0.18),green)
