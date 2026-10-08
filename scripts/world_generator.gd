extends Node3D
class_name WorldGenerator

@export var radius := 32.0

func _ready() -> void:
    _generate()

func _generate() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 91472
    for i in range(55):
        var rock := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        var s := rng.randf_range(0.3, 1.5)
        mesh.radius = s
        mesh.height = s * 1.7
        rock.mesh = mesh
        rock.position = Vector3(rng.randf_range(-radius,radius), s * 0.45, rng.randf_range(-radius,radius))
        rock.scale = Vector3(1.0, rng.randf_range(0.5,1.4), 1.0)
        add_child(rock)
    for i in range(18):
        var tree := Node3D.new()
        tree.position = Vector3(rng.randf_range(-radius,radius),0,rng.randf_range(-radius,radius))
        var trunk := MeshInstance3D.new()
        var trunk_mesh := CylinderMesh.new()
        trunk_mesh.top_radius = 0.18
        trunk_mesh.bottom_radius = 0.28
        trunk_mesh.height = 2.8
        trunk.mesh = trunk_mesh
        trunk.position.y = 1.4
        tree.add_child(trunk)
        var crown := MeshInstance3D.new()
        var crown_mesh := SphereMesh.new()
        crown_mesh.radius = 1.2
        crown_mesh.height = 2.2
        crown.mesh = crown_mesh
        crown.position.y = 3.0
        tree.add_child(crown)
        add_child(tree)
