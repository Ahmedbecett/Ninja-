extends Node3D
class_name CampaignWorld

func _ready() -> void:
    _add_zone_marker(Vector3(-19,0,18),"BAMBOO SHADOWS")
    _add_zone_marker(Vector3(0,0,3),"RIVER OF BLADES")
    _add_zone_marker(Vector3(23,0,21),"DOJO OF ASH")
    _add_zone_marker(Vector3(-22,0,21),"CASTLE APPROACH")
    _add_zone_marker(Vector3(0,0,-20),"SHADOW CITADEL")

func _add_zone_marker(pos:Vector3,title:String) -> void:
    var root:=Node3D.new()
    root.position=pos
    add_child(root)
    var ring:=MeshInstance3D.new()
    var mesh:=TorusMesh.new()
    mesh.inner_radius=2.2
    mesh.outer_radius=2.35
    ring.mesh=mesh
    ring.rotation_degrees.x=90
    var mat:=StandardMaterial3D.new()
    mat.albedo_color=Color(0.65,0.04,0.03,1)
    mat.emission_enabled=true
    mat.emission=Color(0.45,0.01,0.01,1)
    mat.emission_energy_multiplier=2.0
    ring.material_override=mat
    ring.position.y=0.08
    root.add_child(ring)
    var label:=Label3D.new()
    label.text=title
    label.position=Vector3(0,3.2,0)
    label.font_size=40
    label.outline_size=8
    label.modulate=Color(1,0.72,0.55,1)
    root.add_child(label)
