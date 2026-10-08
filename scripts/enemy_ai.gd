extends CharacterBody3D
class_name EnemyAI

@export var max_health := 120.0
@export var move_speed := 2.8
@export var chase_range := 18.0
@export var attack_range := 1.85
@export var attack_damage := 14.0
@export var xp_reward := 25

var health := 120.0
var target: Node3D
var attack_timer := 0.0
var stagger_timer := 0.0
var visual: CharacterVisual

func _ready() -> void:
    health = max_health
    add_to_group("enemies")
    visual = get_node_or_null("Visual") as CharacterVisual

func _physics_process(delta: float) -> void:
    attack_timer = maxf(attack_timer-delta,0.0)
    stagger_timer = maxf(stagger_timer-delta,0.0)
    if stagger_timer > 0.0:
        velocity.x = move_toward(velocity.x,0,24*delta)
        velocity.z = move_toward(velocity.z,0,24*delta)
        move_and_slide()
        return
    if not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player")
        return
    var offset: Vector3 = target.global_position-global_position
    var distance: float = offset.length()
    if distance > chase_range:
        velocity.x = move_toward(velocity.x,0,12*delta)
        velocity.z = move_toward(velocity.z,0,12*delta)
    elif distance > attack_range:
        var dir: Vector3 = offset.normalized()
        velocity.x = dir.x*move_speed
        velocity.z = dir.z*move_speed
        rotation.y = lerp_angle(rotation.y,atan2(-dir.x,-dir.z),delta*7.0)
    else:
        velocity.x = move_toward(velocity.x,0,20*delta)
        velocity.z = move_toward(velocity.z,0,20*delta)
        rotation.y = lerp_angle(rotation.y,atan2(-offset.x,-offset.z),delta*9.0)
        if attack_timer <= 0.0 and target.has_method("take_damage"):
            attack_timer = 1.15
            target.take_damage(attack_damage)
    if visual:
        visual.animate_state(Vector2(velocity.x,velocity.z).length(),attack_timer>1.0)
    move_and_slide()

func take_damage(amount: float, source: Vector3 = Vector3.ZERO) -> void:
    health -= amount
    stagger_timer = 0.16
    if visual:
        visual.hit_flash()
    VFX.impact(get_parent(),global_position)
    if source != Vector3.ZERO:
        velocity += (global_position-source).normalized()*6.0
    if health <= 0.0:
        GameState.register_kill()
        QuestSystem.register_kill(false)
        queue_free()
