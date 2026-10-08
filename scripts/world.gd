extends Node3D

func _ready() -> void:
    _create_arena()

func _create_arena() -> void:
    for i in range(12):
        var pillar := MeshInstance3D.new()
        var mesh := BoxMesh.new()
        mesh.size = Vector3(1.4, randf_range(2.0,5.0), 1.4)
        pillar.mesh = mesh
        pillar.position = Vector3(randf_range(-18,18), mesh.size.y/2.0, randf_range(-18,18))
        add_child(pillar)

    for i in range(8):
        var rock := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        mesh.radius = randf_range(0.4,1.1)
        mesh.height = mesh.radius*2.0
        rock.mesh = mesh
        rock.position = Vector3(randf_range(-25,25),mesh.radius,randf_range(-25,25))
        rock.scale.y = randf_range(0.5,1.4)
        add_child(rock)
