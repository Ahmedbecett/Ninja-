extends CharacterBody3D
class_name EnemyAI

@export var max_health := 120.0
@export var move_speed := 2.8
@export var chase_range := 16.0
@export var attack_range := 1.9
@export var attack_damage := 14.0
@export var xp_reward := 25

var health := 120.0
var target: Node3D
var attack_timer := 0.0
var stagger_timer := 0.0

func _ready() -> void:
    health = max_health
    add_to_group("enemies")

func _physics_process(delta: float) -> void:
    attack_timer = maxf(attack_timer - delta, 0.0)
    stagger_timer = maxf(stagger_timer - delta, 0.0)
    if stagger_timer > 0.0:
        velocity.x = move_toward(velocity.x, 0.0, 20.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 20.0 * delta)
        move_and_slide()
        return
    if not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player")
        return
    var offset := target.global_position - global_position
    var distance := offset.length()
    if distance > chase_range:
        velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
    elif distance > attack_range:
        var dir := offset.normalized()
        velocity.x = dir.x * move_speed
        velocity.z = dir.z * move_speed
        rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), minf(delta * 6.0, 1.0))
    else:
        velocity.x = move_toward(velocity.x, 0.0, 18.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 18.0 * delta)
        if attack_timer <= 0.0 and target.has_method("take_damage"):
            attack_timer = 1.15
            target.take_damage(attack_damage)
    move_and_slide()

func take_damage(amount: float, source: Vector3 = Vector3.ZERO) -> void:
    health -= amount
    stagger_timer = 0.18
    if source != Vector3.ZERO:
        velocity += (global_position - source).normalized() * 5.5
    if health <= 0.0:
        var state := get_tree().get_first_node_in_group("game_state")
        if state and state.has_method("register_kill"):
            state.register_kill()
        queue_free()
