extends Node3D
class_name CharacterVisual

@export var enemy := false
var parts: Array[Node3D] = []
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var sword: Node3D
var base_y := 0.0
var phase := 0.0
var imported_model: Node3D
var _char_foot_offset := 0.0

func _ready() -> void:
    if _load_imported_character():
        return
    _build()

func _load_imported_character() -> bool:
    # The Android build converts the real Blender source files to GLB first.
    # Keep the procedural rig only as a fallback if an export/import fails.
    var model_path := "res://assets/imported/characters/Anime2.glb" if enemy else "res://assets/imported/characters/mikasanew2.glb"
    if not ResourceLoader.exists(model_path):
        push_warning("NINJA: Imported character unavailable; using fallback rig: %s" % model_path)
        return false
    var packed := load(model_path) as PackedScene
    if packed == null:
        push_warning("NINJA: Character GLB could not be loaded; using fallback rig: %s" % model_path)
        return false
    var model := packed.instantiate() as Node3D
    if model == null:
        push_warning("NINJA: Character GLB root is not Node3D; using fallback rig.")
        return false
    model.name = "ImportedCharacterModel"
    add_child(model)
    _normalize_character(model)
    var animations := _find_animation_player(model)
    if animations != null and animations.has_animation("RESET"):
        animations.play("RESET")
    elif animations != null:
        var names := animations.get_animation_list()
        if not names.is_empty():
            animations.play(names[0])
    imported_model = model
    print("NINJA: Loaded imported character model: ", model_path)
    return true

func _normalize_character(model: Node3D) -> void:
    # Source rigs ship at arbitrary scales/offsets; fit them to a 1.8 m
    # humanoid footprint so gameplay collision and the camera stay correct.
    var bounds := AABB()
    var found := false
    var stack: Array[Node] = [model]
    while not stack.is_empty():
        var current: Node = stack.pop_back()
        if current is MeshInstance3D and (current as MeshInstance3D).mesh != null:
            var local := (current as MeshInstance3D).get_aabb()
            var world := local * (current as Node3D).global_transform * model.global_transform.affine_inverse()
            if not found:
                bounds = world
                found = true
            else:
                bounds = bounds.merge(world)
        for child in current.get_children():
            stack.append(child)
    if not found or bounds.size.y < 0.01:
        model.position = Vector3.ZERO
        model.scale = Vector3.ONE
        return
    var target_height := 1.8
    var factor := target_height / bounds.size.y
    model.scale = Vector3.ONE * factor
    _char_foot_offset = bounds.position.y * factor
    model.position = Vector3(
        -bounds.get_center().x * factor,
        -_char_foot_offset,
        -bounds.get_center().z * factor
    )

func _find_animation_player(root: Node) -> AnimationPlayer:
    if root is AnimationPlayer:
        return root as AnimationPlayer
    for child in root.get_children():
        var found := _find_animation_player(child)
        if found != null:
            return found
    return null

func _mat(color: Color, metallic := 0.0, roughness := 0.65) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metallic
    m.roughness = roughness
    return m

func _mesh(parent: Node3D, mesh: Mesh, material: Material, pos: Vector3, scale := Vector3.ONE) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.mesh = mesh
    n.material_override = material
    n.position = pos
    n.scale = scale
    parent.add_child(n)
    return n

func _build() -> void:
    var cloth := _mat(Color(0.018,0.022,0.028,1), 0.08, 0.82) if not enemy else _mat(Color(0.075,0.025,0.022,1), 0.05, 0.86)
    var armor := _mat(Color(0.07,0.085,0.095,1), 0.65, 0.38) if not enemy else _mat(Color(0.12,0.035,0.03,1), 0.55, 0.42)
    var skin := _mat(Color(0.36,0.24,0.18,1), 0.0, 0.78)
    var metal := _mat(Color(0.32,0.36,0.4,1), 0.92, 0.2)
    var accent := _mat(Color(0.45,0.035,0.025,1), 0.2, 0.5)

    var torso := Node3D.new()
    torso.name = "Torso"
    add_child(torso)
    var torso_mesh := BoxMesh.new()
    torso_mesh.size = Vector3(0.72,0.92,0.38)
    _mesh(torso, torso_mesh, armor, Vector3(0,1.38,0))
    parts.append(torso)

    var head := Node3D.new()
    head.name = "Head"
    add_child(head)
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.28
    head_mesh.height = 0.56
    _mesh(head, head_mesh, skin, Vector3(0,2.05,0))
    var mask_mesh := BoxMesh.new()
    mask_mesh.size = Vector3(0.5,0.18,0.34)
    _mesh(head, mask_mesh, cloth, Vector3(0,2.0,-0.17))
    parts.append(head)

    left_arm = Node3D.new()
    right_arm = Node3D.new()
    left_arm.position = Vector3(-0.47,1.58,0)
    right_arm.position = Vector3(0.47,1.58,0)
    add_child(left_arm); add_child(right_arm)
    var arm_mesh := CylinderMesh.new()
    arm_mesh.top_radius = 0.105
    arm_mesh.bottom_radius = 0.13
    arm_mesh.height = 0.72
    _mesh(left_arm, arm_mesh, cloth, Vector3(0,-0.34,0), Vector3.ONE)
    _mesh(right_arm, arm_mesh, cloth, Vector3(0,-0.34,0), Vector3.ONE)

    left_leg = Node3D.new()
    right_leg = Node3D.new()
    left_leg.position = Vector3(-0.2,0.96,0)
    right_leg.position = Vector3(0.2,0.96,0)
    add_child(left_leg); add_child(right_leg)
    var leg_mesh := CylinderMesh.new()
    leg_mesh.top_radius = 0.14
    leg_mesh.bottom_radius = 0.11
    leg_mesh.height = 0.85
    _mesh(left_leg, leg_mesh, cloth, Vector3(0,-0.42,0))
    _mesh(right_leg, leg_mesh, cloth, Vector3(0,-0.42,0))

    sword = Node3D.new()
    sword.name = "Katana"
    sword.position = Vector3(0.62,1.22,0.08)
    sword.rotation_degrees = Vector3(0,0,70)
    add_child(sword)
    var blade := BoxMesh.new()
    blade.size = Vector3(0.08,1.15,0.025)
    _mesh(sword, blade, metal, Vector3(0,-0.55,0))
    var guard := BoxMesh.new()
    guard.size = Vector3(0.34,0.05,0.05)
    _mesh(sword, guard, accent, Vector3(0,-0.02,0))
    var grip := CylinderMesh.new()
    grip.top_radius = 0.035
    grip.bottom_radius = 0.035
    grip.height = 0.32
    _mesh(sword, grip, cloth, Vector3(0,0.16,0))

    # High-detail silhouette: layered shoulder armor, scarf, hair and boots.
    var shoulder_mesh := SphereMesh.new()
    shoulder_mesh.radius = 0.22
    shoulder_mesh.height = 0.30
    _mesh(self, shoulder_mesh, armor, Vector3(-0.43,1.66,0), Vector3(1.15,0.65,0.95))
    _mesh(self, shoulder_mesh, armor, Vector3(0.43,1.66,0), Vector3(1.15,0.65,0.95))

    var scarf_mesh := BoxMesh.new()
    scarf_mesh.size = Vector3(0.12,0.58,0.72)
    _mesh(self, scarf_mesh, cloth, Vector3(0,1.72,0.34), Vector3(1.0,1.0,1.0))

    var hair_mesh := SphereMesh.new()
    hair_mesh.radius = 0.31
    hair_mesh.height = 0.35
    _mesh(head, hair_mesh, cloth, Vector3(0,2.27,0.02), Vector3(1.0,0.72,0.92))

    var boot_mesh := BoxMesh.new()
    boot_mesh.size = Vector3(0.25,0.18,0.48)
    _mesh(left_leg, boot_mesh, cloth, Vector3(0,-0.84,-0.09))
    _mesh(right_leg, boot_mesh, cloth, Vector3(0,-0.84,-0.09))

    var sheath := BoxMesh.new()
    sheath.size = Vector3(0.07,1.0,0.10)
    _mesh(self, sheath, cloth, Vector3(-0.50,1.05,0.12), Vector3(1.0,1.0,1.0))

    var belt := MeshInstance3D.new()
    var belt_mesh := TorusMesh.new()
    belt_mesh.inner_radius = 0.34
    belt_mesh.outer_radius = 0.39
    belt_mesh.rings = 12
    belt_mesh.ring_segments = 16
    belt.mesh = belt_mesh
    belt.material_override = accent
    belt.position.y = 1.02
    add_child(belt)
    if not enemy:
        _apply_weapon_visual()

func _apply_weapon_visual() -> void:
    if not is_instance_valid(sword):
        return
    var data:Dictionary = WeaponSystem.get_current()
    var id:=WeaponSystem.equipped
    var length_scale:=1.0 + (float(data.range)-2.8)*0.7
    sword.scale=Vector3(1.0,length_scale,1.0)
    var blade_mesh:=sword.get_child(0) as MeshInstance3D
    if blade_mesh:
        var blade_mat:=_mat(Color(0.32,0.36,0.4,1),0.92,0.2)
        if id=="ASH_KATANA":
            blade_mat=_mat(Color(0.42,0.18,0.12,1),0.94,0.16)
        elif id=="SHADOW_BLADE":
            blade_mat=_mat(Color(0.08,0.11,0.15,1),0.98,0.10)
        elif id=="CITADEL_RELIC":
            blade_mat=_mat(Color(0.55,0.45,0.25,1),0.96,0.12)
        blade_mesh.material_override=blade_mat

func animate_state(speed: float, attacking: bool) -> void:
    if is_instance_valid(imported_model):
        # Subtle locomotion life for skinned imports that carry no walk clip.
        phase += speed * 0.09
        var bob := absf(sin(phase)) * minf(speed * 0.012, 0.06)
        imported_model.position.y = -_char_foot_offset + bob
        imported_model.rotation.x = sin(phase) * minf(speed * 0.004, 0.03)
        if attacking:
            imported_model.rotation.y = sin(phase * 4.0) * 0.06
        return
    if left_leg == null or right_leg == null or left_arm == null or right_arm == null or not is_instance_valid(sword):
        return
    phase += speed * 0.08
    var stride := sin(phase) * minf(speed * 0.08, 0.55)
    left_leg.rotation.x = stride
    right_leg.rotation.x = -stride
    left_arm.rotation.x = -stride * 0.8
    right_arm.rotation.x = stride * 0.8
    if attacking:
        right_arm.rotation.z = -0.9
        sword.rotation_degrees = Vector3(0,0,20)
    else:
        sword.rotation_degrees = Vector3(0,0,70)

func hit_flash() -> void:
    for child in get_children():
        if child is MeshInstance3D:
            var old: Material = child.material_override
            var flash := _mat(Color(1.0,0.65,0.4,1), 0.2, 0.25)
            child.material_override = flash
            var tw := create_tween()
            tw.tween_interval(0.06)
            tw.tween_callback(func(): child.material_override = old)
