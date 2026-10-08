extends Node3D
class_name CombatSystem

@export var attack_angle := 110.0
@export var damage_light := 32.0
@export var damage_heavy := 58.0

var combo_step := 0
var combo_window := 0.0
var attack_lock := 0.0

func tick(delta: float) -> void:
    combo_window = maxf(combo_window - delta, 0.0)
    attack_lock = maxf(attack_lock - delta, 0.0)
    if combo_window <= 0.0:
        combo_step = 0

func try_attack(owner: Node3D, heavy := false) -> bool:
    if attack_lock > 0.0:
        return false
    combo_step = (combo_step % 3) + 1
    combo_window = 0.9
    var base_lock := 0.18 if not heavy else 0.45
    attack_lock = WeaponSystem.get_attack_lock(base_lock)
    var base_damage := damage_heavy if heavy else damage_light + (combo_step - 1) * 6.0
    var damage := WeaponSystem.get_damage(base_damage)
    var attack_distance := WeaponSystem.get_range()
    for enemy in owner.get_tree().get_nodes_in_group("enemies"):
        if not is_instance_valid(enemy):
            continue
        var offset: Vector3 = enemy.global_position - owner.global_position
        if offset.length() > attack_distance:
            continue
        var forward := -owner.global_transform.basis.z
        var angle := rad_to_deg(acos(clampf(forward.dot(offset.normalized()), -1.0, 1.0)))
        if angle <= attack_angle * 0.5 and enemy.has_method("take_damage"):
            enemy.take_damage(damage, owner.global_position)
    return true
