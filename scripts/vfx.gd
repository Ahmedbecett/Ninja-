extends Node
class_name VFX

static func slash(parent: Node3D, origin: Vector3, color := Color(0.7,0.85,1.0,1)) -> void:
    var arc := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(2.2,0.035,0.12)
    arc.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = 3.5
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    arc.material_override = mat
    arc.global_position = origin + Vector3(0,1.15,0)
    arc.rotation.y = randf_range(-0.7,0.7)
    parent.add_child(arc)
    var tw := parent.create_tween()
    tw.parallel().tween_property(arc,"scale",Vector3(1.8,1,1),0.12)
    tw.tween_callback(arc.queue_free)

static func impact(parent: Node3D, origin: Vector3) -> void:
    var ring := MeshInstance3D.new()
    var mesh := TorusMesh.new()
    mesh.inner_radius = 0.12
    mesh.outer_radius = 0.22
    mesh.rings = 8
    mesh.ring_segments = 16
    ring.mesh = mesh
    ring.global_position = origin + Vector3(0,0.8,0)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(1,0.28,0.08,1)
    mat.emission_enabled = true
    mat.emission = Color(1,0.1,0.02,1)
    mat.emission_energy_multiplier = 2.5
    ring.material_override = mat
    parent.add_child(ring)
    var tw := parent.create_tween()
    tw.parallel().tween_property(ring,"scale",Vector3(4,4,4),0.18)
        tw.tween_callback(ring.queue_free)
